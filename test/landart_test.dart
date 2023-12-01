import 'package:flutter_test/flutter_test.dart';

import 'package:landart/landart.dart';
import 'package:landart/type.dart';

void main() async {
  test("test http", () async {
    var data = await Landart.fetchUser("");
    print(LanyardUser.fromJson(data).activities.first.timestamps.start);
  });
  // test('test sub', () async {
  //   (await Landart.subscribe(["283841865403465728"])).listen(print);
  //   await Future.delayed(Duration(days: 999999));
  // });
}
