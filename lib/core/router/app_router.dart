import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/pos/presentation/pages/pos_dashboard_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';

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
      builder: (context, state) =>
          const PaymentPage(),
    ),
  ],
);