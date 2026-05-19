import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/constants/constants.dart';
import '../core/utils/app_toast.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';

class _DefaultCategory {
  final int id;
  final String name;
  final IconData icon;

  const _DefaultCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  static const List<_DefaultCategory> _defaultCategories = [
    _DefaultCategory(id: 1, name: 'Foods', icon: Icons.restaurant_outlined),
    _DefaultCategory(id: 2, name: 'Drinks', icon: Icons.local_drink_outlined),
    _DefaultCategory(id: 3, name: 'Snacks', icon: Icons.cookie_outlined),
    _DefaultCategory(id: 4, name: 'Others', icon: Icons.category_outlined),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _reorderLevelController = TextEditingController();

  final ApiService _apiService = ApiService();
  List<Supplier> _suppliers = [];
  int? _selectedSupplierId;
  int _selectedCategoryId = _defaultCategories.first.id;
  bool _suppliersLoading = false;
  String? _suppliersError;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _skuController.text = widget.product!.sku ?? '';
      _costPriceController.text = widget.product!.costPrice?.toString() ?? '';
      _sellingPriceController.text = widget.product!.sellingPrice?.toString() ?? '';
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _reorderLevelController.text = widget.product!.reorderLevel?.toString() ?? '';
      _selectedSupplierId = widget.product!.supplierId;
      _isActive = widget.product!.isActive;
      _selectedCategoryId = _categoryIdForName(widget.product!.category?.name);
    }

    _fetchSuppliers();
  }

  int _categoryIdForName(String? name) {
    if (name == null || name.isEmpty) return _defaultCategories.first.id;
    final match = _defaultCategories.where((c) => c.name.toLowerCase() == name.toLowerCase());
    return match.isNotEmpty ? match.first.id : _defaultCategories.last.id;
  }

  String get _selectedCategoryName {
    return _defaultCategories.firstWhere((c) => c.id == _selectedCategoryId).name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
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
      final response = await _apiService.getSuppliers(limit: 100);
      if (response.status == 'Success' && response.data != null) {
        setState(() {
          _suppliers = response.data!.data;
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
      'category': _selectedCategoryName,
      'category_id': _selectedCategoryId,
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
      AppToast.success(
        context,
        widget.product != null ? 'Product updated successfully' : 'Product created successfully',
      );
      Navigator.of(context).pop();
    } else if (mounted && productProvider.error != null) {
      AppToast.error(context, productProvider.error!);
    }
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _defaultCategories.length,
            itemBuilder: (context, index) {
              final category = _defaultCategories[index];
              final selected = _selectedCategoryId == category.id;

              return Padding(
                padding: EdgeInsets.only(right: index < _defaultCategories.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategoryId = category.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: 88,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.borderMuted,
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.icon,
                          size: 26,
                          color: selected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.product != null ? 'Edit Product' : 'Add Product',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ImsCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product != null ? 'Update product details' : 'Create a new product',
                  style: AppTextStyles.caption.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 20),
                _buildCategorySelector(),
                const SizedBox(height: 20),
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
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: _isActive,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: widget.product != null ? 'Update Product' : 'Add Product',
                  onPressed: _saveProduct,
                  isLoading: _isLoading,
                  icon: widget.product != null ? Icons.save_outlined : Icons.add_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
