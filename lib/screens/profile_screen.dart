import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return AppShell(
      currentRoute: '/profile',
      title: 'Profile',
      body: user == null
          ? const Center(child: Text('No user data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImsCard(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(user.name, style: AppTextStyles.headline.copyWith(fontSize: 22)),
                        const SizedBox(height: 8),
                        Chip(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          label: Text(
                            user.role.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ImsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Account Details',
                          style: AppTextStyles.headline.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(label: 'Email', value: user.email),
                        if (user.phone != null) _ProfileInfoRow(label: 'Phone', value: user.phone!),
                        if (user.address != null) _ProfileInfoRow(label: 'Address', value: user.address!),
                        _ProfileInfoRow(label: 'Status', value: user.isActive ? 'Active' : 'Inactive'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text('$label:', style: AppTextStyles.caption),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
