import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:provider/provider.dart';

class FindWhatYouNeedView extends StatelessWidget {
  const FindWhatYouNeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLtr = context.read<LocalizationController>().isLtr;
    final dark = context.read<ThemeController>().darkTheme;

    return Consumer<ProductController>(
      builder: (context, c, _) {
        final items = c.findWhatYouNeedModel?.findWhatYouNeed;

        if (items == null) return const FindWhatYouNeedShimmer();
        if (items.isEmpty) return const SizedBox();

        final cardHeight = ResponsiveHelper.isTab(context) ? 170.0 : 155.0;

        return SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: cardHeight,
              padEnds: false,
              viewportFraction: ResponsiveHelper.isTab(context) ? .65 : .88,
              autoPlay: true,
              enableInfiniteScroll: items.length > 1,
              enlargeCenterPage: false,
            ),
            itemCount: items.length,
            itemBuilder: (context, index, _) {
              final item = items[index];
              final childes = item.childes ?? [];

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: isLtr ? Dimensions.paddingSizeSmall : 0,
                  end: index == items.length - 1
                      ? Dimensions.paddingSizeDefault
                      : (isLtr ? 0 : Dimensions.paddingSizeSmall),
                ),
                child: _FindNeedCard(
                  dark: dark,
                  title: item.name ?? '',
                  productCount: item.productCount ?? 0,
                  childes: childes,
                  onTapCard: () {
                    RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: item.id,
                      name: item.name,
                    );
                  },
                  onTapChild: (sub) {
                    RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: sub.id,
                      name: sub.name,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FindNeedCard extends StatelessWidget {
  final bool dark;
  final String title;
  final int productCount;
  final List<dynamic> childes;
  final VoidCallback onTapCard;
  final void Function(dynamic child) onTapChild;

  const _FindNeedCard({
    required this.dark,
    required this.title,
    required this.productCount,
    required this.childes,
    required this.onTapCard,
    required this.onTapChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(Dimensions.radiusDefault);
    final primary = theme.primaryColor;

    // show max 4 child items in a 2x2 grid
    final preview = childes.take(4).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTapCard,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: theme.cardColor,
            border: Border.all(color: primary.withOpacity(0.5), width: 0.8),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(dark ? 0.25 : 0.10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              children: [
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        primary.withOpacity(dark ? 0.30 : 0.25),
                        primary.withOpacity(dark ? 0.15 : 0.1),
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$productCount ${getTranslated('products', context)}',
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(dark ? 0.35 : 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: primary.withOpacity(0.20),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 14, color: primary),
                            const SizedBox(width: 6),
                            Text(
                              getTranslated('explore', context) ?? 'Explore',
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(
                      children: [
                        // Mini grid (2x2)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final size = (c.maxHeight - 8) / 1; // 2 rows + spacing
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(preview.length, (i) {
                                  final sub = preview[i];
                                  final iconPath = sub.iconFullUrl?.path ?? '';
                                  final name = sub.name ?? '';

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => onTapChild(sub),
                                    child: Container(
                                      width: (c.maxWidth - 8) / 2,
                                      height: size,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: theme.primaryColor.withOpacity(0.06),
                                        border: Border.all(
                                          color: primary.withOpacity(0.10),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: SizedBox(
                                              width: size * 0.62,
                                              height: size * 0.62,
                                              child: CustomImageWidget(
                                                fit: BoxFit.cover,
                                                image: iconPath,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: textRegular.copyWith(
                                                fontSize: Dimensions.fontSizeSmall,
                                                fontWeight: FontWeight.w700,
                                                color: theme.textTheme.bodyLarge?.color,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        // CTA vertical
                        Container(
                          width: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: primary.withOpacity(dark ? 0.28 : 0.10),
                            border: Border.all(
                              color: primary.withOpacity(0.18),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
