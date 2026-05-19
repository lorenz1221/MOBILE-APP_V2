import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/constants.dart';

/// Search field shown below the main [AppBar] (or inline when expanded).
class SearchAppBarField extends StatefulWidget {
  final String hint;
  final String initialQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClear;

  const SearchAppBarField({
    super.key,
    this.hint = 'Search...',
    this.initialQuery = '',
    required this.onSearchChanged,
    this.onClear,
  });

  @override
  State<SearchAppBarField> createState() => _SearchAppBarFieldState();
}

class _SearchAppBarFieldState extends State<SearchAppBarField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.caption.copyWith(fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.bgMain,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderMuted),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderMuted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Expanding search icon in the AppBar actions — tap to show a full-width search field.
class ExpandingSearchAction extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onSearchChanged;

  const ExpandingSearchAction({
    super.key,
    this.hint = 'Search...',
    required this.onSearchChanged,
  });

  @override
  State<ExpandingSearchAction> createState() => _ExpandingSearchActionState();
}

class _ExpandingSearchActionState extends State<ExpandingSearchAction> {
  bool _expanded = false;
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) {
        _controller.clear();
        widget.onSearchChanged('');
      }
    });
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return IconButton(
        icon: const Icon(Icons.search_rounded, size: 22),
        tooltip: 'Search',
        onPressed: _toggle,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width - 120,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: AppColors.bgMain,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: _toggle),
        ],
      ),
    );
  }
}
