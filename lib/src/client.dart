import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:landart/src/config.dart';
import 'package:landart/src/extension.dart';
import 'package:landart/src/type.dart';


class Landart {
  static final HttpClient _httpClient = HttpClient();

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

  static Future<Stream<dynamic>> subscribe(List<String> userId) async {
    WebSocket socketClient = await WebSocket.connect("wss://${Config.apiPath}/socket");
    Stream<dynamic> socketStream = socketClient.asBroadcastStream();

    Stream<LanyardSocketEvent> eventStream = socketStream.map((s) => jsonDecode(s)).map(LanyardSocketEvent.fromJson);

    int heartbeatInterval = (
      await eventStream.firstWhere((e) => e.opCode == 1)
    ).data["heartbeat_interval"];

    socketClient.add(
      LanyardSocketEvent(
        opCode: 2,
        data: {
          "subscribe_to_ids": userId
        }
      ).toJson()
    );

    Timer heartbeatTimer = Timer.periodic(
      Duration(milliseconds: heartbeatInterval),
      (t) => socketClient.add(
        LanyardSocketEvent(
          opCode: 3
        ).toJson()
      )
    );

    socketStream.listen(
      (_) => {},
      onDone: () => heartbeatTimer.cancel(),
    );

    return socketStream;
  }
}
