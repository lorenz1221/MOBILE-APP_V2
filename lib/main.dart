import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/supplier_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/add_edit_product_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/product_list_screen.dart';
import 'models/product.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.example');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
      ],
      child: MaterialApp(
        title: 'Inventory MS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            surface: const Color(0xFFFDFEFE),
          ),
          scaffoldBackgroundColor: const Color(0xFFE8EDF5),
          fontFamily: 'Segoe UI',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFDFEFE),
            foregroundColor: Color(0xFF1A2340),
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFFFDFEFE),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFD8DEE9)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFFDFEFE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/products': (context) => const ProductListScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/categories': (context) => const CategoryListScreen(),
          '/suppliers': (context) => const SupplierListScreen(),
          '/add_product': (context) => const AddEditProductScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product_detail') {
            final productId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: productId),
            );
          } else if (settings.name == '/edit_product') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => AddEditProductScreen(product: product),
            );
          } else if (settings.name == '/category_form') {
            final category = settings.arguments as Category?;
            return MaterialPageRoute(
              builder: (context) => CategoryFormScreen(category: category),
            );
          } else if (settings.name == '/supplier_form') {
            final supplier = settings.arguments as Supplier?;
            return MaterialPageRoute(
              builder: (context) => SupplierFormScreen(supplier: supplier),
            );
          }
          return null;
        },
      ),
    );
  }
}

