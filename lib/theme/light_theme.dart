import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';

const String _fontFamily = 'SF-Pro-Rounded-Regular';

ThemeData light({Color? primaryColor, Color? secondaryColor}) {
  final Color primary = primaryColor ?? AppPalette.primary;
  final Color secondary = secondaryColor ?? AppPalette.secondary;

  return ThemeData(
    fontFamily: _fontFamily,
    primaryColor: primary,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    hintColor: AppPalette.lightHint, // Border / hint colour
    splashColor: Colors.transparent,
    disabledColor: const Color(0xFFC3D3D5),
    dividerColor: const Color(0x1A0A6F6B),
    cardColor: AppPalette.lightGlass,
    canvasColor: const Color(0xFFF7FCFC),

    // Routes paint the pharmacy backdrop (see GlassPageTransitionsBuilder).
    scaffoldBackgroundColor: Colors.transparent,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPalette.lightInk), // Text colour primary
      bodyMedium: TextStyle(color: AppPalette.lightInk), // Text colour secondary
      bodySmall: TextStyle(color: AppPalette.lightHint), // Light grey
      titleMedium: TextStyle(color: AppPalette.lightInkSoft),
    ),

    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: AppPalette.warning, // Warning colour
      tertiaryContainer: const Color(0xFFBFE6F5),
      onTertiaryContainer: AppPalette.success, // Success colour
      onPrimary: Colors.white,
      surface: const Color(0xFFF3FBFA),
      onSecondary: AppPalette.accent,
      error: AppPalette.error, // Danger colour
      onSecondaryContainer: const Color(0xFFEFF9F8),
      outline: AppPalette.info, // Info colour
      onTertiary: AppPalette.lightTint,
      shadow: AppPalette.lightInkSoft,
      primaryContainer: const Color(0xFFBDF0E6),
      secondaryContainer: const Color(0xFFE4EEF0),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppPalette.lightInk,
      iconTheme: IconThemeData(color: AppPalette.lightInk),
    ),

    cardTheme: CardThemeData(
      color: AppPalette.lightGlass,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.lightGlassBorder),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFF7FCFC),
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x660A2A2E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFFF7FCFC),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .75),
      hintStyle: const TextStyle(color: AppPalette.lightHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x1F0A6F6B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x1F0A6F6B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.lightGlass,
      selectedColor: primary.withValues(alpha: .15),
      side: const BorderSide(color: Color(0x1F0A6F6B)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      indicatorColor: primary,
      unselectedLabelColor: AppPalette.lightInkSoft,
      dividerColor: Colors.transparent,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android:
          GlassPageTransitionsBuilder(CupertinoPageTransitionsBuilder()),
      TargetPlatform.iOS:
          GlassPageTransitionsBuilder(CupertinoPageTransitionsBuilder()),
      TargetPlatform.fuchsia:
          GlassPageTransitionsBuilder(FadeForwardsPageTransitionsBuilder()),
    }),
  );
}
