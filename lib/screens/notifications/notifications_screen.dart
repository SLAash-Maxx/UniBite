import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    final notifications = _buildNotifications(orders);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.h3),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read',
                style:
                    AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔔', style: TextStyle(fontSize: 64)),
              const SizedBox(height: AppSizes.lg),
              Text('No notifications yet', style: AppTextStyles.h3),
              Text('Order updates will appear here.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (_, i) => _NotifTile(notif: notifications[i]),
            ),
    );
  }

 
          break;
        case OrderStatus.ready:
          list.add(_Notif(
              icon: '✅',
              title: 'Ready for Pickup!',
              body: 'Order $short is ready. Show your QR code at the canteen.',
              time: order.updatedAt ?? order.createdAt,
              color: AppColors.success));
          break;
        case OrderStatus.completed:
          list.add(_Notif(
              icon: '🎉',
              title: 'Order Completed',
              body: 'Order $short has been completed. Enjoy your meal!',
              time: order.updatedAt ?? order.createdAt,
              color: AppColors.success));
          break;
        case OrderStatus.cancelled:
          list.add(_Notif(
              icon: '❌',
              title: 'Order Cancelled',
              body: 'Order $short was cancelled. Amount refunded to wallet.',
              time: order.updatedAt ?? order.createdAt,
              color: AppColors.error));
          break;
      }
    }
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }
}

class _Notif {
  final String icon, title, body;
  final DateTime time;
  final Color color;
  const _Notif(
      {required this.icon,
      required this.title,
      required this.body,
      required this.time,
      required this.color});
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: notif.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Center(
              child: Text(notif.icon, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notif.title, style: AppTextStyles.labelLg),
          const SizedBox(height: 2),
          Text(notif.body,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_timeAgo(notif.time), style: AppTextStyles.caption),
        ])),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
