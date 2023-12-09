[![pub](https://img.shields.io/pub/v/landart.svg)](https://pub.dev/packages/landart)
[![documentation](https://img.shields.io/badge/Documentation-landart-blue.svg)](https://pub.dev/documentation/landart/latest/)

An API wrapper for [Lanyard](https://github.com/Phineas/lanyard) written in Dart. 

## Features

- Get user's presence data
- Subscribing to user presence
- Access Lanyard KV

## Getting started

Make sure your target user already joined Lanyard's Discord server.  
Check out [Phineas/lanyard](https://github.com/Phineas/lanyard) for more information.

## Usage

```dart
import 'package:landart/landart.dart';

void main() async {
  LanyardUser user = await Lanyard.fetchUser("someUserId");
  List<String> users = (await Lanyard.fetchMultiUser(
    ["someUserId1", "someUserId2", "someUserId3"]
  )).map((e) => e.discordUser.id).toList();
  
  (await Lanyard.subscribe(user.discordUser.id)).listen((user) {
    user.toObject();
  });
  (await Lanyard.subscribeMultiple(users)).listen((user) {
    user.values;
  });
  (await Lanyard.subscribeAll()).listen((user) {
    user.toObject();
  });

  LanyardKV kv = LanyardKV(
    userId: "someUserId",
    token: "someToken"
  );

  kv.token("someOtherToken");

  await kv.set("randomKey", "randomValue");
  await kv.setAll({
    "randomKey1": "randomValue1",
    "randomKey2": "randomValue2",
    "randomKey3": "randomValue3",
  });

  await kv.get("randomKey");
  await kv.getAll();

  await kv.delete("randomKey");
  await kv.deleteAll();
}
