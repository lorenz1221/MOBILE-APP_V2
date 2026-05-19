import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../models/api_response.dart';
import '../models/dashboard_summary.dart';
import '../models/user.dart';
import '../models/product.dart';

class ApiService {
  final ApiClient _client;

  ApiService({ApiClient? client}) : _client = client ?? ApiClient();

  String get baseUrl => _client.baseUrl;

  Future<String?> getToken() => _client.getToken();

  Future<void> setToken(String token) => _client.setToken(token);

  Future<void> removeToken() => _client.removeToken();

  String? _extractToken(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    if (data is Map<String, dynamic>) {
      return data['token'] as String? ?? data['access_token'] as String?;
    }
    return null;
  }

  User _parseUser(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      final payload = rawData['user'] is Map<String, dynamic> ? rawData['user'] as Map<String, dynamic> : rawData;
      return User.fromJson(payload);
    }
    throw FormatException('Unable to parse user data');
  }

  ApiResponse<Map<String, dynamic>> _mapResponse(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return ApiResponse.fromJson(decoded, (d) => d as Map<String, dynamic>);
    }
    return ApiResponse(status: 'Error', message: 'Invalid API response', data: null);
  }

  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    final response = await _client.post(
      '/login',
      body: {'email': email, 'password': password},
      includeAuth: false,
    );

    final apiResponse = _mapResponse(response);
    final data = apiResponse.data ?? <String, dynamic>{};
    final token = _extractToken(data);
    if (token != null) {
      await setToken(token);
    }

    return apiResponse;
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await _client.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      includeAuth: false,
    );

    final apiResponse = _mapResponse(response);
    final data = apiResponse.data ?? <String, dynamic>{};
    final token = _extractToken(data);
    if (token != null) {
      await setToken(token);
    }

    return apiResponse;
  }

  Future<ApiResponse<User>> getMe() async {
    const candidates = ['/v1/auth/me', '/auth/me', '/me', '/user'];
    for (final path in candidates) {
      try {
        final response = await _client.get(path);

        if (response.statusCode == 404) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (response.statusCode == 401) {
          await removeToken();
          return ApiResponse(status: 'Error', message: 'Unauthorized', data: null);
        }

        if (decoded is Map<String, dynamic>) {
          return ApiResponse.fromJson(decoded, (d) => _parseUser(d));
        }
        break;
      } catch (_) {
        continue;
      }
    }

    return ApiResponse(status: 'Error', message: 'Failed to load profile', data: null);
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    const candidates = ['/v1/auth/logout', '/auth/logout', '/logout'];
    for (final path in candidates) {
      try {
        final response = await _client.post(path);

        if (response.statusCode == 404) {
          continue;
        }

        final decoded = jsonDecode(response.body);
        await removeToken();

        if (decoded is Map<String, dynamic>) {
          return ApiResponse.fromJson(decoded, (d) => d as Map<String, dynamic>);
        }
        break;
      } catch (_) {
        continue;
      }
    }

    await removeToken();
    return ApiResponse(status: 'Success', message: 'Logged out successfully', data: <String, dynamic>{});
  }

  Future<ApiResponse<PaginatedResponse<Product>>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search?.isNotEmpty == true) 'search': search!,
      if (categoryId != null) 'category_id': categoryId.toString(),
    };

    final response = await _client.get('/v1/products', queryParams: queryParams);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => PaginatedResponse<Product>.fromJson(d, (item) => Product.fromJson(item)));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to fetch products.',
      data: null,
    );
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    final response = await _client.get('/v1/products/$id');
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Product.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to load product.',
      data: null,
    );
  }

  Future<ApiResponse<Product>> createProduct(Map<String, dynamic> productData) async {
    final response = await _client.post('/v1/products', body: productData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Product.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to create product.',
      data: null,
    );
  }

  Future<ApiResponse<Product>> updateProduct(int id, Map<String, dynamic> productData) async {
    final response = await _client.put('/v1/products/$id', body: productData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Product.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to update product.',
      data: null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteProduct(int id) async {
    final response = await _client.delete('/v1/products/$id');
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, (d) => <String, dynamic>{});
    }

    return ApiResponse(status: 'Error', message: 'Failed to delete product.', data: null);
  }

  Future<ApiResponse<DashboardSummary>> getDashboardSummary() async {
    final response = await _client.get('/v1/dashboard/summary');
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => DashboardSummary.fromJson(d as Map<String, dynamic>));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to load dashboard.',
      data: null,
    );
  }

  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int limit = 15,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search?.isNotEmpty == true) 'search': search!,
    };

    final response = await _client.get('/v1/categories', queryParams: queryParams);
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(
        data,
        (d) => PaginatedResponse<Category>.fromJson(
          d is Map<String, dynamic> ? d : {'data': d},
          (item) => Category.fromJson(item),
        ),
      );
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to fetch categories.',
      data: null,
    );
  }

  Future<ApiResponse<Category>> createCategory(Map<String, dynamic> categoryData) async {
    final response = await _client.post('/v1/categories', body: categoryData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Category.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to create category.',
      data: null,
    );
  }

  Future<ApiResponse<Category>> updateCategory(int id, Map<String, dynamic> categoryData) async {
    final response = await _client.put('/v1/categories/$id', body: categoryData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Category.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to update category.',
      data: null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteCategory(int id) async {
    final response = await _client.delete('/v1/categories/$id');
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, (d) => <String, dynamic>{});
    }

    return ApiResponse(status: 'Error', message: 'Failed to delete category.', data: null);
  }

  Future<ApiResponse<PaginatedResponse<Supplier>>> getSuppliers({
    int page = 1,
    int limit = 15,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search?.isNotEmpty == true) 'search': search!,
    };

    final response = await _client.get('/v1/suppliers', queryParams: queryParams);
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(
        data,
        (d) => PaginatedResponse<Supplier>.fromJson(
          d is Map<String, dynamic> ? d : {'data': d},
          (item) => Supplier.fromJson(item),
        ),
      );
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to fetch suppliers.',
      data: null,
    );
  }

  Future<ApiResponse<Supplier>> createSupplier(Map<String, dynamic> supplierData) async {
    final response = await _client.post('/v1/suppliers', body: supplierData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Supplier.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to create supplier.',
      data: null,
    );
  }

  Future<ApiResponse<Supplier>> updateSupplier(int id, Map<String, dynamic> supplierData) async {
    final response = await _client.put('/v1/suppliers/$id', body: supplierData);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(data, (d) => Supplier.fromJson(d));
    }

    return ApiResponse(
      status: data['status'] ?? 'Error',
      message: data['message'] ?? data['error'] ?? 'Failed to update supplier.',
      data: null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteSupplier(int id) async {
    final response = await _client.delete('/v1/suppliers/$id');
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, (d) => <String, dynamic>{});
    }

    return ApiResponse(status: 'Error', message: 'Failed to delete supplier.', data: null);
  }
}
