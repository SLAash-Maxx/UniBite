import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🌿 Primary — keep as is
  static const Color primary       = Color(0xFF3CB54C);

  // Variants of primary (FIXED)
  static const Color primaryLight  = Color(0xFF6EDC7A); // lighter green
  static const Color primaryDark   = Color(0xFF2E8F3A); // deeper green
  static const Color primarySoft   = Color(0xFFE8F7EC); // soft background tint

  // 🌑 Secondary — dark green instead of navy
  static const Color secondary     = Color(0xFF1B3A2B); // deep forest green
  static const Color secondaryLight= Color(0xFF2F5D46);

  // 🧾 Background
  static const Color background    = Color(0xFFF6FBF7); // slight green tint
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceGrey   = Color(0xFFF0F5F2);

  // ✍️ Text (neutral but slightly green-friendly)
  static const Color textPrimary   = Color(0xFF1B3A2B);
  static const Color textSecondary = Color(0xFF5F7A6B);
  static const Color textHint      = Color(0xFFA0B3A7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ✅ Status (adjusted to match green theme)
  static const Color success       = Color(0xFF22C55E);
  static const Color successSoft   = Color(0xFFDCFCE7);

  static const Color warning       = Color(0xFFEAB308); // softer yellow
  static const Color warningSoft   = Color(0xFFFEF9C3);

  static const Color error         = Color(0xFFEF4444);
  static const Color errorSoft     = Color(0xFFFEE2E2);

  static const Color info          = Color(0xFF0EA5E9);
  static const Color infoSoft      = Color(0xFFE0F2FE);

  // 📏 Border & divider
  static const Color border        = Color(0xFFDDE7E1);
  static const Color divider       = Color(0xFFEEF3F0);

  // 🌫 Shadow
  static const Color shadow        = Color(0x14000000);

  // 📱 Bottom nav (FIXED from orange → green)
  static const Color navActive     = Color(0xFF3CB54C);
  static const Color navInactive   = Color(0xFFA0B3A7);

  // 🏷 Chips
  static const Color chipSelected  = Color(0xFF3CB54C);
  static const Color chipUnselected= Color(0xFFF0F5F2);

  // 🔔 Badge
  static const Color badge         = Color(0xFF3CB54C);
}