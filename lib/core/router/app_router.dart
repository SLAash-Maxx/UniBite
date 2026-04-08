import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/shop/shop_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/food_detail/food_detail_screen.dart';
import '../../screens/canteen/canteen_detail_screen.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();
  static final _rootKey  = GlobalKey<NavigatorState>();
  static final _shellKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash,   builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: RouteNames.orderDetail,
        builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id'] ?? '')),
      GoRoute(path: RouteNames.foodDetail,
        builder: (_, s) => FoodDetailScreen(foodId: s.pathParameters['id'] ?? '')),
      GoRoute(path: RouteNames.canteenDetail,
        builder: (_, s) => CanteenDetailScreen(canteenId: s.pathParameters['id'] ?? '')),
      GoRoute(path: RouteNames.wallet,        builder: (_, __) => const WalletScreen()),
      GoRoute(path: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: RouteNames.home,    builder: (_, __) => const HomeScreen()),
          GoRoute(path: RouteNames.shop,    builder: (_, __) => const ShopScreen()),
          GoRoute(path: RouteNames.cart,    builder: (_, __) => const CartScreen()),
          GoRoute(path: RouteNames.orders,  builder: (_, __) => const OrdersScreen()),
          GoRoute(path: RouteNames.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
