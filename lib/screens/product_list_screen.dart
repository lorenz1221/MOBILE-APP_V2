import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../core/constants/constants.dart';
import '../widgets/app_shell.dart' show ImsCard;
import '../widgets/common_widgets.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_app_bar.dart';

/// Products list with AppBar search + infinite scroll (Option B).
/// Set [useFooterPagination] to true for Previous/Next buttons (Option A).
class ProductListScreen extends StatefulWidget {
  /// When true, uses [PaginationFooter] instead of infinite scroll.
  final bool useFooterPagination;

  const ProductListScreen({super.key, this.useFooterPagination = false});

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final _infiniteScroll = InfiniteScrollMixin();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _hasInitialized = true;
        _loadInitial();
      }
    });

    if (!widget.useFooterPagination) {
      _infiniteScroll.attachInfiniteScroll(
        controller: _scrollController,
        onLoadMore: _loadMore,
      );
    }
  }

  @override
  void dispose() {
    _infiniteScroll.detachInfiniteScroll();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitial() {
    final provider = context.read<ProductProvider>();
    provider.fetchProducts(refresh: true);
  }

  void _loadMore() {
    context.read<ProductProvider>().fetchProducts();
  }

  void _onSearch(String query) {
    context.read<ProductProvider>().search(query);
  }

  Future<void> openAddForm() => _openForm();

  Future<void> _openForm([Product? product]) async {
    if (product != null) {
      await Navigator.of(context).pushNamed('/edit_product', arguments: product);
    } else {
      await Navigator.of(context).pushNamed('/add_product');
    }
    if (mounted) _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProductProvider>();
    final canEdit = auth.isAdmin || auth.isStaff;

    return Column(
      children: [
        SearchAppBarField(
          hint: 'Search by name, SKU...',
          initialQuery: provider.searchQuery,
          onSearchChanged: _onSearch,
          onClear: () => _onSearch(''),
        ),
        Container(height: 1, color: AppColors.borderMuted),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.fetchProducts(refresh: true),
            child: _buildBody(provider, canEdit),
          ),
        ),
        if (widget.useFooterPagination)
          PaginationFooter(
            currentPage: provider.displayPage,
            lastPage: provider.lastPage,
            total: provider.total,
            isLoading: provider.isLoading,
            onPrevious: provider.goToPreviousPage,
            onNext: provider.goToNextPage,
          ),
      ],
    );
  }

  Widget _buildBody(ProductProvider provider, bool canEdit) {
    if (provider.isInitialLoading) {
      return ListView(children: const [SizedBox(height: 200, child: LoadingWidget())]);
    }

    if (provider.error != null && provider.products.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: CustomErrorWidget(
              message: provider.error!,
              onRetry: _loadInitial,
            ),
          ),
        ],
      );
    }

    if (provider.products.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty ? 'No matching products' : 'No products yet',
                  style: AppTextStyles.headline.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Tap + to add your first product',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final itemCount = provider.products.length + (widget.useFooterPagination ? 0 : 1);

    return ListView.builder(
      controller: widget.useFooterPagination ? null : _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (!widget.useFooterPagination && index == provider.products.length) {
          return PaginationListLoader(
            isLoadingMore: provider.isLoadingMore,
            hasMore: provider.hasMore,
          );
        }

        final product = provider.products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ImsCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text(
                '${product.sku ?? '—'} · ${product.category?.name ?? 'Uncategorized'} · Stock: ${product.stockQuantity}',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
              trailing: Text(
                '₱${product.sellingPrice?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
              ),
              onTap: () => Navigator.of(context).pushNamed('/product_detail', arguments: product.id),
            ),
          ),
        );
      },
    );
  }
}
