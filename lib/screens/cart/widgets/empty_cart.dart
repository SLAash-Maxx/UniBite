import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/custom_button.dart';

class EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;

  const EmptyCart({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart illustration
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 72)),
                  // Empty badge
                  Positioned(
                    top: 28,
                    right: 28,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            Text(
              AppStrings.emptyCart,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              AppStrings.emptyCartSub,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),

            CustomButton(
              label: AppStrings.browseMenu,
              onPressed: onBrowse,
            ),
          ],
        ),
      ),
    );
  }
}
