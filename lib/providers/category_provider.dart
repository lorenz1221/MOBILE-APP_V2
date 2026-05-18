import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    if (refresh) {
      _categories.clear();
    }
    notifyListeners();

    try {
      final response = await _apiService.getCategories();
      if (response.status == 'Success' && response.data != null) {
        if (refresh) {
          _categories.clear();
        }
        _categories.addAll(response.data!);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load categories: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory(String name, String? description) async {
    try {
      final response = await _apiService.createCategory({
        'name': name,
        'description': description,
      });
      if (response.status == 'Success' && response.data != null) {
        _categories.insert(0, response.data!);
        notifyListeners();
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to create category: $e';
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
        final index = _categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          _categories[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to update category: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.deleteCategory(id);
      if (response.status == 'Success') {
        _categories.removeWhere((category) => category.id == id);
        notifyListeners();
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to delete category: $e';
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
