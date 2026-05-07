import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
      onPrimary: isDarkTheme ? AppColors.brandNavy : Colors.white,
      secondary: AppColors.brandGold,
      onSecondary: AppColors.brandNavy,
      surface: isDarkTheme
          ? AppColors.darkContainerBackground
          : AppColors.containerBackground,
      onSurface: isDarkTheme ? Colors.white : AppColors.brandNavy,
      surfaceContainerHighest: isDarkTheme
          ? AppColors.darkSurfaceElevated
          : AppColors.surfaceTint,
      error: AppColors.error,
      onError: Colors.white,
      outline: isDarkTheme
          ? AppColors.darkContainerBorder
          : AppColors.containerBorder,
    );

    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDarkTheme ? AppColors.brandSurfaceDark : AppColors.brandSurface,
      primaryColor: scheme.primary,
      hintColor: isDarkTheme ? AppColors.gray500 : AppColors.gray500,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      cardColor: scheme.surface,
      dividerColor:
          isDarkTheme ? AppColors.darkContainerBorder : AppColors.containerBorder,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.55),
      ),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isDarkTheme
            ? AppColors.brandSurfaceDark
            : AppColors.containerBackground,
        foregroundColor: isDarkTheme ? Colors.white : AppColors.brandNavy,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkTheme ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              isDarkTheme ? Brightness.dark : Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
          size: 22,
        ),
        actionsIconTheme: IconThemeData(
          color: isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
          size: 22,
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? Colors.white : AppColors.brandNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
          foregroundColor:
              isDarkTheme ? AppColors.brandNavy : Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shadowColor: AppColors.brandGold.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.brandGold.withOpacity(0.18);
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor:
              isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
          side: BorderSide(
            color: isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.brandSurfaceDark
            : AppColors.containerBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: isDarkTheme
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(isDarkTheme ? 0.4 : 0.06),
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDarkTheme
                ? AppColors.darkContainerBorder
                : AppColors.containerBorder,
            width: 1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDarkTheme ? AppColors.darkTextField : AppColors.textField,
        hintStyle: GoogleFonts.poppins(
          color: isDarkTheme ? AppColors.gray400 : AppColors.gray500,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          color: isDarkTheme ? AppColors.gray300 : AppColors.gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _border(isDarkTheme, AppColors.containerBorder),
        enabledBorder: _border(
          isDarkTheme,
          isDarkTheme
              ? AppColors.darkTextFieldBorder
              : AppColors.textFieldBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.brandGold,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        selectedColor:
            isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
        iconColor: isDarkTheme ? AppColors.gray300 : AppColors.gray700,
        textColor: isDarkTheme ? Colors.white : AppColors.brandNavy,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.brandSurfaceDark
            : AppColors.containerBackground,
        selectedItemColor:
            isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
        unselectedItemColor:
            isDarkTheme ? AppColors.gray500 : AppColors.gray400,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.brandSurfaceDark
            : AppColors.containerBackground,
        indicatorColor: AppColors.brandGold.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? (isDarkTheme ? AppColors.brandGold : AppColors.brandNavy)
                : (isDarkTheme ? AppColors.gray400 : AppColors.gray500),
          );
        }),
        height: 68,
        elevation: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandGold,
        foregroundColor: AppColors.brandNavy,
        elevation: 6,
        focusElevation: 8,
        highlightElevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.darkSurfaceElevated
            : AppColors.surfaceTint,
        selectedColor: AppColors.brandGold,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkTheme ? Colors.white : AppColors.brandNavy,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: isDarkTheme
              ? AppColors.darkContainerBorder
              : AppColors.containerBorder,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? Colors.white : AppColors.brandNavy,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? AppColors.gray300 : AppColors.gray700,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDarkTheme
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: isDarkTheme
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.brandGold,
        linearTrackColor: isDarkTheme
            ? AppColors.darkContainerBorder
            : AppColors.containerBorder,
        circularTrackColor: isDarkTheme
            ? AppColors.darkContainerBorder
            : AppColors.containerBorder,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDarkTheme ? AppColors.gray800 : AppColors.brandNavy,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.brandGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
        unselectedLabelColor:
            isDarkTheme ? AppColors.gray500 : AppColors.gray400,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.brandGold, width: 2.5),
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandGold;
          }
          return isDarkTheme ? AppColors.gray500 : AppColors.gray300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandGold.withOpacity(0.4);
          }
          return isDarkTheme ? AppColors.gray800 : AppColors.gray200;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandGold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.brandNavy),
        side: BorderSide(
          color: isDarkTheme ? AppColors.gray500 : AppColors.gray400,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandGold;
          }
          return isDarkTheme ? AppColors.gray500 : AppColors.gray400;
        }),
      ),
    );
  }

  static OutlineInputBorder _border(bool isDarkTheme, Color borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1),
    );
  }
}
