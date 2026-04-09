import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/text_styles.dart';
import 'custom_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const ErrorStateWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Text(
              AppStrings.error,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              message ?? AppStrings.errorSub,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.xl),
              CustomButton(
                label: AppStrings.retry,
                onPressed: onRetry,
                width: 160,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
