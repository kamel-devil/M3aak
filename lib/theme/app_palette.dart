import 'package:flutter/material.dart';

/// Pharmacy design tokens: a calm medical teal/mint palette with a frosted
/// glass surface system. Every themed colour in the app derives from here.
class AppPalette {
  AppPalette._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0E9F8E); // pharmacy teal
  static const Color primaryDeep = Color(0xFF0A6F6B); // deep teal
  static const Color primaryLight = Color(0xFF5FD8C6); // mint
  static const Color secondary = Color(0xFF2F8FEA); // clinical blue
  static const Color accent = Color(0xFFFF7A6B); // coral (offers / sale)

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1FB57A);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFEF4E64);
  static const Color info = Color(0xFF3B9BF5);

  // ── Light surfaces ───────────────────────────────────────────────────────
  static const Color lightInk = Color(0xFF0F2A2E);
  static const Color lightInkSoft = Color(0xFF4F6B70);
  static const Color lightHint = Color(0xFF8FA5AA);
  static const Color lightBgTop = Color(0xFFE6FAF5);
  static const Color lightBgMid = Color(0xFFF2FAFB);
  static const Color lightBgBottom = Color(0xFFEAF3FC);
  static const Color lightGlass = Color(0xD9FFFFFF); // 85% white
  static const Color lightGlassBorder = Color(0xB3FFFFFF);
  static const Color lightTint = Color(0xFFE3F6F2); // soft teal tint

  // ── Dark surfaces ────────────────────────────────────────────────────────
  static const Color darkInk = Color(0xFFE6F4F2);
  static const Color darkInkSoft = Color(0xFFA9C2C1);
  static const Color darkHint = Color(0xFF6E8B8C);
  static const Color darkBgTop = Color(0xFF041A1D);
  static const Color darkBgMid = Color(0xFF07161E);
  static const Color darkBgBottom = Color(0xFF0A1424);
  static const Color darkGlass = Color(0xE6122A30); // 90% deep teal glass
  static const Color darkGlassBorder = Color(0x26FFFFFF);
  static const Color darkTint = Color(0xFF113236);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF13B5A0), primary, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient offerGradient = LinearGradient(
    colors: [Color(0xFFFF8F6B), accent, Color(0xFFF2557A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color glass(BuildContext context) =>
      isDark(context) ? darkGlass : lightGlass;

  static Color glassBorder(BuildContext context) =>
      isDark(context) ? darkGlassBorder : lightGlassBorder;

  static Color tint(BuildContext context) =>
      isDark(context) ? darkTint : lightTint;

  static List<BoxShadow> softShadow(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: .35)
              : primaryDeep.withValues(alpha: .10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}
