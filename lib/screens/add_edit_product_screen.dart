import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _reorderLevelController = TextEditingController();

  final ApiService _apiService = ApiService();
  List<Supplier> _suppliers = [];
  List<Category> _categories = [];
  int? _selectedSupplierId;
  String? _selectedCategoryName;
  bool _suppliersLoading = false;
  bool _categoriesLoading = false;
  String? _suppliersError;
  String? _categoriesError;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _skuController.text = widget.product!.sku ?? '';
      _categoryController.text = widget.product!.category?.name ?? '';
      _costPriceController.text = widget.product!.costPrice?.toString() ?? '';
      _sellingPriceController.text = widget.product!.sellingPrice?.toString() ?? '';
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _reorderLevelController.text = widget.product!.reorderLevel?.toString() ?? '';
      _selectedSupplierId = widget.product!.supplierId;
      _selectedCategoryName = widget.product!.category?.name;
      _isActive = widget.product!.isActive;
    }

    _fetchSuppliers();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockQuantityController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      _suppliersLoading = true;
      _suppliersError = null;
    });

    try {
      final response = await _apiService.getSuppliers();
      if (response.status == 'Success' && response.data != null) {
        setState(() {
          _suppliers = response.data!;
        });
      } else {
        setState(() {
          _suppliersError = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _suppliersError = 'Failed to load suppliers: $e';
      });
    } finally {
      setState(() {
        _suppliersLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });

    try {
      final response = await _apiService.getCategories();
      if (response.status == 'Success' && response.data != null) {
        setState(() {
          _categories = response.data!;
        });
      } else {
        setState(() {
          _categoriesError = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _categoriesError = 'Failed to load categories: $e';
      });
    } finally {
      setState(() {
        _categoriesLoading = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final unitPrice = double.tryParse(_sellingPriceController.text) ??
        double.tryParse(_costPriceController.text) ??
        0.0;

    final productData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'sku': _skuController.text.trim(),
      'category': _selectedCategoryName ?? _categoryController.text.trim(),
      'cost_price': double.tryParse(_costPriceController.text) ?? 0.0,
      'selling_price': double.tryParse(_sellingPriceController.text) ?? 0.0,
      'unit_price': unitPrice,
      'stock_quantity': int.tryParse(_stockQuantityController.text) ?? 0,
      'reorder_level': int.tryParse(_reorderLevelController.text) ?? 0,
      'supplier_id': _selectedSupplierId,
      'is_active': _isActive,
    };

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (widget.product != null) {
      success = await productProvider.updateProduct(widget.product!.id, productData);
    } else {
      success = await productProvider.createProduct(productData);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _skuController,
                label: 'SKU',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _categoriesLoading
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryName,
                      items: [
                        ..._categories.map(
                          (category) => DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _selectedCategoryName = value),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
              if (_categoriesError != null) ...[
                const SizedBox(height: 8),
                Text(_categoriesError!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              _suppliersLoading
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<int?>(
                      initialValue: _selectedSupplierId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('No supplier'),
                        ),
                        ..._suppliers.map(
                          (supplier) => DropdownMenuItem<int?>(
                            value: supplier.id,
                            child: Text(supplier.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _selectedSupplierId = value),
                      decoration: InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
              if (_suppliersError != null) ...[
                const SizedBox(height: 8),
                Text(_suppliersError!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _costPriceController,
                      label: 'Cost Price',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _sellingPriceController,
                      label: 'Selling Price',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockQuantityController,
                      label: 'Stock Quantity',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _reorderLevelController,
                      label: 'Reorder Level',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.product != null ? 'Update Product' : 'Add Product',
                onPressed: _saveProduct,
                isLoading: _isLoading,
              ),
              if (productProvider.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  productProvider.error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}