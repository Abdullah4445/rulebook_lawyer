import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
      onPrimary: isDarkTheme ? AppColors.primary : Colors.white,
      secondary: isDarkTheme ? AppColors.brandGold : AppColors.brandNavy,
      onSecondary: isDarkTheme ? AppColors.primary : Colors.white,
      surface: isDarkTheme ? AppColors.darkBackground : Colors.white,
      onSurface: isDarkTheme ? Colors.white : AppColors.primary,
      error: Colors.redAccent,
      onError: Colors.white,
    );
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      primarySwatch: Colors.amber,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDarkTheme ? AppColors.brandSurfaceDark : AppColors.brandSurface,
      primaryColor: scheme.primary,
      hintColor: isDarkTheme ? Colors.white38 : Colors.black38,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      cardColor: scheme.surface,
      dividerColor: isDarkTheme ? Colors.white12 : Colors.black12,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme,
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        colorScheme: Theme.of(context)
            .colorScheme
            .copyWith(primary: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
          side: BorderSide(
            color: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: scheme.onPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: isDarkTheme ? AppColors.darkContainerBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.cardShadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDarkTheme ? AppColors.darkContainerBorder : AppColors.containerBorder.withValues(alpha: 0.5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? AppColors.darkTextField : Colors.white,
        hintStyle: GoogleFonts.poppins(
          color: isDarkTheme ? Colors.white54 : AppColors.subTitleColor,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
      ),
    );
  }
}
