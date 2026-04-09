import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading  = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: bg, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _child(bg),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _child(AppColors.textOnPrimary),
            ),
    );
  }

  Widget _child(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor:
              AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(label,
              style:
                  AppTextStyles.button.copyWith(color: textColor)),
        ],
      );
    }
    return Text(label,
        style: AppTextStyles.button.copyWith(color: textColor));
  }
}
