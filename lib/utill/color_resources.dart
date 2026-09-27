import 'package:flutter/material.dart';

class ColorResources {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color accentPurple = Color(0xFF5B4CF0);

  // ── Bottom-nav ─────────────────────────────────────────────────────────────
  /// Pill background for the selected nav item.
  static const Color navPillBackground = Color(0xFFECE9FF);

  // ── Cart badge ─────────────────────────────────────────────────────────────
  static const Color cartBadge = Color(0xFFE5484D);

  // ── Product card ───────────────────────────────────────────────────────────
  static const Color starRating = Color(0xFFF5A524);

  // ── Bottom-nav bar ─────────────────────────────────────────────────────────
  /// Subtle border around the floating bottom nav container.
  static const Color navBarBorder = Color(0xFFE5E8F1);

  /// Drop-shadow for the floating bottom nav container.
  static const Color navBarShadow = Color(0x18000000);

  // ── Search bar ─────────────────────────────────────────────────────────────
  /// Drop-shadow for the sticky search bar.
  static const Color searchBarShadow = Color(0x14000000);

  /// Inner search-field background.
  static const Color searchFieldBackground = Color(0xFFF1F3FA);

  /// Placeholder / icon colour inside the search field.
  static const Color searchHint = Color(0xFF6D7385);

  // ── Section cards ──────────────────────────────────────────────────────────
  /// Drop-shadow for home section cards.
  static const Color sectionCardShadow = Color(0x12000000);

  // ── Banner overlay ─────────────────────────────────────────────────────────
  static const Color bannerOverlayTop    = Color(0x05000000);
  static const Color bannerOverlayBottom = Color(0xA0000000);

  static Color getHeaderGradientStart(BuildContext context) {
	return Theme.of(context).primaryColor.withValues(alpha: .90);
  }

  static Color getHeaderGradientMid(BuildContext context) {
	return Theme.of(context).primaryColor;
  }

  static Color getHeaderGradientEnd(BuildContext context) {
	return Color.alphaBlend(
	  Colors.black.withValues(alpha: .16),
	  Theme.of(context).primaryColor,
	);
  }

  static Color getHeaderBorder(BuildContext context) {
	return Colors.white.withValues(alpha: .42);
  }

  static Color getHeaderShadow(BuildContext context) {
	return Theme.of(context).primaryColor.withValues(alpha: .22);
  }

  static Color getHeaderIconSurface(BuildContext context) {
	return Colors.white.withValues(alpha: .18);
  }

  static Color getHeaderIconBorder(BuildContext context) {
	return Colors.white.withValues(alpha: .30);
  }

  static Color getNotificationDot(BuildContext context) {
	return Theme.of(context).colorScheme.error;
  }
}
