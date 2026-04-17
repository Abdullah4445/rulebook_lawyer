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
      primarySwatch: Colors.blue,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDarkTheme ? AppColors.brandSurfaceDark : AppColors.brandSurface,
      primaryColor: scheme.primary,
      hintColor: isDarkTheme ? Colors.white38 : AppColors.gray500,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      cardColor: scheme.surface,
      dividerColor: isDarkTheme ? AppColors.gray700 : AppColors.gray200,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme,

      // 🎨 Enhanced AppBar Theme - Professional Legal Look
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        foregroundColor: isDarkTheme ? Colors.white : AppColors.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkTheme ? Brightness.dark : Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? Colors.white : AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // 🎨 Enhanced Button Themes - Premium Legal Design
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary,
        colorScheme: Theme.of(context)
            .colorScheme
            .copyWith(primary: isDarkTheme ? AppColors.darkModePrimary : AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
          foregroundColor: isDarkTheme ? AppColors.primary : Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shadowColor: (isDarkTheme ? AppColors.brandGold : AppColors.primary).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.1);
              }
              return null;
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
          side: BorderSide(
            color: isDarkTheme ? AppColors.brandGold : AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 🎨 Enhanced Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),

      // 🎨 Enhanced Card Theme - Premium Legal Cards
      cardTheme: CardThemeData(
        color: isDarkTheme ? AppColors.darkContainerBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.08),
        elevation: 2,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDarkTheme
              ? AppColors.darkContainerBorder.withOpacity(0.3)
              : AppColors.containerBorder.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),

      // 🎨 Enhanced Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme ? AppColors.darkTextField : AppColors.gray50,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkTheme ? AppColors.brandGold : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),

      // 🎨 Enhanced List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        iconColor: isDarkTheme ? AppColors.gray400 : AppColors.gray600,
        textColor: isDarkTheme ? Colors.white : AppColors.primary,
      ),

      // 🎨 Enhanced Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        selectedItemColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        unselectedItemColor: isDarkTheme ? AppColors.gray500 : AppColors.gray400,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 🎨 Enhanced Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        foregroundColor: isDarkTheme ? AppColors.primary : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 🎨 Enhanced Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkGray : AppColors.gray100,
        selectedColor: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 🎨 Enhanced Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkContainerBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? Colors.white : AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: isDarkTheme ? AppColors.gray300 : AppColors.gray700,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // 🎨 Enhanced Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: isDarkTheme ? AppColors.darkBackground : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),

      // 🎨 Enhanced Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDarkTheme ? AppColors.brandGold : AppColors.primary,
        linearTrackColor: isDarkTheme ? AppColors.gray700 : AppColors.gray200,
        circularTrackColor: isDarkTheme ? AppColors.gray700 : AppColors.gray200,
      ),

      // 🎨 Enhanced Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDarkTheme ? AppColors.gray800 : AppColors.gray900,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
}
