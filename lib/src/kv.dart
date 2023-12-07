import 'dart:convert';
import 'dart:io';

import 'package:landart/landart.dart';
import 'package:landart/src/config.dart';
import 'package:landart/src/extension.dart';


/// Base class for interacting with the LanyardKV API.
class LanyardKV {
  static final HttpClient _httpClient = HttpClient();
  
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

    HttpClientRequest req = await _httpClient.putUrl(uri);
    req.headers.contentType = ContentType.text;
    req.headers.add("Authorization", _token ?? "");
    req.headers.contentLength = utf8.encode(value).length;
    req.write(value);

    HttpClientResponse res = await req.close();

    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(await res.body());

    switch (res.statusCode) {
      case 401: {
        throw Exception(jsonBody["error"]["message"]);
      }
      default: {
        throw Exception(jsonBody["error"]["message"] ?? "Unknown Error");
      }
    }
  }

  /// Setting multiple key->value pairs.
  Future<void> setAll(Map<String, String> data) async {
    Uri uri = Uri.parse("https://${Config.apiPath}/${Config.apiVersion}/users/$_userId/kv");

    String jsonString = jsonEncode(data);

    HttpClientRequest req = await _httpClient.patchUrl(uri);
    req.headers.contentType = ContentType.json;
    req.headers.add("Authorization", _token ?? "");
    req.headers.contentLength = utf8.encode(jsonString).length;
    req.write(jsonString);

    HttpClientResponse res = await req.close();

    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(await res.body());

    switch (res.statusCode) {
      case 401: {
        throw Exception(jsonBody["error"]["message"]);
      }
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

    HttpClientRequest req = await _httpClient.deleteUrl(uri);
    req.headers.add("Authorization", _token ?? "");

    HttpClientResponse res = await req.close();

    if (res.statusCode == 204) {
      return;
    }
    
    dynamic jsonBody = jsonDecode(await res.body());

    switch (res.statusCode) {
      case 401: {
        throw Exception(jsonBody["error"]["message"]);
      }
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
