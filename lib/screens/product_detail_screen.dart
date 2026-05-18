import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = await productProvider.getProduct(widget.productId);

    setState(() {
      _product = product;
      _isLoading = false;
      _error = product == null ? 'Failed to load product' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: AppColors.primary,
        actions: [
          if (_product != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).pushNamed(
                '/edit_product',
                arguments: _product,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadProduct)
              : _product == null
                  ? const Center(child: Text('Product not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_product!.name, style: AppTextStyles.headline),
                          const SizedBox(height: 16),
                          if (_product!.description != null) ...[
                            Text('Description: ${_product!.description}', style: AppTextStyles.body),
                            const SizedBox(height: 8),
                          ],
                          Text('SKU: ${_product!.sku ?? 'N/A'}', style: AppTextStyles.body),
                          const SizedBox(height: 8),
                          Text('Stock Quantity: ${_product!.stockQuantity}', style: AppTextStyles.body),
                          const SizedBox(height: 8),
                          Text('Cost Price: \$${_product!.costPrice?.toStringAsFixed(2) ?? 'N/A'}', style: AppTextStyles.body),
                          const SizedBox(height: 8),
                          Text('Selling Price: \$${_product!.sellingPrice?.toStringAsFixed(2) ?? 'N/A'}', style: AppTextStyles.body),
                          const SizedBox(height: 8),
                          if (_product!.category != null) ...[
                            Text('Category: ${_product!.category!.name}', style: AppTextStyles.body),
                            const SizedBox(height: 8),
                          ],
                          if (_product!.supplier != null) ...[
                            Text('Supplier: ${_product!.supplier!.name}', style: AppTextStyles.body),
                            const SizedBox(height: 8),
                          ],
                          Text('Active: ${_product!.isActive ? 'Yes' : 'No'}', style: AppTextStyles.body),
                        ],
                      ),
                    ),
    );
  }
}