import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:landart/src/config.dart';
import 'package:landart/src/extension.dart';
import 'package:landart/src/type.dart';


class Landart {
  static final HttpClient _httpClient = HttpClient();

  static final ZLibDecoder _zlibDecoder = ZLibDecoder();
  static const Utf8Decoder _utf8Decoder = Utf8Decoder();

  static Future<LanyardUser> fetchUser(String userId) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/v1/users/$userId");
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

  static Future<List<LanyardUser>> fetchMultiUser(List<String> userIdList) async {
    List<LanyardUser> result = [];

    for (String userId in userIdList) {
      result.add(await Landart.fetchUser(userId));
    }

    return result;
  }

  static Future<(WebSocket, Stream<LanyardSocketEvent>)> _handleSocket() async {
    WebSocket socketClient = await WebSocket.connect("wss://${Config.apiPath}/socket?compression=zlib_json");
    Stream<dynamic> socketStream = socketClient.asBroadcastStream();

    Stream<LanyardSocketEvent> eventStream = socketStream
      .map((r) => _utf8Decoder.convert(_zlibDecoder.convert(r)))
      .map((s) => jsonDecode(s))
      .map(LanyardSocketEvent.fromJson);

    int heartbeatInterval = (
      await eventStream.firstWhere((e) => e.opCode == 1)
    ).data["heartbeat_interval"];

    Timer.periodic(
      Duration(milliseconds: heartbeatInterval),
      (t) {
        if (socketClient.closeCode != null) {
          t.cancel();
          return;
        }

        socketClient.add(
          LanyardSocketEvent(
            opCode: 3
          ).toJson()
        );
      }
    );

    return (socketClient, eventStream);
  }

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

  static Future<Stream<Map<String, LanyardUser>>> subscribeMulti(List<String> userIdList) async {
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
      .skipWhile((e) => e.type == "INIT_STATE")
      .map((e) => LanyardUser.fromJson(e.data));
  }
}
