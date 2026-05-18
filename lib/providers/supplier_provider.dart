import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class SupplierProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuppliers({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    if (refresh) {
      _suppliers.clear();
    }
    notifyListeners();

    try {
      final response = await _apiService.getSuppliers();
      if (response.status == 'Success' && response.data != null) {
        if (refresh) {
          _suppliers.clear();
        }
        _suppliers.addAll(response.data!);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load suppliers: $e';
    }

    _isLoading = false;
    notifyListeners();
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
        _suppliers.insert(0, response.data!);
        notifyListeners();
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to create supplier: $e';
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
        final index = _suppliers.indexWhere((supplier) => supplier.id == id);
        if (index != -1) {
          _suppliers[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to update supplier: $e';
    }
    notifyListeners();
    return false;
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      final response = await _apiService.deleteSupplier(id);
      if (response.status == 'Success') {
        _suppliers.removeWhere((supplier) => supplier.id == id);
        notifyListeners();
        return true;
      }
      _error = response.message;
    } catch (e) {
      _error = 'Failed to delete supplier: $e';
    }
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
