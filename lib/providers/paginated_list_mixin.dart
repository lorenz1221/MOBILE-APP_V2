import 'package:flutter/foundation.dart';
import '../models/api_response.dart';

/// Shared pagination + search state for list providers.
mixin PaginatedListMixin<T> on ChangeNotifier {
  final List<T> items = [];
  int currentPage = 1;
  int lastPage = 1;
  int total = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String searchQuery = '';
  String? error;

  bool get isInitialLoading => isLoading && items.isEmpty;
  int get displayPage => currentPage > 1 ? currentPage - 1 : 1;

  void resetPagination() {
    currentPage = 1;
    lastPage = 1;
    total = 0;
    hasMore = true;
    items.clear();
    error = null;
  }

  void applyPaginatedResult(PaginatedResponse<T> page, {required bool refresh}) {
    if (refresh) items.clear();
    items.addAll(page.data);
    lastPage = page.lastPage;
    total = page.total;
    currentPage++;
    hasMore = currentPage <= lastPage;
  }

  void setError(String message) {
    error = message;
  }
}
