import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';

class ColorResources {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color accentPurple = AppPalette.primary; // legacy name

  // ── Bottom-nav ─────────────────────────────────────────────────────────────
  /// Pill background for the selected nav item.
  static const Color navPillBackground = Color(0xFFD7F4EE);

  // ── Cart badge ─────────────────────────────────────────────────────────────
  static const Color cartBadge = AppPalette.accent;

  // ── Product card ───────────────────────────────────────────────────────────
  static const Color starRating = AppPalette.warning;

  // ── Bottom-nav bar ─────────────────────────────────────────────────────────
  /// Subtle border around the floating bottom nav container.
  static const Color navBarBorder = AppPalette.lightGlassBorder;

  /// Drop-shadow for the floating bottom nav container.
  static const Color navBarShadow = Color(0x220A6F6B);

  // ── Search bar ─────────────────────────────────────────────────────────────
  /// Drop-shadow for the sticky search bar.
  static const Color searchBarShadow = Color(0x180A6F6B);

  /// Inner search-field background.
  static const Color searchFieldBackground = Color(0xB3FFFFFF);

  /// Placeholder / icon colour inside the search field.
  static const Color searchHint = AppPalette.lightInkSoft;

  // ── Section cards ──────────────────────────────────────────────────────────
  /// Drop-shadow for home section cards.
  static const Color sectionCardShadow = Color(0x140A6F6B);

  // ── Banner overlay ─────────────────────────────────────────────────────────
  static const Color bannerOverlayTop    = Color(0x05000000);
  static const Color bannerOverlayBottom = Color(0xA0062A2A);

  static Color getHeaderGradientStart(BuildContext context) {
	return const Color(0xFF13B5A0);
  }

  static Color getHeaderGradientMid(BuildContext context) {
	return AppPalette.primary;
  }

  static Color getHeaderGradientEnd(BuildContext context) {
	return AppPalette.primaryDeep;
  }

  static Color getHeaderBorder(BuildContext context) {
	return Colors.white.withValues(alpha: .42);
  }

  static Color getHeaderShadow(BuildContext context) {
	return AppPalette.primaryDeep.withValues(alpha: .25);
  }

  static Color getHeaderIconSurface(BuildContext context) {
	return Colors.white.withValues(alpha: .18);
  }

  static Color getHeaderIconBorder(BuildContext context) {
	return Colors.white.withValues(alpha: .30);
  }

  static Color getNotificationDot(BuildContext context) {
	return AppPalette.accent;
  }
}
