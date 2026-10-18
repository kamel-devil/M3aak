import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';

ThemeData dark = ThemeData(
  fontFamily: 'SF-Pro-Rounded-Regular',
  primaryColor: AppPalette.primaryLight,
  brightness: Brightness.dark,
  highlightColor: const Color(0xFF0E2328),
  hintColor: AppPalette.darkHint,
  cardColor: AppPalette.darkGlass,
  canvasColor: const Color(0xFF0B1E23),
  disabledColor: const Color(0xFF2C4447),
  dividerColor: const Color(0x1FFFFFFF),
  splashColor: Colors.transparent,

  // Routes paint the pharmacy backdrop (see GlassPageTransitionsBuilder).
  scaffoldBackgroundColor: Colors.transparent,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppPalette.darkInk), // Text colour primary
    bodyMedium: TextStyle(color: AppPalette.darkInk), // Text colour secondary
    bodySmall: TextStyle(color: AppPalette.darkInkSoft), // Light grey
    titleMedium: TextStyle(color: AppPalette.darkInkSoft),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppPalette.primaryLight,
    secondary: AppPalette.info,
    tertiary: AppPalette.warning, // Warning colour
    tertiaryContainer: Color(0xFF3A5A66),
    surface: Color(0xFF10262B),
    onPrimary: Color(0xFF04201E),
    onTertiaryContainer: AppPalette.success, // Success colour
    primaryContainer: Color(0xFF0E5A52),
    onSecondaryContainer: Color(0x912A2A2A),
    outline: AppPalette.info, // Info colour
    onTertiary: AppPalette.darkTint,
    secondaryContainer: Color(0xFF1C3438),
    surfaceContainer: AppPalette.accent,
    onSecondary: AppPalette.accent,
    error: AppPalette.error, // Danger colour
    shadow: Color(0xFFE6F4F2),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    foregroundColor: AppPalette.darkInk,
    iconTheme: IconThemeData(color: AppPalette.darkInk),
  ),

  cardTheme: CardThemeData(
    color: AppPalette.darkGlass,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppPalette.darkGlassBorder),
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF0D2126),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF0D2126),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: .06),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppPalette.darkGlassBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppPalette.darkGlassBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppPalette.primaryLight, width: 1.4),
    ),
  ),

  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: AppPalette.primaryLight),
  tabBarTheme: const TabBarThemeData(
    labelColor: AppPalette.primaryLight,
    indicatorColor: AppPalette.primaryLight,
    unselectedLabelColor: AppPalette.darkInkSoft,
    dividerColor: Colors.transparent,
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
