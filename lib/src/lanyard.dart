import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:http/http.dart';

import 'package:landart/src/config.dart';
import 'package:landart/src/type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


/// Base class for interacting with the Lanyard API.
abstract class Lanyard {
  static final Client _httpClient = Client();

  static final ZLibDecoder _zlibDecoder = ZLibDecoder();
  static const Utf8Decoder _utf8Decoder = Utf8Decoder();

  /// Fetch user by Discord ID.
  static Future<LanyardUser> fetchUser(String userId) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$userId");
    Response res = await _httpClient.get(uri);

    dynamic jsonBody = jsonDecode(res.body);

    switch (res.statusCode) {
      case 200: {
        if (!jsonBody["success"]) {
          throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
        }

        return LanyardUser.fromJson(jsonBody["data"]);
      }
      default: {
        throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
      }
    }
  }

  /// Fetch multiple users at the same time.
  static Future<List<LanyardUser>> fetchMultiUser(List<String> userIdList) async {
    List<LanyardUser> result = [];

    for (String userId in userIdList) {
      result.add(await Lanyard.fetchUser(userId));
    }

    return result;
  }

  /// Handles basic socket functions like decompression, decoding and heartbeats.
  static (WebSocketChannel, Stream<_LanyardSocketEvent>) _handleSocket() {
    Uri uri = Uri.parse("wss://${Config.apiPath}/socket?compression=zlib_json");
    WebSocketChannel socketClient = WebSocketChannel.connect(uri);
    Stream<dynamic> socketStream = socketClient.stream.asBroadcastStream();

    Stream<_LanyardSocketEvent> eventStream = socketStream
      .map((r) => _utf8Decoder.convert(_zlibDecoder.decodeBytes(r))) // Decompress zlib data
      .map((s) => jsonDecode(s)) // Decode to JSON
      .map(_LanyardSocketEvent.fromJson); // Parse JSON data into `LanyardSocketEvent`

    eventStream
      .firstWhere((e) => e.opCode == 1)
      .then((e) {
        Timer.periodic(
          Duration(milliseconds: e.data["heartbeat_interval"]),
          (t) {
            // Cancel heartbeat timer if connection is closed
            if (socketClient.closeCode != null) {
              t.cancel();
              return;
            }
            
            // Send heartbeat event
            socketClient.sink.add(
              _LanyardSocketEvent(
                opCode: 3
              ).toJson()
            );
          }
        );
      });

    return (socketClient, eventStream);
  }

  /// Subscribing to a single user presence.
  static Stream<LanyardUser> subscribe(String userId) {
    var (socketClient, eventStream) = _handleSocket();

    socketClient.sink.add(
      _LanyardSocketEvent(
        opCode: 2,
        data: {
          "subscribe_to_id": userId
        }
      ).toJson()
    );

    return eventStream
      .where((e) => e.opCode == 0)
      .map((e) => LanyardUser.fromJson(e.data));
  }

  /// Subscribing to multiple user presences.
  static Stream<Map<String, LanyardUser>> subscribeMultiple(List<String> userIdList) {
    var (socketClient, eventStream) = _handleSocket();

    socketClient.sink.add(
      _LanyardSocketEvent(
        opCode: 2,
        data: {
          "subscribe_to_ids": userIdList
        }
      ).toJson()
    );

    return eventStream
      .where((e) => e.opCode == 0)
      .map((e) => e.data as Map<String, dynamic>)
      .map((e) => e.map((k, v) => MapEntry(k, LanyardUser.fromJson(v))));
  }

  /// Subscribing to every user presence.
  static Stream<LanyardUser> subscribeAll() {
    var (socketClient, eventStream) = _handleSocket();

    socketClient.sink.add(
      _LanyardSocketEvent(
        opCode: 2,
        data: {
          "subscribe_to_all": true
        }
      ).toJson()
    );

    return eventStream
      .where((e) => e.opCode == 0)
      .skipWhile((e) => e.type == "INIT_STATE") // Skip `INIT_STATE` event, takes too long to decode
      .map((e) => LanyardUser.fromJson(e.data));
  }
}

class _LanyardSocketEvent {
  final int opCode;
  final dynamic data;
  final String? type;

  _LanyardSocketEvent({
    required this.opCode,
    this.data,
    this.type
  });

  /// Parse JSON data into [_LanyardSocketEvent].
  static _LanyardSocketEvent fromJson(dynamic json) {
    return _LanyardSocketEvent(
      opCode: json["op"],
      data: json["d"],
      type: json["t"]
    );
  }

  /// Convert [_LanyardSocketEvent] to JSON data.
  String toJson() {
    return jsonEncode(
      {
        "op": opCode,
        "d": data,
        "t": type
      }
    );
  }
}
