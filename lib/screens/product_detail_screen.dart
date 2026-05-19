import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import '../widgets/app_shell.dart';
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

  Widget _detailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textMuted),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTextStyles.label.copyWith(fontSize: 10)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/dashboard',
      showDrawer: false,
      title: 'Product Details',
      actions: [
        if (_product != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Navigator.of(context).pushNamed(
              '/edit_product',
              arguments: _product,
            ),
          ),
      ],
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(message: _error!, onRetry: _loadProduct)
              : _product == null
                  ? const Center(child: Text('Product not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImsCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.15),
                                            AppColors.info.withValues(alpha: 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_product!.name, style: AppTextStyles.headline.copyWith(fontSize: 20)),
                                          const SizedBox(height: 4),
                                          Text(
                                            _product!.sku ?? 'No SKU',
                                            style: AppTextStyles.caption.copyWith(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _product!.isActive
                                            ? AppColors.success.withValues(alpha: 0.12)
                                            : AppColors.danger.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _product!.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _product!.isActive ? AppColors.success : AppColors.danger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_product!.description != null && _product!.description!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Divider(color: AppColors.borderMuted, height: 1),
                                  const SizedBox(height: 12),
                                  Text(_product!.description!, style: AppTextStyles.body.copyWith(fontSize: 14)),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ImsCard(
                            child: Column(
                              children: [
                                _detailRow('Stock Quantity', '${_product!.stockQuantity}', icon: Icons.warehouse_outlined),
                                const Divider(color: AppColors.borderMuted, height: 1),
                                _detailRow(
                                  'Cost Price',
                                  '₱${_product!.costPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                  icon: Icons.payments_outlined,
                                ),
                                const Divider(color: AppColors.borderMuted, height: 1),
                                _detailRow(
                                  'Selling Price',
                                  '₱${_product!.sellingPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                  icon: Icons.sell_outlined,
                                ),
                                if (_product!.category != null) ...[
                                  const Divider(color: AppColors.borderMuted, height: 1),
                                  _detailRow('Category', _product!.category!.name, icon: Icons.category_outlined),
                                ],
                                if (_product!.supplier != null) ...[
                                  const Divider(color: AppColors.borderMuted, height: 1),
                                  _detailRow('Supplier', _product!.supplier!.name, icon: Icons.local_shipping_outlined),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
