import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import 'package:landart/landart.dart';

void main() async {
  late String kvToken;

  setUpAll(() {
    String? env = Platform.environment["LANYARD_KV_TOKEN"];
    if (env == null) {
      throw Exception("Environment variable `LANYARD_KV_TOKEN` is not set");
    }
    kvToken = env;
  });

  test("Fetch Single User", () async {
    LanyardUser user = await Lanyard.fetchUser("94490510688792576");
    
    expect(user.discordUser.id, "94490510688792576");
  });

  test("Fetch Multiple User", () async {
    List<LanyardUser> users = await Lanyard.fetchMultiUser(
      ["94490510688792576", "156114103033790464", "819287687121993768"]
    );

    expect(users.length, 3);
  });

  test("Subscribe Single User", () async {
    Stream<LanyardUser> event = await Lanyard.subscribe("94490510688792576");

    bool hasError = false;

    event.listen(
      (_) => {},
      onError: (_) => hasError = true,
      cancelOnError: true
    );

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });

  test("Subscribe Multiple User", () async {
    Stream<Map<String, LanyardUser>> event = await Lanyard.subscribeMultiple(
      ["94490510688792576", "156114103033790464", "819287687121993768"]
    );

    bool hasError = false;

    event.listen(
      (_) => {},
      onError: (_) => hasError = true,
      cancelOnError: true
    );

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });

  test("Subscribe All", () async {
    Stream<LanyardUser> event = await Lanyard.subscribeAll();

    bool hasError = false;

    event.listen(
      (_) => {},
      onError: (_) => hasError = true,
      cancelOnError: true
    );

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });

  test("KV Set Single", () async {
    LanyardKV kv = LanyardKV(userId: "283841865403465728");
    kv.token(kvToken);

    String rnd = Random().nextInt(99999999).toString();

    await kv.set("test", rnd);
    String? data = await kv.get("test");

    expect(data, rnd);
  });

  test("KV Delete Single", () async {
    LanyardKV kv = LanyardKV(userId: "283841865403465728");
    kv.token(kvToken);

    await kv.delete("test");

    String? data = await kv.get("test");

    expect(data, null);
  });

  test("KV Set Multiple", () async {
    LanyardKV kv = LanyardKV(userId: "283841865403465728");
    kv.token(kvToken);

    String rnd() => Random().nextInt(99999999).toString();

    Map<String, String> testData = {
      "test1": rnd(),
      "test2": rnd(),
      "test3": rnd()
    };

    await kv.setAll(testData);

    Map<String, String> data = await kv.getAll();

    expect(data, testData);
  });

  test("KV Delete All", () async {
    LanyardKV kv = LanyardKV(userId: "283841865403465728");
    kv.token(kvToken);

    await kv.deleteAll();

    Map<String, String> data = await kv.getAll();

    expect(data.keys.length, 0);
  });
}
