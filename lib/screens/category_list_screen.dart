import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../core/constants/constants.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_app_bar.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final ScrollController _scrollController = ScrollController();
  final _infiniteScroll = InfiniteScrollMixin();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized && mounted) {
        _hasInitialized = true;
        context.read<CategoryProvider>().fetchCategories(refresh: true);
      }
    });
    _infiniteScroll.attachInfiniteScroll(
      controller: _scrollController,
      onLoadMore: () => context.read<CategoryProvider>().fetchCategories(),
    );
  }

  @override
  void dispose() {
    _infiniteScroll.detachInfiniteScroll();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm([Category? category]) async {
    final result = await Navigator.of(context).pushNamed('/category_form', arguments: category);
    if (result == true && mounted) {
      context.read<CategoryProvider>().fetchCategories(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return AppShell(
      title: 'Categories',
      body: Column(
        children: [
          SearchAppBarField(
            hint: 'Search categories...',
            initialQuery: provider.searchQuery,
            onSearchChanged: (q) => provider.search(q),
            onClear: () => provider.search(''),
          ),
          Container(height: 1, color: AppColors.borderMuted),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.fetchCategories(refresh: true),
              child: _buildList(provider),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildList(CategoryProvider provider) {
    if (provider.isInitialLoading) {
      return ListView(children: const [SizedBox(height: 200, child: LoadingWidget())]);
    }

    if (provider.error != null && provider.categories.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: CustomErrorWidget(
              message: provider.error!,
              onRetry: () => provider.fetchCategories(refresh: true),
            ),
          ),
        ],
      );
    }

    if (provider.categories.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 56, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty ? 'No matching categories' : 'No categories yet',
                  style: AppTextStyles.headline.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('Tap + to create your first category', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.categories.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.categories.length) {
          return PaginationListLoader(
            isLoadingMore: provider.isLoadingMore,
            hasMore: provider.hasMore,
          );
        }

        final category = provider.categories[index];
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
                child: const Icon(Icons.sell_outlined, color: AppColors.primary, size: 22),
              ),
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: category.description != null && category.description!.isNotEmpty
                  ? Text(category.description!, style: AppTextStyles.caption.copyWith(fontSize: 13))
                  : null,
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: () => _openForm(category),
            ),
          ),
        );
      },
    );
  }
}
