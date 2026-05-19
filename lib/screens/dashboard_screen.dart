import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_summary.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/app_shell.dart' show ImsCard, MetricCard;
import '../utils/app_toast.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardSummary? _summary;
  bool _isLoadingSummary = true;
  String? _summaryError;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _hasInitialized = true;
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await Future.wait([
      productProvider.fetchProducts(refresh: true),
      _fetchSummary(),
    ]);
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoadingSummary = true;
      _summaryError = null;
    });

    try {
      final response = await _apiService.getDashboardSummary();
      if (!mounted) return;
      if (response.status == 'Success' && response.data != null) {
        setState(() {
          _summary = response.data;
          _isLoadingSummary = false;
        });
      } else {
        setState(() {
          _summaryError = response.message.isNotEmpty ? response.message : 'Failed to load dashboard.';
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryError = 'Failed to load dashboard: $e';
        _isLoadingSummary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final counts = _summary?.counts;

    return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await _loadData();
          if (!context.mounted) return;
          AppToast.success(context, 'Dashboard refreshed');
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${authProvider.user?.name.split(' ').first ?? 'Team'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Operations Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track stock health, sales movement, and team activity.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoadingSummary && _summary == null)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: LoadingWidget())
            else if (_summaryError != null && _summary == null)
              CustomErrorWidget(message: _summaryError!, onRetry: _fetchSummary)
            else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  MetricCard(
                    label: 'Total Products',
                    value: '${counts?.products ?? productProvider.products.length}',
                    trend: 'Active SKUs',
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.info,
                  ),
                  MetricCard(
                    label: 'Categories',
                    value: '${counts?.categories ?? 0}',
                    trend: 'Catalog groups',
                    icon: Icons.sell_outlined,
                    iconColor: AppColors.primary,
                  ),
                  MetricCard(
                    label: 'Low Stock',
                    value: '${counts?.lowStock ?? 0}',
                    trend: 'At or below reorder',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.warning,
                  ),
                  MetricCard(
                    label: 'Out of Stock',
                    value: '${counts?.outOfStock ?? 0}',
                    trend: 'Needs replenishment',
                    icon: Icons.cancel_outlined,
                    iconColor: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LowStockSection(items: _summary?.lowStockPreview ?? []),
              const SizedBox(height: 16),
              _RecentMovementsSection(
                movements: _summary?.recentMovements ?? [],
                isLoading: _isLoadingSummary,
              ),
            ],
            const SizedBox(height: 16),
            _RecentProductsSection(products: productProvider.products),
            if (productProvider.isLoading && productProvider.products.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: LoadingWidget()),
          ],
        ),
      );
  }
}

class _LowStockSection extends StatelessWidget {
  final List<LowStockItem> items;

  const _LowStockSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return ImsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LOW STOCK ALERT', style: AppTextStyles.sectionTitle),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No low stock items.', style: AppTextStyles.caption),
            )
          else
            ...items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderMuted, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(item.category, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.stockQuantity}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('/${item.reorderLevel}', style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RecentMovementsSection extends StatelessWidget {
  final List<StockMovementItem> movements;
  final bool isLoading;

  const _RecentMovementsSection({required this.movements, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ImsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT STOCK MOVEMENTS', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          if (isLoading)
            Text('Loading stock movements...', style: AppTextStyles.caption)
          else if (movements.isEmpty)
            Text('No stock movements recorded.', style: AppTextStyles.caption)
          else
            ...movements.take(5).map((movement) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgMain,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMuted),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movement.item,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movement.type,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${movement.qty} | By: ${movement.by}',
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RecentProductsSection extends StatelessWidget {
  final List<Product> products;

  const _RecentProductsSection({required this.products});

  @override
  Widget build(BuildContext context) {
    final recent = products.take(6).toList();

    return ImsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENTLY ADDED PRODUCTS', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No products found.', style: AppTextStyles.caption),
            )
          else
            ...recent.map((product) {
              return InkWell(
                onTap: () => Navigator.of(context).pushNamed('/product_detail', arguments: product.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.borderMuted, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                      Expanded(
                        child: Text(
                          product.category?.name ?? 'N/A',
                          style: AppTextStyles.caption.copyWith(fontSize: 12),
                        ),
                      ),
                      Text('${product.stockQuantity}', style: AppTextStyles.caption.copyWith(fontSize: 13)),
                      const SizedBox(width: 8),
                      Text(
                        '₱${product.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
