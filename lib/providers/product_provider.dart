import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  int? _categoryId;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  int? get categoryId => _categoryId;

  Future<void> fetchProducts({bool refresh = false, String? search, int? categoryId}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore || _isLoading) return;

    _searchQuery = search ?? _searchQuery;
    _categoryId = categoryId ?? _categoryId;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _categoryId,
      );

      if (response.status == 'Success' && response.data != null) {
        final paginated = response.data!;
        if (refresh) {
          _products.clear();
        }
        _products.addAll(paginated.data);
        _currentPage++;
        _totalPages = paginated.lastPage;
        _hasMore = _currentPage <= _totalPages;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters({String? search, int? categoryId}) async {
    _searchQuery = search ?? _searchQuery;
    _categoryId = categoryId;
    await fetchProducts(refresh: true);
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiService.getProduct(id);
      if (response.status == 'Success') {
        return response.data;
      }
    } catch (e) {
      _error = 'Failed to fetch product: $e';
    }
    return null;
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.createProduct(productData);
      if (response.status == 'Success') {
        // Refresh products
        await fetchProducts(refresh: true);
        return true;
      }
    } catch (e) {
      _error = 'Failed to create product: $e';
    }
    return false;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.updateProduct(id, productData);
      if (response.status == 'Success') {
        // Update local list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Failed to update product: $e';
    }
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiService.deleteProduct(id);
      if (response.status == 'Success') {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to delete product: $e';
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}