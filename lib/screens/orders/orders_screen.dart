import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/router/route_names.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_state_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.myOrders, style: AppTextStyles.h3),
      ),
      body: orders.isLoading
          ? const ShimmerListLoader()
          : orders.hasError
              ? ErrorStateWidget(onRetry: orders.loadOrders)
              : orders.orders.isEmpty
                  ? _EmptyOrders()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: orders.loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(
                            AppSizes.screenPadding),
                        itemCount: orders.orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.md),
                        itemBuilder: (_, i) => _OrderCard(
                          order: orders.orders[i],
                          onTap: () => context.push(
                            '/orders/${orders.orders[i].id}',
                          ),
                        ),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.placed:    return AppColors.info;
      case OrderStatus.preparing: return AppColors.warning;
      case OrderStatus.ready:     return AppColors.success;
      case OrderStatus.completed: return AppColors.textSecondary;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: AppTextStyles.labelLg,
                ),
                _StatusBadge(
                    label: order.status.label,
                    color: _statusColor),
              ],
            ),
            const SizedBox(height: AppSizes.sm),

            // Item names
            Text(
              order.items
                  .map((i) => '${i.foodItem.name} ×${i.quantity}')
                  .join(', '),
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.sm),

            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSizes.sm),

            // Date + total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      AppFormatters.formatDateTime(order.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                Text(
                  'LKR ${order.total.toStringAsFixed(0)}',
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style:
            AppTextStyles.labelSm.copyWith(color: color),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSizes.lg),
          Text(AppStrings.noOrders, style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Your order history will appear here.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
