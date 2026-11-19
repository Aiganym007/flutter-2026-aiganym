import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});
  factory ApiClient.live({String host = 'jsonplaceholder.typicode.com'}) =>
      ApiClient(http.Client(), host: host);
  final http.Client _client;
  final String host;
  static const _timeout = Duration(seconds: 10);
  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final response = await _send(
      () => _client.get(Uri.https(host, path, query), headers: _headers),
    );
    _check(response);
    return response;
  }

  Future<http.Response> post(String path, Object body) async {
    final response = await _send(
      () => _client.post(
        Uri.https(host, path),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(response);
    return response;
  }

  dynamic decode(http.Response r) => _decode(r);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(_timeout);
      _log(response);
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final status = r.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    if (status >= 400) throw BadResponseException('HTTP $status');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('invalid JSON: ${e.message}');
    }
  }

  void _log(http.Response r) {
    if (kDebugMode) {
      final request = r.request;
      log(
        '${request?.method} ${request?.url} -> ${r.statusCode} '
        '(${r.bodyBytes.length} bytes)',
        name: 'api',
      );
    }
  }
}
