import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final TokenStorage _tokenStorage;

  ApiClient({TokenStorage? tokenStorage}) : _tokenStorage = tokenStorage ?? TokenStorage();

  String get baseUrl => ApiConstants.baseUrl;

  Future<String?> getToken() => _tokenStorage.getToken();

  Future<void> setToken(String token) => _tokenStorage.setToken(token);

  Future<void> removeToken() => _tokenStorage.removeToken();

  Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    final token = includeAuth ? await _tokenStorage.getToken() : null;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri uri(String path, [Map<String, String>? queryParams]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(queryParameters: queryParams);
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    return http.get(
      uri(path, queryParams),
      headers: await getHeaders(includeAuth: includeAuth),
    );
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool includeAuth = true,
  }) async {
    return http.post(
      uri(path),
      headers: await getHeaders(includeAuth: includeAuth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    bool includeAuth = true,
  }) async {
    return http.put(
      uri(path),
      headers: await getHeaders(includeAuth: includeAuth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {bool includeAuth = true}) async {
    return http.delete(
      uri(path),
      headers: await getHeaders(includeAuth: includeAuth),
    );
  }
}
