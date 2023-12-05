import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:landart/landart.dart';

void main() async {
  test("Fetch Single User", () async {
    LanyardUser user = await Landart.fetchUser("94490510688792576");
    
    debugPrint(user.toString());
  });

  test("Fetch Multi User", () async {
    List<LanyardUser> users = await Landart.fetchMultiUser(
      ["94490510688792576", "156114103033790464", "819287687121993768"]
    );

    debugPrint(users.toString());
  });
}
