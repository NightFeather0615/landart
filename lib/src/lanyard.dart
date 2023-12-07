import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:landart/src/config.dart';
import 'package:landart/src/extension.dart';
import 'package:landart/src/type.dart';


/// Base class for interacting with the Lanyard API.
abstract class Lanyard {
  static final HttpClient _httpClient = HttpClient();

  static final ZLibDecoder _zlibDecoder = ZLibDecoder();
  static const Utf8Decoder _utf8Decoder = Utf8Decoder();

  /// Fetch user by Discord ID.
  static Future<LanyardUser> fetchUser(String userId) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$userId");
    HttpClientResponse res = await (await _httpClient.getUrl(uri)).close();

    dynamic jsonBody = jsonDecode(await res.body());

    switch (res.statusCode) {
      case 200: {
        if (!jsonBody["success"]) {
          throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
        }

        return LanyardUser.fromJson(jsonBody["data"]);
      }
      case 404: {
        throw Exception(jsonBody["error"]["message"]);
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
  static Future<(WebSocket, Stream<LanyardSocketEvent>)> _handleSocket() async {
    WebSocket socketClient = await WebSocket.connect("wss://${Config.apiPath}/socket?compression=zlib_json");
    Stream<dynamic> socketStream = socketClient.asBroadcastStream();

    Stream<LanyardSocketEvent> eventStream = socketStream
      .map((r) => _utf8Decoder.convert(_zlibDecoder.convert(r))) // Decompress zlib data
      .map((s) => jsonDecode(s)) // Decode to JSON
      .map(LanyardSocketEvent.fromJson); // Parse JSON data into `LanyardSocketEvent`

    int heartbeatInterval = (
      await eventStream.firstWhere((e) => e.opCode == 1)
    ).data["heartbeat_interval"]; // Get heartbeat interval from event

    Timer.periodic(
      Duration(milliseconds: heartbeatInterval),
      (t) {
        // Cancel heartbeat timer if connection is closed
        if (socketClient.closeCode != null) {
          t.cancel();
          return;
        }
        
        // Send heartbeat event
        socketClient.add(
          LanyardSocketEvent(
            opCode: 3
          ).toJson()
        );
      }
    );

    return (socketClient, eventStream);
  }

  /// Subscribing to a single user presence.
  static Future<Stream<LanyardUser>> subscribe(String userId) async {
    var (socketClient, eventStream) = await _handleSocket();

    socketClient.add(
      LanyardSocketEvent(
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
  static Future<Stream<Map<String, LanyardUser>>> subscribeMultiple(List<String> userIdList) async {
    var (socketClient, eventStream) = await _handleSocket();

    socketClient.add(
      LanyardSocketEvent(
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
  static Future<Stream<LanyardUser>> subscribeAll() async {
    var (socketClient, eventStream) = await _handleSocket();

    socketClient.add(
      LanyardSocketEvent(
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
