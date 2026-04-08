import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';

enum SortOption { popular, priceLow, priceHigh, newest }

extension SortOptionX on SortOption {
  String get label {
    switch (this) {
      case SortOption.popular:   return AppStrings.sortPopular;
      case SortOption.priceLow:  return AppStrings.sortPriceLow;
      case SortOption.priceHigh: return AppStrings.sortPriceHigh;
      case SortOption.newest:    return AppStrings.sortNewest;
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.popular:   return Icons.local_fire_department_outlined;
      case SortOption.priceLow:  return Icons.arrow_downward_rounded;
      case SortOption.priceHigh: return Icons.arrow_upward_rounded;
      case SortOption.newest:    return Icons.new_releases_outlined;
    }
  }
}

class SortBottomSheet extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onSelect;

  const SortBottomSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding, AppSizes.lg,
          AppSizes.screenPadding, AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          Text(AppStrings.sortBy, style: AppTextStyles.h3),
          const SizedBox(height: AppSizes.md),

          ...SortOption.values.map((opt) => _SortTile(
                option: opt,
                isSelected: opt == current,
                onTap: () => onSelect(opt),
              )),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final SortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: AppSizes.iconSm),
            const SizedBox(width: AppSizes.md),
            Text(
              option.label,
              style: AppTextStyles.labelLg.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: AppSizes.iconSm),
          ],
        ),
      ),
    );
  }
}
