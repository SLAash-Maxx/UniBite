import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../cart/widgets/order_summary.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final order  = orders.findById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.orderDetails, style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tracker
            _StatusTracker(status: order.status),
            const SizedBox(height: AppSizes.xl),

            // Order ID + date
            _SectionCard(
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Order ID',
                    value: '#${order.id.substring(0, 8).toUpperCase()}',
                  ),
                  const Divider(color: AppColors.divider),
                  _DetailRow(
                    label: 'Date',
                    value: AppFormatters.formatDateTime(order.createdAt),
                  ),
                  const Divider(color: AppColors.divider),
                  _DetailRow(
                    label: 'Status',
                    value: order.status.label,
                    valueColor: _statusColor(order.status),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Items
            Text('Items', style: AppTextStyles.h4),
            const SizedBox(height: AppSizes.sm),
            _SectionCard(
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Row(
                      children: [
                        Text('${item.quantity}×',
                            style: AppTextStyles.labelLg
                                .copyWith(color: AppColors.primary)),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(item.foodItem.name,
                              style: AppTextStyles.bodyMd),
                        ),
                        Text(
                          AppFormatters.formatPriceShort(item.subtotal),
                          style: AppTextStyles.labelLg,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Payment summary
            Text(AppStrings.orderSummary, style: AppTextStyles.h4),
            const SizedBox(height: AppSizes.sm),
            _SectionCard(
              child: OrderSummaryWidget(
                subtotal:    order.subtotal,
                deliveryFee: order.deliveryFee,
                total:       order.total,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:    return AppColors.info;
      case OrderStatus.preparing: return AppColors.warning;
      case OrderStatus.ready:     return AppColors.success;
      case OrderStatus.completed: return AppColors.textSecondary;
      case OrderStatus.cancelled: return AppColors.error;
    }
  }
}

class _StatusTracker extends StatelessWidget {
  final OrderStatus status;

  const _StatusTracker({required this.status});

  static const _steps = [
    OrderStatus.placed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  int get _currentIndex => _steps.indexOf(status);

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: AppSizes.sm),
            Text('This order was cancelled.',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.error)),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isActive = stepIndex < _currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isActive ? AppColors.primary : AppColors.border,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone    = stepIndex <= _currentIndex;
        return _StepDot(
          label: _steps[stepIndex].label,
          isDone: isDone,
          isCurrent: stepIndex == _currentIndex,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepDot(
      {required this.label, required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.labelLg
                  .copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
