import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import 'secure_storage_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    http.Client? httpClient,
  })  : _storage = storage,
        _http = httpClient ?? http.Client();

  final SecureStorageService _storage;
  final http.Client _http;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<dynamic> get(String path) async {
    final response = await _http.get(_uri(path), headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final response = await _http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _decode(response);
  }

  Future<List<int>> getBytes(String path) async {
    final response = await _http.get(_uri(path), headers: await _headers());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException('Failed to download file', statusCode: response.statusCode);
  }

  dynamic _decode(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {'message': response.body};
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['message'] != null
        ? '${decoded['message']}'
        : 'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
