import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'paginated_list_mixin.dart';

class CategoryProvider with ChangeNotifier, PaginatedListMixin<Category> {
  final ApiService _apiService = ApiService();

  List<Category> get categories => items;

  /// GET /v1/categories?page=1&limit=15&search=query
  Future<void> fetchCategories({bool refresh = false}) async {
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
      final response = await _apiService.getCategories(
        page: pageToFetch,
        limit: 15,
        search: searchQuery.isEmpty ? null : searchQuery,
      );

      if (response.status == 'Success' && response.data != null) {
        applyPaginatedResult(response.data!, refresh: refresh);
      } else {
        setError(response.message.isNotEmpty ? response.message : 'Failed to load categories.');
      }
    } catch (e) {
      setError('Failed to load categories: $e');
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchPage(int page) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCategories(
        page: page,
        limit: 15,
        search: searchQuery.isEmpty ? null : searchQuery,
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
      setError('Failed to load categories: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    searchQuery = query;
    resetPagination();
    await fetchCategories(refresh: true);
  }

  void goToPreviousPage() {
    final page = displayPage;
    if (page > 1) fetchPage(page - 1);
  }

  void goToNextPage() {
    final page = displayPage;
    if (page < lastPage) fetchPage(page + 1);
  }

  Future<bool> createCategory(String name, String? description) async {
    try {
      final response = await _apiService.createCategory({
        'name': name,
        'description': description,
      });
      if (response.status == 'Success' && response.data != null) {
        await fetchCategories(refresh: true);
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to create category: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateCategory(int id, String name, String? description) async {
    try {
      final response = await _apiService.updateCategory(id, {
        'name': name,
        'description': description,
      });
      if (response.status == 'Success' && response.data != null) {
        final index = items.indexWhere((c) => c.id == id);
        if (index != -1) {
          items[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to update category: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.deleteCategory(id);
      if (response.status == 'Success') {
        items.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to delete category: $e');
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
