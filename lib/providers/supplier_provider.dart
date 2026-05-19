import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'paginated_list_mixin.dart';

class SupplierProvider with ChangeNotifier, PaginatedListMixin<Supplier> {
  final ApiService _apiService = ApiService();

  List<Supplier> get suppliers => items;

  /// GET /v1/suppliers?page=1&limit=15&search=query
  Future<void> fetchSuppliers({bool refresh = false}) async {
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
      final response = await _apiService.getSuppliers(
        page: pageToFetch,
        limit: 15,
        search: searchQuery.isEmpty ? null : searchQuery,
      );

      if (response.status == 'Success' && response.data != null) {
        applyPaginatedResult(response.data!, refresh: refresh);
      } else {
        setError(response.message.isNotEmpty ? response.message : 'Failed to load suppliers.');
      }
    } catch (e) {
      setError('Failed to load suppliers: $e');
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
      final response = await _apiService.getSuppliers(
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
      setError('Failed to load suppliers: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    searchQuery = query;
    resetPagination();
    await fetchSuppliers(refresh: true);
  }

  void goToPreviousPage() {
    final page = displayPage;
    if (page > 1) fetchPage(page - 1);
  }

  void goToNextPage() {
    final page = displayPage;
    if (page < lastPage) fetchPage(page + 1);
  }

  Future<bool> createSupplier(
    String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    bool isActive,
  ) async {
    try {
      final response = await _apiService.createSupplier({
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'is_active': isActive,
      });
      if (response.status == 'Success' && response.data != null) {
        await fetchSuppliers(refresh: true);
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to create supplier: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> updateSupplier(
    int id,
    String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    bool isActive,
  ) async {
    try {
      final response = await _apiService.updateSupplier(id, {
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'is_active': isActive,
      });
      if (response.status == 'Success' && response.data != null) {
        final index = items.indexWhere((s) => s.id == id);
        if (index != -1) {
          items[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to update supplier: $e');
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      final response = await _apiService.deleteSupplier(id);
      if (response.status == 'Success') {
        items.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
      setError(response.message);
    } catch (e) {
      setError('Failed to delete supplier: $e');
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
