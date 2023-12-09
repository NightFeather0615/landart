import 'dart:convert';


/// Utilities for data parsering.
abstract class ParseUtils {
  /// JSON encoder with indent.
  static const JsonEncoder jsonEncoder = JsonEncoder.withIndent("  ");
  
  /// Parse JSON data into [Map<String, String>].
  static Map<String, String>? parseStringMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
