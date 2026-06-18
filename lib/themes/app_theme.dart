import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// RoolBook Lawyer theme — Professional Lawyer Workspace.
///
/// Material 3 ColorScheme-driven. Use this everywhere instead of hard-coded
/// hex colours, `Colors.white`, etc. so that:
///   * Light <-> dark switches automatically.
///   * Re-theming the brand later means changing **one** file.
///   * `Theme.of(context).colorScheme.*` is the only colour API screens
///     need to know about.
///
/// Brand palette (Charcoal + Refined Gold — focused workspace feel):
///   * Primary    — Charcoal     #111827
///   * Secondary  — Slate-700    #374151
///   * Accent     — Refined Gold #C9A227
///   * Background — Gray-50      #F9FAFB
///   * Cards      — Pure White
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────
  // Brand seed colours — RoolBook Lawyer
  // ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF111827); // Charcoal Gray-900
  static const Color primaryDark = Color(0xFF030712); // Gray-950
  static const Color primaryLight = Color(0xFFE5E7EB); // Gray-200 tint
  static const Color secondary = Color(0xFF374151); // Slate Gray-700
  static const Color accent = Color(0xFFC9A227); // Refined Gold
  static const Color accentDark = Color(0xFF9C7E1B);
  static const Color accentLight = Color(0xFFEEDD9C);
  // Aliases kept so existing screens that reference `secondary` for the
  // accent during migration keep their visual gold semantics.
  static const Color secondaryDark = accentDark;
  static const Color secondaryLight = accentLight;

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFE0A800);
  static const Color danger = Color(0xFFDC2626);

  // Neutral surfaces — light theme (gallery-white workspace)
  static const Color lightScaffold = Color(0xFFF9FAFB); // Gray-50
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White cards
  static const Color lightOnSurface = Color(0xFF111827); // Charcoal text
  static const Color lightSubtle = Color(0xFF6B7280); // Gray-500
  static const Color lightBorder = Color(0xFFE5E7EB); // Gray-200

  // Neutral surfaces — dark theme (premium night workspace)
  static const Color darkScaffold = Color(0xFF030712); // Gray-950
  static const Color darkSurface = Color(0xFF111827); // Charcoal cards
  static const Color darkSurfaceHigh = Color(0xFF1F2937); // Gray-800
  static const Color darkOnSurface = Color(0xFFF9FAFB); // Gray-50
  static const Color darkSubtle = Color(0xFF9CA3AF); // Gray-400
  static const Color darkBorder = Color(0xFF374151); // Gray-700

  // ─────────────────────────────────────────────────────────
  // Gradients (premium feel — hero cards, CTAs, splash)
  // ─────────────────────────────────────────────────────────
  /// Charcoal gradient — primary CTAs, headers, splash background.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF374151), Color(0xFF111827), Color(0xFF030712)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Refined Gold gradient — verified badges, premium accents, CTAs.
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEDD9C), Color(0xFFC9A227), Color(0xFF9C7E1B)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Alias for the gold gradient — semantically clearer at call sites.
  static const LinearGradient accentGradient = secondaryGradient;

  // ─────────────────────────────────────────────────────────
  // Shape / motion tokens
  // ─────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 18;
  static const double radiusXl = 24;
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMed = Duration(milliseconds: 260);
  static const Duration motionSlow = Duration(milliseconds: 400);

  // ─────────────────────────────────────────────────────────
  // PUBLIC: themes
  // ─────────────────────────────────────────────────────────
  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? secondary : primaryLight,
      onPrimaryContainer: isDark ? Colors.white : primary,
      // M3 maps `secondary` to "accent" semantics — use gold so all
      // surface theming (buttons, badges, highlights) picks up brand gold.
      secondary: accent,
      onSecondary: const Color(0xFF1A1208),
      secondaryContainer: isDark ? accentDark : accentLight,
      onSecondaryContainer: const Color(0xFF1A1208),
      tertiary: secondary, // Slate Gray-700 — for darker container surfaces
      onTertiary: Colors.white,
      error: danger,
      onError: Colors.white,
      surface: isDark ? darkSurface : lightSurface,
      onSurface: isDark ? darkOnSurface : lightOnSurface,
      surfaceContainerHighest:
          isDark ? darkSurfaceHigh : const Color(0xFFF1F5F9),
      onSurfaceVariant: isDark ? darkSubtle : lightSubtle,
      outline: isDark ? darkBorder : lightBorder,
      outlineVariant: isDark
          ? darkBorder.withValues(alpha: 0.5)
          : lightBorder.withValues(alpha: 0.5),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: isDark ? lightSurface : darkSurface,
      onInverseSurface: isDark ? lightOnSurface : darkOnSurface,
      inversePrimary: isDark ? primaryLight : primaryDark,
    );

    final textTheme = _buildTextTheme(colorScheme);

    return base.copyWith(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkScaffold : lightScaffold,
      canvasColor: colorScheme.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary),
      dividerColor: colorScheme.outline,
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        space: 1,
        thickness: 0.6,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: colorScheme.outline, width: 0.6),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.3),
          minimumSize: const Size.fromHeight(48),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceHigh : const Color(0xFFF7F9FB),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle:
            textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.secondary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: colorScheme.secondary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
      ),
      splashColor: colorScheme.secondary.withValues(alpha: 0.06),
      highlightColor: colorScheme.secondary.withValues(alpha: 0.04),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme c) {
    final h = GoogleFonts.poppinsTextTheme();
    final b = GoogleFonts.interTextTheme();
    return TextTheme(
      displayLarge: h.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: c.onSurface,
      ),
      displayMedium: h.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      displaySmall: h.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      headlineLarge: h.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      headlineMedium: h.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      headlineSmall: h.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      titleLarge: h.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: c.onSurface,
      ),
      titleMedium: h.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: c.onSurface,
      ),
      titleSmall: h.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: c.onSurface,
      ),
      bodyLarge: b.bodyLarge?.copyWith(color: c.onSurface, height: 1.5),
      bodyMedium: b.bodyMedium?.copyWith(color: c.onSurface, height: 1.5),
      bodySmall:
          b.bodySmall?.copyWith(color: c.onSurfaceVariant, height: 1.45),
      labelLarge: b.labelLarge?.copyWith(
        color: c.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelMedium: b.labelMedium?.copyWith(color: c.onSurfaceVariant),
      labelSmall: b.labelSmall?.copyWith(color: c.onSurfaceVariant),
    );
  }
}
