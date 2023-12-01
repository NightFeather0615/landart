library landart;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:landart/config.dart';
import 'package:landart/extension.dart';
import 'package:landart/type.dart';


class Landart {
  static final HttpClient _httpClient = HttpClient();

  static Future<dynamic> fetchUser(String userId) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/v1/users/$userId");
    HttpClientResponse res = await (await _httpClient.getUrl(uri)).close();

    return jsonDecode(await res.body());
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
