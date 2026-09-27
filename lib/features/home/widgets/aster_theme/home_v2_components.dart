import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/color_resources.dart';

import '../../../../localization/language_constrants.dart';

class HomeV2StickySearchBar extends StatelessWidget {
  const HomeV2StickySearchBar({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onScanTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).cardColor.withValues(alpha: 0.85),
              border: Border.all(color: ColorResources.navBarBorder),
              boxShadow: const [
                BoxShadow(
                  color: ColorResources.searchBarShadow,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onSearchTap,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: ColorResources.searchFieldBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: ColorResources.searchHint),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              getTranslated('search_home', context)!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ColorResources.searchHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _UtilityButton(icon: Icons.tune_rounded, onTap: onFilterTap),
                const SizedBox(width: 8),
                _UtilityButton(
                    icon: Icons.qr_code_scanner_rounded, onTap: onScanTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color brandColor = Theme.of(context).primaryColor;
    return Material(
      color: ColorResources.navPillBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: brandColor),
        ),
      ),
    );
  }
}

class HomeV2SectionCard extends StatelessWidget {
  const HomeV2SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: ColorResources.sectionCardShadow,
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HomeV2SectionGap extends StatelessWidget {
  const HomeV2SectionGap({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
