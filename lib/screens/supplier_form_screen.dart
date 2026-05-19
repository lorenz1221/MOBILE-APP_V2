import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/supplier_provider.dart';
import '../utils/constants.dart';
import '../utils/app_toast.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _contactController.text = widget.supplier!.contactPerson ?? '';
      _emailController.text = widget.supplier!.email ?? '';
      _phoneController.text = widget.supplier!.phone ?? '';
      _addressController.text = widget.supplier!.address ?? '';
      _isActive = widget.supplier!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final success = widget.supplier != null
        ? await supplierProvider.updateSupplier(
            widget.supplier!.id,
            _nameController.text.trim(),
            _contactController.text.trim(),
            _phoneController.text.trim(),
            _emailController.text.trim(),
            _addressController.text.trim(),
            _isActive,
          )
        : await supplierProvider.createSupplier(
            _nameController.text.trim(),
            _contactController.text.trim(),
            _phoneController.text.trim(),
            _emailController.text.trim(),
            _addressController.text.trim(),
            _isActive,
          );

    setState(() => _isLoading = false);

    if (success && mounted) {
      AppToast.success(
        context,
        widget.supplier != null ? 'Supplier updated successfully' : 'Supplier created successfully',
      );
      Navigator.of(context).pop(true);
    } else if (mounted && supplierProvider.error != null) {
      AppToast.error(context, supplierProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.supplier != null ? 'Edit Supplier' : 'New Supplier';
    return AppShell(
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
                  widget.supplier != null ? 'Update supplier details' : 'Register a new supplier',
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
                controller: _contactController,
                label: 'Contact Person',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.supplier != null ? 'Update Supplier' : 'Create Supplier',
                onPressed: _saveSupplier,
                isLoading: _isLoading,
                icon: widget.supplier != null ? Icons.save_outlined : Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
