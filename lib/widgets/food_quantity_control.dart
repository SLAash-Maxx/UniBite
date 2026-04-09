import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/text_styles.dart';

enum ControlSize { small, medium }

class FoodQuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ControlSize size;

  const FoodQuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.size = ControlSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = size == ControlSize.small;
    final btnSize = isSmall ? 24.0 : 32.0;
    final iconSize = isSmall ? 14.0 : 18.0;
    final fontSize = isSmall ? 12.0 : 14.0;
    final spacing = isSmall ? 6.0 : 10.0;
    final radius = isSmall ? AppSizes.radiusSm : AppSizes.radiusMd;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement
        _ControlBtn(
          icon: Icons.remove,
          onTap: onDecrement,
          size: btnSize,
          iconSize: iconSize,
          radius: radius,
          filled: false,
        ),
        SizedBox(width: spacing),

        Text(
          '$quantity',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: spacing),

        _ControlBtn(
          icon: Icons.add,
          onTap: onIncrement,
          size: btnSize,
          iconSize: iconSize,
          radius: radius,
          filled: true,
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final double radius;
  final bool filled;

  const _ControlBtn({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.radius,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: filled ? AppColors.textOnPrimary : AppColors.primary,
        ),
      ),
    );
  }
}
