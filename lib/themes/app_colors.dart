import 'package:flutter/material.dart';

/// Lawyer App — Premium Legal Color System
/// Light mode: pure-white surfaces with warm cream scaffold and rich gold accents.
/// Dark mode: deep ink-black with vivid antique-gold accents.
class AppColors {
  // ───────────────────────────────────────────────────
  // BRAND CORE
  // ───────────────────────────────────────────────────
  /// Primary ink (text + dark UI elements in light mode)
  static const Color primary = Color(0xFF002147);

  /// In dark mode, primary swaps to gold
  static const Color darkModePrimary = Color(0xFFC5A059);

  /// Signature muted gold — legal-authority accent (per design spec).
  static const Color brandGold = Color(0xFFC5A059);
  static const Color brandGoldLight = Color(0xFFE8DCC0);
  static const Color brandGoldDeep = Color(0xFF8F7440);
  static const Color brandGoldGlow = Color(0x33C5A059); // 20% gold for glows

  /// Deep brand navy — per "Rulebook" design spec.
  static const Color brandNavy = Color(0xFF002147);
  static const Color brandNavyDeep = Color(0xFF001638);

  // ───────────────────────────────────────────────────
  // SURFACES — Light mode (clean white + subtle grey-blue)
  // ───────────────────────────────────────────────────
  /// Scaffold background — soft light grey/white per spec (#F4F7F9).
  static const Color brandSurface = Color(0xFFF4F7F9);
  /// Pure white card / dialog / sheet surface
  static const Color containerBackground = Color(0xFFFFFFFF);
  /// Soft tint for hover/highlight zones — pale gold tone.
  static const Color surfaceTint = Color(0xFFF1EADB);
  /// Subtle hairline divider — cool grey-blue.
  static const Color containerBorder = Color(0xFFE2E6EC);

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
  static const Color gradientStart = Color(0xFF002147);
  static const Color gradientEnd = Color(0xFF001638);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF002147), Color(0xFF001638)],
  );

  /// Premium gold gradient — muted authentic gold instead of bright yellow.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8C291), Color(0xFFC5A059), Color(0xFF8F7440)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient lightSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F7F9)],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF002147), Color(0xFF001638)],
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
  static const Color drawerActive = Color(0xFF002147);
  static const Color drawerActiveDark = Color(0xFFC5A059);

  // ───────────────────────────────────────────────────
  // SEMANTIC / UTILITY
  // ───────────────────────────────────────────────────
  static const Color lightGray = Color(0xFFEDEFF3);
  static const Color ratingColour = Color(0xFFC5A059);
  static const Color dottedDivider = Color(0xFFCBD5E1);
  static const Color subTitleColor = Color(0xFF64748B);

  /// Body text per spec — charcoal grey (#333333).
  static const Color bodyText = Color(0xFF333333);
  /// Explicit success / "case won" / "payment received" green per spec.
  static const Color successAction = Color(0xFF28A745);

  static const Color success = Color(0xFF28A745);
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
  static const Color textField = Color(0xFFF7F9FB);
  static const Color textFieldBorder = Color(0xFFE2E6EC);
  static const Color darkTextField = Color(0xFF111726);
  static const Color darkTextFieldBorder = Color(0xFF1F2A40);

  // ───────────────────────────────────────────────────
  // SPECIAL
  // ───────────────────────────────────────────────────
  static const Color darkInvite = Color(0xFF1A2236);
  static const Color darkService = Color(0xFF111726);
  static const Color onBoarding = Color(0xFFF4F7F9);

  // Service category tint colors (legal theme)
  static const Color serviceColor1 = Color(0xFFE8DCC0); // Muted gold tint
  static const Color serviceColor2 = Color(0xFFE7EEFE); // Royal blue tint
  static const Color serviceColor3 = Color(0xFFD7F5E5); // Emerald tint
  static const Color serviceColor4 = Color(0xFFEDE0FF); // Royal purple tint
  static const Color serviceColor5 = Color(0xFFFFEAD0); // Warm amber tint

  static const Color danger200 = Color(0xFFFF7277);
}
