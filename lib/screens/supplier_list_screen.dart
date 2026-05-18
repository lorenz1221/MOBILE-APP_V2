import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/app_shell.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final ApiService _apiService = ApiService();
  final List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      if (refresh) {
        _suppliers.clear();
      }
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getSuppliers();
      if (response.status == 'Success' && response.data != null) {
        setState(() {
          if (refresh) {
            _suppliers.clear();
          }
          _suppliers.addAll(response.data!);
        });
      } else {
        setState(() {
          _error = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load suppliers: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/suppliers',
      title: 'Suppliers',
      body: _isLoading && _suppliers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchSuppliers(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _suppliers.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _suppliers.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final supplier = _suppliers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(supplier.name),
                        subtitle: Text(supplier.contactPerson ?? 'No contact info'),
                        trailing: Text(supplier.isActive ? 'Active' : 'Inactive'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/supplier_form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
