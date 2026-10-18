import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Height the home screen reserves for [FindWhatYouNeedView].
double findWhatYouNeedHeight(BuildContext context) =>
    ResponsiveHelper.isTab(context) ? 212 : 196;

/// Horizontal rail of colourful category "aisles", each showing its
/// top sub-categories as round shortcuts.
class FindWhatYouNeedView extends StatelessWidget {
  const FindWhatYouNeedView({super.key});

  static const List<Color> _accents = [
    AppPalette.primary,
    AppPalette.secondary,
    AppPalette.accent,
    AppPalette.warning,
    Color(0xFF8B6CF0),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, c, _) {
        final items = c.findWhatYouNeedModel?.findWhatYouNeed;

        if (items == null) return const FindWhatYouNeedShimmer();
        if (items.isEmpty) return const SizedBox();

        final double width = ResponsiveHelper.isTab(context)
            ? 340
            : MediaQuery.of(context).size.width * .8;

        return SizedBox(
          height: findWhatYouNeedHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault, 4, Dimensions.paddingSizeDefault, 14),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: width,
                child: FadeSlideIn(
                  index: index,
                  offset: const Offset(24, 0),
                  child: _AisleCard(
                    accent: _accents[index % _accents.length],
                    title: item.name ?? '',
                    productCount: item.productCount ?? 0,
                    childes: item.childes ?? [],
                    onTap: () => RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: item.id,
                      name: item.name,
                    ),
                    onTapChild: (sub) => RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: sub.id,
                      name: sub.name,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AisleCard extends StatelessWidget {
  const _AisleCard({
    required this.accent,
    required this.title,
    required this.productCount,
    required this.childes,
    required this.onTap,
    required this.onTapChild,
  });

  final Color accent;
  final String title;
  final int productCount;
  final List<dynamic> childes;
  final VoidCallback onTap;
  final void Function(dynamic child) onTapChild;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppPalette.isDark(context);
    final preview = childes.take(3).toList();

    return PressableScale(
      scale: .98,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              accent.withValues(alpha: dark ? .32 : .20),
              accent.withValues(alpha: dark ? .12 : .06),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: .25)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(children: [
            // Decorative ring in the corner.
            PositionedDirectional(
              end: -36,
              top: -36,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: .18), width: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$productCount ${getTranslated('products', context)}',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: accent),
                      ),
                    ]),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ]),
                const Spacer(),
                Row(children: [
                  for (int i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: i < preview.length
                          ? _SubCategoryBubble(
                              sub: preview[i],
                              accent: accent,
                              onTap: () => onTapChild(preview[i]),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SubCategoryBubble extends StatelessWidget {
  const _SubCategoryBubble({required this.sub, required this.accent, required this.onTap});

  final dynamic sub;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: AppPalette.isDark(context)
              ? Colors.white.withValues(alpha: .06)
              : Colors.white.withValues(alpha: .85),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 50,
              height: 50,
              child: CustomImageWidget(
                image: sub.iconFullUrl?.path ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall + 1,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ]),
      ),
    );
  }
}
