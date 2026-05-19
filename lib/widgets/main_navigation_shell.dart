import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/supplier_list_screen.dart';
import '../utils/constants.dart';
import 'app_brand.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  final GlobalKey<ProductListScreenState> _productsKey = GlobalKey();

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Products'),
    _NavItem(icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping, label: 'Suppliers'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _navItems.length - 1);
  }

  Widget? _buildFab(AuthProvider auth) {
    switch (_currentIndex) {
      case 0:
        if (auth.isAdmin || auth.isStaff) {
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed('/add_product'),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Product', style: TextStyle(color: Colors.white)),
          );
        }
        return null;
      case 1:
        if (auth.isAdmin || auth.isStaff) {
          return FloatingActionButton.extended(
            onPressed: () => _productsKey.currentState?.openAddForm(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Product', style: TextStyle(color: Colors.white)),
          );
        }
        return null;
      case 2:
        return FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed('/supplier_form'),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Supplier', style: TextStyle(color: Colors.white)),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final showAppBar = _currentIndex != 3;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppColors.bgLight.withValues(alpha: 0.95),
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.borderMuted),
              ),
              title: _currentIndex == 0
                  ? const AppBrand(compact: true)
                  : Text(
                      _navItems[_currentIndex].label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'System Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
                if (auth.user != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          auth.user!.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.user!.email,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardScreen(),
          ProductListScreen(key: _productsKey),
          const SupplierListScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _buildFab(auth),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          border: Border(top: BorderSide(color: AppColors.borderMuted.withValues(alpha: 0.8))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final selected = _currentIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_currentIndex != index) setState(() => _currentIndex = index);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 22,
                            color: selected ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
