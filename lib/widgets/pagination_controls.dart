import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Option A: classic Previous / Next footer with page indicator.
class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoading;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoading = false,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = currentPage > 1 && !isLoading;
    final canGoForward = currentPage < lastPage && !isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border(top: BorderSide(color: AppColors.borderMuted.withValues(alpha: 0.8))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: canGoBack ? AppColors.primary : AppColors.bgMain,
                foregroundColor: canGoBack ? Colors.white : AppColors.textMuted,
              ),
              onPressed: canGoBack ? onPrevious : null,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous page',
            ),
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              Text(
                'Page $currentPage of $lastPage · $total items',
                style: AppTextStyles.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: canGoForward ? AppColors.primary : AppColors.bgMain,
                foregroundColor: canGoForward ? Colors.white : AppColors.textMuted,
              ),
              onPressed: canGoForward ? onNext : null,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next page',
            ),
          ],
        ),
      ),
    );
  }
}

/// Option B: subtle loader shown at the bottom while fetching the next page.
class PaginationListLoader extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const PaginationListLoader({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'End of list',
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}

/// Attach to a [ScrollController] to trigger [onLoadMore] near the bottom.
class InfiniteScrollMixin {
  ScrollController? _controller;
  VoidCallback? _onLoadMore;
  bool _isAttached = false;

  void attachInfiniteScroll({
    required ScrollController controller,
    required VoidCallback onLoadMore,
    double threshold = 200,
  }) {
    if (_isAttached && _controller == controller) return;
    detachInfiniteScroll();
    _controller = controller;
    _onLoadMore = onLoadMore;
    _isAttached = true;

    controller.addListener(() {
      if (!controller.hasClients) return;
      final max = controller.position.maxScrollExtent;
      if (controller.position.pixels >= max - threshold) {
        _onLoadMore?.call();
      }
    });
  }

  void detachInfiniteScroll() {
    _isAttached = false;
    _controller = null;
    _onLoadMore = null;
  }
}
