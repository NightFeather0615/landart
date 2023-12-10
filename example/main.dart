import 'package:landart/landart.dart';

void main() async {
  LanyardUser user = await Lanyard.fetchUser("someUserId");
  List<String> users = (await Lanyard.fetchMultiUser(
    ["someUserId1", "someUserId2", "someUserId3"]
  )).map((e) => e.discordUser.id).toList();
  
  Lanyard.subscribe(user.discordUser.id).listen((user) {
    user.toObject();
  });
  Lanyard.subscribeMultiple(users).listen((user) {
    user.toObject();
  });
  Lanyard.subscribeAll().listen((user) {
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
