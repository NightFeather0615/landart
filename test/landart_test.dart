import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:landart/landart.dart';

void main() async {
  test("Fetch Single User", () async {
    LanyardUser user = await Landart.fetchUser("94490510688792576");
    
    expect(user.discordUser.id, "94490510688792576");
  });

  test("Fetch Multiple User", () async {
    List<LanyardUser> users = await Landart.fetchMultiUser(
      ["94490510688792576", "156114103033790464", "819287687121993768"]
    );

    expect(users.length, 3);
  });

  test("Subscribe Single User", () async {
    Stream<LanyardUser> event = await Landart.subscribe("94490510688792576");

    bool hasError = false;

    event.listen((_) => {}, onError: (e) => hasError = true);

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });

  test("Subscribe Multiple User", () async {
    Stream<Map<String, LanyardUser>> event = await Landart.subscribeMulti(
      ["94490510688792576", "156114103033790464", "819287687121993768"]
    );

    bool hasError = false;

    event.listen((_) => {}, onError: (e) => hasError = true);

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });

  test("Subscribe All", () async {
    Stream<LanyardUser> event = await Landart.subscribeAll();

    bool hasError = false;

    event.listen((_) => {}, onError: (e) => hasError = true);

    await Future.delayed(const Duration(seconds: 10));

    expect(hasError, false);
  });
}
