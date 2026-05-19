import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/app_toast.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final success = widget.category != null
        ? await categoryProvider.updateCategory(
            widget.category!.id,
            _nameController.text.trim(),
            _descriptionController.text.trim(),
          )
        : await categoryProvider.createCategory(
            _nameController.text.trim(),
            _descriptionController.text.trim(),
          );

    setState(() => _isLoading = false);

    if (success && mounted) {
      AppToast.success(
        context,
        widget.category != null ? 'Category updated successfully' : 'Category created successfully',
      );
      Navigator.of(context).pop(true);
    } else if (mounted && categoryProvider.error != null) {
      AppToast.error(context, categoryProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category != null ? 'Edit Category' : 'New Category';
    return AppShell(
      currentRoute: '/categories',
      showDrawer: false,
      title: title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ImsCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.category != null ? 'Update category information' : 'Add a new product category',
                  style: AppTextStyles.caption.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.category != null ? 'Update Category' : 'Create Category',
                onPressed: _saveCategory,
                isLoading: _isLoading,
                icon: widget.category != null ? Icons.save_outlined : Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
