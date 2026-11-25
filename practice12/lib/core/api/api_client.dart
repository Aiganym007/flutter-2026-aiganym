import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, this._store);
  static const _base = 'https://jsonplaceholder.typicode.com';
  static const _timeout = Duration(seconds: 10);
  final http.Client _client;
  final SecureStore _store;

  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };
  Uri _uri(String path) => Uri.parse('$_base$path');
  Future<Object?> getJson(String path) =>
      _send(() async => _client.get(_uri(path), headers: await _headers()));

  Future<Object?> postJson(String path, Map<String, Object?> body) => _send(
    () async => _client.post(
      _uri(path),
      headers: {...await _headers(), 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpStatusException(res.statusCode);
      }
      return jsonDecode(res.body);
    } on SocketException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on FormatException {
      throw const BadResponseException();
    }
  }
}
