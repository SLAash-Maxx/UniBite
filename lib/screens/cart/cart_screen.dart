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
import '../../providers/wallet_provider.dart';
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
              // FIX #18 — wrapped in Builder so context is below Scaffold
              onPressed: () => _confirmClear(context, cart),
              child: Text('Clear', style: AppTextStyles.labelMd.copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyCart(onBrowse: () => context.go(RouteNames.shop))
          : Column(children: [
              // Canteen tag
              if (cart.canteenName != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding, vertical: AppSizes.sm),
                  color: AppColors.primarySoft,
                  child: Row(children: [
                    const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text('From: ${cart.canteenName}',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  ]),
                ),

              Expanded(
                child: ListView.separated(
                  // FIX #18 — key ensures Dismissible doesn't reuse stale keys after clear
                  key: ValueKey(cart.items.length),
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.screenPadding, AppSizes.sm,
                      AppSizes.screenPadding, AppSizes.md),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (_, i) {
                    // Guard: if index out of bounds after clear, return empty
                    if (i >= cart.items.length) return const SizedBox.shrink();
                    return CartItemTile(item: cart.items[i]);
                  },
                ),
              ),
              _CheckoutPanel(cart: cart),
            ]),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // FIX #18 — pop dialog FIRST, then clear to avoid Dismissible key conflict
              WidgetsBinding.instance.addPostFrameCallback((_) => cart.clear());
            },
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
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
    final orders = context.watch<OrderProvider>();
    final wallet = context.watch<WalletProvider>();
    final hasEnough = wallet.balance >= cart.total;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding, AppSizes.lg,
          AppSizes.screenPadding, AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Wallet balance row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text('Wallet Balance', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          ]),
          Text('LKR ${wallet.balance.toStringAsFixed(2)}',
              style: AppTextStyles.labelLg.copyWith(
                  color: hasEnough ? AppColors.success : AppColors.error)),
        ]),
        if (!hasEnough)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Insufficient balance. Please top up your wallet.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ),
        const Divider(height: AppSizes.lg),
        OrderSummaryWidget(subtotal: cart.subtotal, deliveryFee: cart.deliveryFee, total: cart.total),
        const SizedBox(height: AppSizes.lg),

        if (orders.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(orders.error!,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                textAlign: TextAlign.center),
          ),

        CustomButton(
          label: hasEnough
              ? '${AppStrings.placeOrder}  •  LKR ${cart.total.toStringAsFixed(0)}'
              : 'Top Up Wallet to Order',
          onPressed: hasEnough
              ? () async {
                  final ok = await orders.placeOrder(cart);
                  if (!context.mounted) return;
                  if (ok) {
                    cart.clear();
                    context.go(RouteNames.orders);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Order placed successfully! 🎉'),
                      backgroundColor: AppColors.success,
                    ));
                  }
                }
              : () => context.push(RouteNames.wallet),
          isLoading: orders.isLoading,
          color: hasEnough ? AppColors.primary : AppColors.warning,
        ),
      ]),
    );
  }
}
