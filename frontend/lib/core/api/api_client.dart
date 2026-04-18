import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP wrapper around the backend REST API.
///
/// Base URL defaults to empty (same-origin, when Flutter is served by the
/// Spring Boot backend). Override at build time with
/// `--dart-define=API_BASE_URL=http://localhost:8080` for a local dev run.
class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({http.Client? httpClient})
      : baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
        _http = httpClient ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final qp = query?.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: (qp == null || qp.isEmpty) ? null : qp,
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _http.get(_uri(path, query), headers: _jsonHeaders);
    return _decode(res, 'GET $path');
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final res = await _http.put(
      _uri(path, query),
      headers: _jsonHeaders,
      body: jsonEncode(body ?? {}),
    );
    return _decode(res, 'PUT $path');
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final res = await _http.post(
      _uri(path, query),
      headers: _jsonHeaders,
      body: jsonEncode(body ?? {}),
    );
    return _decode(res, 'POST $path');
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  dynamic _decode(http.Response res, String label) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('[ApiClient] $label → ${res.statusCode}: ${res.body}');
      throw ApiException(res.statusCode, res.body);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;

  const ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
