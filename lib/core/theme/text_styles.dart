import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Poppins';

  // Display
  static const TextStyle displayLg = TextStyle(
    fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static const TextStyle displayMd = TextStyle(
    fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );

  // Body
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  // Labels
  static const TextStyle labelLg = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, height: 1.4,
  );

  // Price
  static const TextStyle price = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.primary, height: 1.2,
  );
  static const TextStyle priceSm = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.primary, height: 1.2,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary, height: 1.2, letterSpacing: 0.3,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textHint, height: 1.4,
  );
}
