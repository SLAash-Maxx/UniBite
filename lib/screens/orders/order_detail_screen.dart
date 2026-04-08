import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/wallet_provider.dart';
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
      appBar: AppBar(title: Text(AppStrings.orderDetails, style: AppTextStyles.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // FIX #17 — QR code shown when ready or completed
          if (order.status == OrderStatus.ready || order.status == OrderStatus.completed)
            _QrSection(order: order),

          // Status tracker
          _StatusTracker(status: order.status),
          const SizedBox(height: AppSizes.xl),

          // FIX #1 — Cancel button in detail screen too
          if (order.status == OrderStatus.placed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.lg),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context, order),
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          _SectionCard(child: Column(children: [
            _DetailRow(label: 'Order ID', value: '#${order.id.substring(0, 8).toUpperCase()}'),
            const Divider(color: AppColors.divider),
            _DetailRow(label: 'Date', value: AppFormatters.formatDateTime(order.createdAt)),
            const Divider(color: AppColors.divider),
            _DetailRow(label: 'Status', value: order.status.label, valueColor: _statusColor(order.status)),
          ])),
          const SizedBox(height: AppSizes.md),

          Text('Items', style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.sm),
          _SectionCard(child: Column(children: order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            child: Row(children: [
              Text('${item.quantity}×', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: Text(item.foodItem.name, style: AppTextStyles.bodyMd)),
              Text(AppFormatters.formatPriceShort(item.subtotal), style: AppTextStyles.labelLg),
            ]),
          )).toList())),
          const SizedBox(height: AppSizes.md),

          Text(AppStrings.orderSummary, style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.sm),
          _SectionCard(child: OrderSummaryWidget(
            subtotal: order.subtotal, deliveryFee: order.deliveryFee, total: order.total,
          )),
        ]),
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

  void _confirmCancel(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Amount will be refunded to your wallet.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Keep')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final orders = context.read<OrderProvider>();
              orders.wallet = context.read<WalletProvider>();
              Navigator.of(dialogContext).pop();
              await orders.cancelOrder(order.id);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// FIX #17 — QR code widget
class _QrSection extends StatelessWidget {
  final OrderModel order;
  const _QrSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final qrData = 'UNIBITE:${order.id}:${order.canteenId}:${order.total}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.success, width: 1.5),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 6),
          Text(
            order.status == OrderStatus.ready ? 'Ready for Pickup!' : 'Order Completed',
            style: AppTextStyles.h4.copyWith(color: AppColors.success),
          ),
        ]),
        const SizedBox(height: AppSizes.md),
        Text('Show this QR code at the canteen to collect your order',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.lg),
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: QrImageView(data: qrData, version: QrVersions.auto, size: 180),
        ),
        const SizedBox(height: AppSizes.sm),
        Text('Order #${order.id.substring(0, 8).toUpperCase()}',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _StatusTracker extends StatelessWidget {
  final OrderStatus status;
  const _StatusTracker({required this.status});

  static const _steps = [OrderStatus.placed, OrderStatus.preparing, OrderStatus.ready, OrderStatus.completed];

  int get _currentIndex {
    if (status == OrderStatus.cancelled) return -1;
    return _steps.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        child: Row(children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          Text('This order was cancelled.', style: AppTextStyles.labelLg.copyWith(color: AppColors.error)),
        ]),
      );
    }
    return Row(children: List.generate(_steps.length * 2 - 1, (i) {
      if (i.isOdd) {
        final isActive = (i ~/ 2) < _currentIndex;
        return Expanded(child: Container(height: 3, color: isActive ? AppColors.primary : AppColors.border));
      }
      final idx      = i ~/ 2;
      final isDone   = idx <= _currentIndex;
      final isCurrent= idx == _currentIndex;
      return Column(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: isDone ? AppColors.primary : AppColors.border, shape: BoxShape.circle),
          child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(height: 4),
        Text(_steps[idx].label,
            style: AppTextStyles.caption.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textSecondary),
            textAlign: TextAlign.center),
      ]);
    }));
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
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

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
      Text(value, style: AppTextStyles.labelLg.copyWith(color: valueColor)),
    ]),
  );
}
