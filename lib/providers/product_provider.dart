import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'paginated_list_mixin.dart';

class ProductProvider with ChangeNotifier, PaginatedListMixin<Product> {
  final ApiService _apiService = ApiService();
  int? _categoryId;

  List<Product> get products => items;
  int? get categoryId => _categoryId;

  /// GET /v1/products?page=1&limit=15&search=query
  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) resetPagination();

    if (!hasMore && !refresh) return;
    if (isLoading || isLoadingMore) return;

    final pageToFetch = currentPage;
    final loadingMore = !refresh && items.isNotEmpty;
    isLoading = !loadingMore;
    isLoadingMore = loadingMore;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: pageToFetch,
        limit: 15,
        search: searchQuery.isEmpty ? null : searchQuery,
        categoryId: _categoryId,
      );

      if (response.status == 'Success' && response.data != null) {
        applyPaginatedResult(response.data!, refresh: refresh);
      } else {
        setError(response.message.isNotEmpty ? response.message : 'Failed to fetch products.');
      }
    } catch (e) {
      setError('Failed to fetch products: $e');
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  /// Replace list with a specific page (footer pagination — Option A).
  Future<void> fetchPage(int page) async {
    if (isLoading) return;
    isLoading = true;
    isLoadingMore = false;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: page,
        limit: 15,
        search: searchQuery.isEmpty ? null : searchQuery,
        categoryId: _categoryId,
      );

      if (response.status == 'Success' && response.data != null) {
        final paginated = response.data!;
        items
          ..clear()
          ..addAll(paginated.data);
        lastPage = paginated.lastPage;
        total = paginated.total;
        currentPage = page + 1;
        hasMore = page < lastPage;
      } else {
        setError(response.message);
      }
    } catch (e) {
      setError('Failed to fetch products: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    searchQuery = query;
    resetPagination();
    await fetchProducts(refresh: true);
  }

  Future<void> applyFilters({String? search, int? categoryId}) async {
    if (search != null) searchQuery = search;
    if (categoryId != null) _categoryId = categoryId;
    resetPagination();
    await fetchProducts(refresh: true);
  }

  void goToPreviousPage() {
    final page = displayPage;
    if (page > 1) fetchPage(page - 1);
  }

  void goToNextPage() {
    final page = displayPage;
    if (page < lastPage) fetchPage(page + 1);
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiService.getProduct(id);
      if (response.status == 'Success') return response.data;
    } catch (e) {
      setError('Failed to fetch product: $e');
    }
    return null;
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.createProduct(productData);
      if (response.status == 'Success') {
        await fetchProducts(refresh: true);
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to create product: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final response = await _apiService.updateProduct(id, productData);
      if (response.status == 'Success') {
        final index = items.indexWhere((p) => p.id == id);
        if (index != -1) {
          items[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to update product: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiService.deleteProduct(id);
      if (response.status == 'Success') {
        items.removeWhere((p) => p.id == id);
        total = (total - 1).clamp(0, total);
        notifyListeners();
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to delete product: $e');
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
