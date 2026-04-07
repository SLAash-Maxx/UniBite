import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

class SearchNotFound extends StatelessWidget {
  final String query;

  const SearchNotFound({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Text(
              AppStrings.noResults,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),

            Text(
              query.isNotEmpty
                  ? 'No results for "$query".\nTry a different keyword.'
                  : AppStrings.noResultsSub,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
