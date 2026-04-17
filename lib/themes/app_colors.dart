import 'package:flutter/material.dart';

/// 🎨 Lawyer App Professional Color Palette
/// Premium legal services color scheme - Dark Blue, Gold, and Black
class AppColors {
  // Primary Legal Brand Colors
  static const Color primary = Color(0xFF0F172A); // Deep Navy Blue
  static const Color darkModePrimary = Color(0xFFC9A227); // Elegant Gold
  static const Color brandGold = Color(0xFFC9A227);
  static const Color brandGoldLight = Color(0xFFFFF9E6);
  static const Color brandNavy = Color(0xFF0F172A);
  static const Color brandSurface = Color(0xFFF8FAFC);
  static const Color brandSurfaceDark = Color(0xFF020617);

  // Accent Colors - Legal Theme
  static const Color accent1 = Color(0xFF1E40AF); // Professional Blue
  static const Color accent2 = Color(0xFFD97706); // Amber
  static const Color accent3 = Color(0xFF059669); // Emerald
  static const Color accent4 = Color(0xFF7C3AED); // Purple

  // Background Colors
  static const Color background = Color(0xffFFFFFF);
  static const Color darkBackground = Color(0xff020617);
  static const Color gradientStart = Color(0xFF0F172A);
  static const Color gradientEnd = Color(0xFF1E293B);

  // Drawer Colors
  static const Color drawerIcon = Color(0xFF94A3B8);
  static const Color drawerActive = Color(0xFF0F172A);
  static const Color drawerActiveDark = Color(0xFFC9A227);

  // Utility Colors
  static const Color lightGray = Color(0xffF1F5F9);
  static const Color ratingColour = Color(0xFFC9A227);
  static const Color dottedDivider = Color(0xff64748B);
  static const Color subTitleColor = Color(0xff64748B);
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF1E40AF);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Container Colors
  static const Color containerBackground = Color(0xFFFFFFFF);
  static const Color darkContainerBackground = Color(0xFF1E293B);
  static const Color containerBorder = Color(0xFFE2E8F0);
  static const Color darkContainerBorder = Color(0xFF334155);
  static const Color cardShadow = Color(0x14000000);

  // Slate Gray Scale (Professional Legal Theme)
  static const Color gray = Color(0xffF1F5F9);
  static const Color darkGray = Color(0xFF1E293B);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Additional Gray Colors (from previous config)
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Text Field Colors
  static const Color textField = Color(0xFFF8FAFC);
  static const Color textFieldBorder = Color(0xFFE2E8F0);
  static const Color darkTextField = Color(0xFF1E293B);
  static const Color darkTextFieldBorder = Color(0xFF334155);

  // Special Colors
  static const Color darkInvite = Color(0xff334155);
  static const Color darkService = Color(0xff1E293B);
  static const Color onBoarding = Color(0xffF1F5F9);

  // Service Category Colors (Legal Theme)
  static const Color serviceColor1 = Color(0xffFFF9E6); // Gold Tint
  static const Color serviceColor2 = Color(0xffEBF4FF); // Blue Tint
  static const Color serviceColor3 = Color(0xffF0FDF4); // Green Tint
  static const Color serviceColor4 = Color(0xffFAF5FF); // Purple Tint
  static const Color serviceColor5 = Color(0xffFFF7ED); // Amber Tint

  static const Color danger200 = Color(0xFFFF7277);

  // Gradient Colors (Legal Professional)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFC9A227)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
  );
}
