import 'dart:convert';
import 'dart:io';

extension HttpClientResponseUtil on HttpClientResponse {
  Future<String> body({bool allowMalformed = true}) async {
    return utf8.decode(
      await expand((e) => e).toList(),
      allowMalformed: allowMalformed
    );
  }
}
