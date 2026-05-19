import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../screens/add_edit_product_screen.dart';
import '../../screens/category_form_screen.dart';
import '../../screens/category_list_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/supplier_form_screen.dart';
import '../../widgets/main_navigation_shell.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const products = '/products';
  static const suppliers = '/suppliers';
  static const profile = '/profile';
  static const categories = '/categories';
  static const addProduct = '/add_product';
  static const productDetail = '/product_detail';
  static const editProduct = '/edit_product';
  static const categoryForm = '/category_form';
  static const supplierForm = '/supplier_form';
}

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const MainNavigationShell(),
        AppRoutes.products: (context) => const MainNavigationShell(initialIndex: 1),
        AppRoutes.suppliers: (context) => const MainNavigationShell(initialIndex: 2),
        AppRoutes.profile: (context) => const MainNavigationShell(initialIndex: 3),
        AppRoutes.categories: (context) => const CategoryListScreen(),
        AppRoutes.addProduct: (context) => const AddEditProductScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.productDetail:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: productId),
        );
      case AppRoutes.editProduct:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (context) => AddEditProductScreen(product: product),
        );
      case AppRoutes.categoryForm:
        final category = settings.arguments as Category?;
        return MaterialPageRoute(
          builder: (context) => CategoryFormScreen(category: category),
        );
      case AppRoutes.supplierForm:
        final supplier = settings.arguments as Supplier?;
        return MaterialPageRoute(
          builder: (context) => SupplierFormScreen(supplier: supplier),
        );
      default:
        return null;
    }
  }
}
