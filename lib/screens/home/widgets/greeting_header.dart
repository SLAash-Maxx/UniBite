import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/user_model.dart';

class GreetingHeader extends StatelessWidget {
  final UserModel? user;
  final double walletBalance;
  const GreetingHeader({super.key, this.user, this.walletBalance = 0});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.goodMorning;
    if (h < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: AppSizes.avatarMd, height: AppSizes.avatarMd,
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        child: Center(child: Text(user?.firstName.substring(0,1).toUpperCase() ?? 'U',
            style: AppTextStyles.h3.copyWith(color: AppColors.primary))),
      ),
      const SizedBox(width: AppSizes.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$_greeting 👋', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(user?.firstName ?? 'Student', style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      GestureDetector(
        onTap: () => context.push(RouteNames.notifications),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            width: AppSizes.avatarMd, height: AppSizes.avatarMd,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: AppSizes.iconMd),
          ),
          Positioned(top: 8, right: 10, child: Container(width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
        ]),
      ),
    ]);
  }
}
