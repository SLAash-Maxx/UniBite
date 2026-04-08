import 'dart:async';
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

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Timer? _etaTimer;

  @override
  void initState() {
    super.initState();
    // Rebuild every 30 seconds so ETA countdown ticks
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _etaTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final order = orders.findById(widget.orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          AppBar(title: Text(AppStrings.orderDetails, style: AppTextStyles.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (order.status != OrderStatus.cancelled) _QrSection(order: order),
          _StatusTracker(status: order.status),
          const SizedBox(height: AppSizes.md),
          if (order.status == OrderStatus.placed ||
              order.status == OrderStatus.preparing)
            _EtaBanner(order: order),
          if (order.status == OrderStatus.placed)
            Padding(
              padding:
                  const EdgeInsets.only(top: AppSizes.md, bottom: AppSizes.sm),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context, order),
                  icon:
                      const Icon(Icons.cancel_outlined, color: AppColors.error),
                  label: const Text('Cancel Order',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),
          _SectionCard(
              child: Column(children: [
            _DetailRow(
                label: 'Order ID',
                value: '#${order.id.substring(0, 8).toUpperCase()}'),
            const Divider(color: AppColors.divider),
            _DetailRow(
                label: 'Date',
                value: AppFormatters.formatDateTime(order.createdAt)),
            const Divider(color: AppColors.divider),
            _DetailRow(
                label: 'Status',
                value: order.status.label,
                valueColor: _statusColor(order.status)),
          ])),
          const SizedBox(height: AppSizes.md),
          Text('Items', style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.sm),
          _SectionCard(
            child: Column(
              children: order.items
                  .map((item) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        child: Row(children: [
                          Text('${item.quantity}×',
                              style: AppTextStyles.labelLg
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                              child: Text(item.foodItem.name,
                                  style: AppTextStyles.bodyMd)),
                          Text(AppFormatters.formatPriceShort(item.subtotal),
                              style: AppTextStyles.labelLg),
                        ]),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(AppStrings.orderSummary, style: AppTextStyles.h4),
          const SizedBox(height: AppSizes.sm),
          _SectionCard(
            child: OrderSummaryWidget(
              subtotal: order.subtotal,
              deliveryFee: order.deliveryFee,
              total: order.total,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ]),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.warning;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.completed:
        return AppColors.textSecondary;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  void _confirmCancel(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Amount will be refunded to your wallet.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Keep')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final op = context.read<OrderProvider>();
              op.wallet = context.read<WalletProvider>();
              Navigator.of(dialogCtx).pop();
              await op.cancelOrder(order.id);
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

class _EtaBanner extends StatelessWidget {
  final OrderModel order;
  const _EtaBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final eta = order.etaMinutesRemaining;
    final isReady = eta == 0 && order.status == OrderStatus.preparing;
    final color = isReady ? AppColors.success : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        // Animated clock icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isReady ? Icons.check_circle_outline_rounded : Icons.timer_outlined,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isReady
                ? 'Almost ready!'
                : order.status == OrderStatus.placed
                    ? 'Waiting to start preparing'
                    : 'Estimated time: ~$eta min',
            style: AppTextStyles.labelLg.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            isReady
                ? 'Your order should be ready very soon'
                : order.status == OrderStatus.placed
                    ? 'The canteen will start preparing shortly'
                    : _progressText(order),
            style: AppTextStyles.bodySm.copyWith(color: color.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressValue(order),
              backgroundColor: color.withOpacity(0.15),
              color: color,
              minHeight: 5,
            ),
          ),
        ])),
      ]),
    );
  }

  double _progressValue(OrderModel order) {
    if (order.status == OrderStatus.placed) return 0.05;
    final prep = order.prepTimeMinutes ?? order._estimatePrepTime();
    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;
    final pct = elapsed / prep;
    return pct.clamp(0.05, 1.0);
  }

  String _progressText(OrderModel order) {
    final prep = order.prepTimeMinutes ?? order._estimatePrepTime();
    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;
    return 'Started $elapsed min ago · $prep min total';
  }
}

class _QrSection extends StatelessWidget {
  final OrderModel order;
  const _QrSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final qrData = 'UNIBITE:${order.id}:${order.canteenId}:${order.total}';

    final isActive = order.status == OrderStatus.placed ||
        order.status == OrderStatus.preparing ||
        order.status == OrderStatus.ready;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
            color: isActive ? AppColors.primary : AppColors.success,
            width: 1.5),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isActive ? Icons.qr_code_rounded : Icons.check_circle_rounded,
              color: isActive ? AppColors.primary : AppColors.success,
              size: 20),
          const SizedBox(width: 6),
          Text(
            order.status == OrderStatus.completed
                ? 'Order Collected ✓'
                : 'Your pickup QR Code',
            style: AppTextStyles.h4.copyWith(
                color: isActive ? AppColors.primary : AppColors.success),
          ),
        ]),
        const SizedBox(height: AppSizes.sm),
        Text(
          order.status == OrderStatus.completed
              ? 'Your order has been collected'
              : 'Show this QR code to the staff to collect your order',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (isActive) ...[
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                QrImageView(data: qrData, version: QrVersions.auto, size: 180),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Order #${order.id.substring(0, 8).toUpperCase()}',
            style:
                AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              '⚠️  Valid for one scan only',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ]),
    );
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

  int get _currentIndex {
    if (status == OrderStatus.cancelled) return -1;
    return _steps.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(children: [
          const Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          Text('This order was cancelled.',
              style: AppTextStyles.labelLg.copyWith(color: AppColors.error)),
        ]),
      );
    }

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isActive = (i ~/ 2) < _currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isActive ? AppColors.primary : AppColors.border,
            ),
          );
        }
        final idx = i ~/ 2;
        final isDone = idx <= _currentIndex;
        final isCurrent = idx == _currentIndex;
        return Column(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : AppColors.border,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: AppColors.primary, width: 2.5)
                  : null,
            ),
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            _steps[idx].label,
            style: AppTextStyles.caption.copyWith(
              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ]);
      }),
    );
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
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.labelLg.copyWith(color: valueColor)),
        ]),
      );
}

extension _OrderModelEta on OrderModel {
  int _estimatePrepTime() {
    final n = totalItems;
    if (n <= 1) return 8;
    if (n <= 3) return 12;
    if (n <= 5) return 18;
    return 25;
  }
}
