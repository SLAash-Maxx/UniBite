import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/formatters.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderSummaryWidget({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Row(
          label: AppStrings.subtotal,
          value: AppFormatters.formatPriceShort(subtotal),
        ),
        const SizedBox(height: AppSizes.sm),
        _Row(
          label: AppStrings.deliveryFee,
          value: deliveryFee == 0
              ? AppStrings.free
              : AppFormatters.formatPriceShort(deliveryFee),
          valueColor: deliveryFee == 0
              ? AppColors.success
              : AppColors.textPrimary,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Divider(color: AppColors.divider),
        ),
        _Row(
          label: AppStrings.total,
          value: AppFormatters.formatPriceShort(total),
          labelStyle: AppTextStyles.h4,
          valueStyle: AppTextStyles.price,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: (valueStyle ?? AppTextStyles.labelLg).copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
