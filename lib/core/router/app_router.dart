import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/pos/presentation/pages/pos_dashboard_page.dart';
import '../../features/printer/presentation/pages/printer_page.dart';
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/transaction/presentation/pages/transaction_history_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),

    GoRoute(
      path: '/pos',
      builder: (context, state) => const PosDashboardPage(),
    ),

    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),

    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentPage(),
    ),

    GoRoute(
      path: '/transactions',
      builder: (context, state) =>
          const TransactionHistoryPage(),
    ),

    // ==========================
    // Inventory Module
    // ==========================

    GoRoute(
      path: '/inventory',
      builder: (context, state) =>
          const InventoryPage(),
    ),

    GoRoute(
      path: '/products',
      builder: (context, state) =>
          const ProductPage(),
    ),

    // ==========================
    // Utilities
    // ==========================

    GoRoute(
      path: '/printer',
      builder: (context, state) =>
          const PrinterPage(),
    ),
  ],
);