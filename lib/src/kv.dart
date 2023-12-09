import 'dart:convert';

import 'package:http/http.dart';

import 'package:landart/landart.dart';
import 'package:landart/src/config.dart';


/// Base class for interacting with the LanyardKV API.
class LanyardKV {
  static final Client _httpClient = Client();
  
  late final String _userId;
  String? _token;

  LanyardKV({
    required String userId,
    String? token
  }) {
    _userId = userId;
    _token = token;
  }

  /// Sets the token for the instance.
  void token(String token) {
    _token = token;
  }

  /// Setting a key->value pair.
  Future<void> set(String key, String value) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$_userId/kv/$key");
    
    Response res = await _httpClient.put(
      uri,
      headers: {
        "Content-Type": "text/plain",
        "Authorization": _token ?? ""
      },
      body: value
    );

    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(res.body);

    switch (res.statusCode) {
      default: {
        throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
      }
    }
  }

  /// Setting multiple key->value pairs.
  Future<void> setAll(Map<String, String> data) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$_userId/kv");

    Response res = await _httpClient.patch(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": _token ?? ""
      },
      body: jsonEncode(data)
    );

    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(res.body);

    switch (res.statusCode) {
      default: {
        throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
      }
    }
  }

  /// Get the data of the key.
  Future<String?> get(String key) async {
    LanyardUser user = await Lanyard.fetchUser(_userId);
    return user.keyValue[key];
  }

  /// Get data for all keys.
  Future<Map<String, String>> getAll() async {
    LanyardUser user = await Lanyard.fetchUser(_userId);
    return user.keyValue;
  }

  /// Delete a key.
  Future<void> delete(String key) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$_userId/kv/$key");

    Response res = await _httpClient.delete(
      uri,
      headers: {
        "Authorization": _token ?? ""
      }
    );
    
    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(res.body);

    switch (res.statusCode) {
      default: {
        throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
      }
    }
  }

  /// Delete all keys.
  Future<void> deleteAll() async {
    LanyardUser user = await Lanyard.fetchUser(_userId);

    for (String key in user.keyValue.keys) {
      await delete(key);
    }
  }
}
