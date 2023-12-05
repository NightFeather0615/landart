import 'dart:convert';

class ParseUtils {
  static const JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
  
  static Map<String, String>? parseStringMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
