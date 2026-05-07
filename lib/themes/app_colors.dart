import 'package:flutter/material.dart';

/// Lawyer App — Premium Legal Color System
/// Light mode: pure-white surfaces with warm cream scaffold and rich gold accents.
/// Dark mode: deep ink-black with vivid antique-gold accents.
class AppColors {
  // ───────────────────────────────────────────────────
  // BRAND CORE
  // ───────────────────────────────────────────────────
  /// Primary ink (text + dark UI elements in light mode)
  static const Color primary = Color(0xFF0B1120);

  /// In dark mode, primary swaps to gold
  static const Color darkModePrimary = Color(0xFFD4AF37);

  /// Signature antique gold — used as the hero accent on every screen
  static const Color brandGold = Color(0xFFC9A227);
  static const Color brandGoldLight = Color(0xFFFFF6D9);
  static const Color brandGoldDeep = Color(0xFF8C6E0F);
  static const Color brandGoldGlow = Color(0x33C9A227); // 20% gold for glows

  /// Deep brand navy (used for headers, ink text)
  static const Color brandNavy = Color(0xFF0B1120);
  static const Color brandNavyDeep = Color(0xFF050810);

  // ───────────────────────────────────────────────────
  // SURFACES — Light mode (predominantly white)
  // ───────────────────────────────────────────────────
  /// Scaffold background — almost-white with the tiniest warm tint
  static const Color brandSurface = Color(0xFFFDFCF7);
  /// Pure white card / dialog / sheet surface
  static const Color containerBackground = Color(0xFFFFFFFF);
  /// Very soft cream — used for hover/highlight zones in light mode
  static const Color surfaceTint = Color(0xFFFAF5E6);
  /// Subtle hairline divider in light mode
  static const Color containerBorder = Color(0xFFEAE8E1);

  // ───────────────────────────────────────────────────
  // SURFACES — Dark mode (predominantly black)
  // ───────────────────────────────────────────────────
  /// Deep ink scaffold — almost black with a hint of midnight blue
  static const Color brandSurfaceDark = Color(0xFF06080F);
  /// Card / elevated surface in dark mode
  static const Color darkContainerBackground = Color(0xFF111726);
  /// Slightly elevated dark surface for nested content
  static const Color darkSurfaceElevated = Color(0xFF1A2236);
  /// Hairline divider in dark mode
  static const Color darkContainerBorder = Color(0xFF1F2A40);

  static const Color background = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF06080F);

  // ───────────────────────────────────────────────────
  // GRADIENT STOPS (used by ui surfaces)
  // ───────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF0B1120);
  static const Color gradientEnd = Color(0xFF1A2236);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1120), Color(0xFF1A2236)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6C04F), Color(0xFFC9A227), Color(0xFF8C6E0F)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient lightSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFDFCF7)],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1120), Color(0xFF06080F)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
  );

  // ───────────────────────────────────────────────────
  // ACCENTS (kept consistent with existing usage)
  // ───────────────────────────────────────────────────
  static const Color accent1 = Color(0xFF1E40AF); // Royal blue
  static const Color accent2 = Color(0xFFD97706); // Amber
  static const Color accent3 = Color(0xFF059669); // Emerald
  static const Color accent4 = Color(0xFF7C3AED); // Purple

  // ───────────────────────────────────────────────────
  // DRAWER
  // ───────────────────────────────────────────────────
  static const Color drawerIcon = Color(0xFF94A3B8);
  static const Color drawerActive = Color(0xFF0B1120);
  static const Color drawerActiveDark = Color(0xFFD4AF37);

  // ───────────────────────────────────────────────────
  // SEMANTIC / UTILITY
  // ───────────────────────────────────────────────────
  static const Color lightGray = Color(0xFFF4F1E8);
  static const Color ratingColour = Color(0xFFC9A227);
  static const Color dottedDivider = Color(0xFFCBD5E1);
  static const Color subTitleColor = Color(0xFF64748B);

  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF1E40AF);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color cardShadow = Color(0x14000000);

  // ───────────────────────────────────────────────────
  // SLATE GRAY SCALE
  // ───────────────────────────────────────────────────
  static const Color gray = Color(0xFFF1F5F9);
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

  // Aliased grey* names retained for backwards compat
  static const Color grey50 = gray50;
  static const Color grey100 = gray100;
  static const Color grey200 = gray200;
  static const Color grey300 = gray300;
  static const Color grey400 = gray400;
  static const Color grey500 = gray500;
  static const Color grey600 = gray600;
  static const Color grey700 = gray700;
  static const Color grey800 = gray800;
  static const Color grey900 = gray900;

  // ───────────────────────────────────────────────────
  // TEXT FIELDS
  // ───────────────────────────────────────────────────
  static const Color textField = Color(0xFFFAF7EE);
  static const Color textFieldBorder = Color(0xFFEAE8E1);
  static const Color darkTextField = Color(0xFF111726);
  static const Color darkTextFieldBorder = Color(0xFF1F2A40);

  // ───────────────────────────────────────────────────
  // SPECIAL
  // ───────────────────────────────────────────────────
  static const Color darkInvite = Color(0xFF1A2236);
  static const Color darkService = Color(0xFF111726);
  static const Color onBoarding = Color(0xFFFDFCF7);

  // Service category tint colors (legal theme)
  static const Color serviceColor1 = Color(0xFFFFF6D9); // Gold tint
  static const Color serviceColor2 = Color(0xFFE7EEFE); // Royal blue tint
  static const Color serviceColor3 = Color(0xFFD7F5E5); // Emerald tint
  static const Color serviceColor4 = Color(0xFFEDE0FF); // Royal purple tint
  static const Color serviceColor5 = Color(0xFFFFEAD0); // Warm amber tint

  static const Color danger200 = Color(0xFFFF7277);
}
