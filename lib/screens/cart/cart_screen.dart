import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/order_summary.dart';
import 'widgets/empty_cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.myCart, style: AppTextStyles.h3),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: Text(
                'Clear',
                style: AppTextStyles.labelMd
                    .copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyCart(
              onBrowse: () => context.go(RouteNames.shop),
            )
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.screenPadding,
                        AppSizes.sm,
                        AppSizes.screenPadding,
                        AppSizes.md),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (_, i) =>
                        CartItemTile(item: cart.items[i]),
                  ),
                ),

                // Order summary + checkout
                _CheckoutPanel(cart: cart),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text(
            'All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  final CartProvider cart;

  const _CheckoutPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final orders = context.read<OrderProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.lg,
          AppSizes.screenPadding,
          AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrderSummaryWidget(
            subtotal:    cart.subtotal,
            deliveryFee: cart.deliveryFee,
            total:       cart.total,
          ),
          const SizedBox(height: AppSizes.lg),
          CustomButton(
            label: '${AppStrings.placeOrder}  •  '
                'LKR ${cart.total.toStringAsFixed(0)}',
            onPressed: () async {
              final ok = await orders.placeOrder(cart);
              if (!context.mounted) return;
              if (ok) {
                cart.clear();
                context.go(RouteNames.orders);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed successfully! 🎉'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            isLoading: orders.isLoading,
          ),
        ],
      ),
    );
  }
}
