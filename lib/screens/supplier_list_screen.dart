import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/supplier_provider.dart';
import '../core/constants/constants.dart';
import '../widgets/app_shell.dart' show ImsCard;
import '../widgets/common_widgets.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_app_bar.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final ScrollController _scrollController = ScrollController();
  final _infiniteScroll = InfiniteScrollMixin();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _hasInitialized = true;
        context.read<SupplierProvider>().fetchSuppliers(refresh: true);
      }
    });
    _infiniteScroll.attachInfiniteScroll(
      controller: _scrollController,
      onLoadMore: () => context.read<SupplierProvider>().fetchSuppliers(),
    );
  }

  @override
  void dispose() {
    _infiniteScroll.detachInfiniteScroll();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm([Supplier? supplier]) async {
    final result = await Navigator.of(context).pushNamed('/supplier_form', arguments: supplier);
    if (result == true && mounted) {
      context.read<SupplierProvider>().fetchSuppliers(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();

    return Column(
      children: [
        SearchAppBarField(
          hint: 'Search suppliers...',
          initialQuery: provider.searchQuery,
          onSearchChanged: (q) => provider.search(q),
          onClear: () => provider.search(''),
        ),
        Container(height: 1, color: AppColors.borderMuted),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.fetchSuppliers(refresh: true),
            child: _buildList(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildList(SupplierProvider provider) {
    if (provider.isInitialLoading) {
      return ListView(children: const [SizedBox(height: 200, child: LoadingWidget())]);
    }

    if (provider.error != null && provider.suppliers.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: CustomErrorWidget(
              message: provider.error!,
              onRetry: () => provider.fetchSuppliers(refresh: true),
            ),
          ),
        ],
      );
    }

    if (provider.suppliers.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty ? 'No matching suppliers' : 'No suppliers yet',
                  style: AppTextStyles.headline.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('Tap + to add a supplier', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.suppliers.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.suppliers.length) {
          return PaginationListLoader(
            isLoadingMore: provider.isLoadingMore,
            hasMore: provider.hasMore,
          );
        }

        final supplier = provider.suppliers[index];
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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.info, size: 22),
              ),
              title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text(
                supplier.contactPerson ?? supplier.email ?? 'No contact info',
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: supplier.isActive
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.textMuted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  supplier.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: supplier.isActive ? AppColors.success : AppColors.textMuted,
                  ),
                ),
              ),
              onTap: () => _openForm(supplier),
            ),
          ),
        );
      },
    );
  }
}
