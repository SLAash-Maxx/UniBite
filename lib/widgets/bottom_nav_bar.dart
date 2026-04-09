import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/router/route_names.dart';
import '../providers/cart_provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(RouteNames.shop))    return 1;
    if (location.startsWith(RouteNames.cart))    return 2;
    if (location.startsWith(RouteNames.orders))  return 3;
    if (location.startsWith(RouteNames.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(RouteNames.home);    break;
      case 1: context.go(RouteNames.shop);    break;
      case 2: context.go(RouteNames.cart);    break;
      case 3: context.go(RouteNames.orders);  break;
      case 4: context.go(RouteNames.profile); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location  = GoRouterState.of(context).matchedLocation;
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _locationToIndex(location),
          onTap: (i) => _onTap(context, i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: AppStrings.navShop,
            ),
            BottomNavigationBarItem(
              icon: _CartIcon(count: cartCount, isActive: false),
              activeIcon: _CartIcon(count: cartCount, isActive: true),
              label: AppStrings.navCart,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: AppStrings.navOrders,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int  count;
  final bool isActive;
  const _CartIcon({required this.count, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Icon(isActive ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined),
      if (count > 0)
        Positioned(
          top: -6, right: -8,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: AppColors.badge, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ]);
  }
}
