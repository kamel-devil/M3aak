import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/home/shimmers/recommended_product_shimmer.dart';
import 'package:provider/provider.dart';

/// "Deal of the day" spotlight: warm gradient frame around one product.
class RecommendedProductWidget extends StatelessWidget {
  final bool fromAsterTheme;
  const RecommendedProductWidget({super.key, this.fromAsterTheme = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, child) {
        final Product? product = controller.recommendedProduct;
        if (product == null) return const RecommendedProductShimmer();
        if (product.id == -1) return const SizedBox();

        final bool dark = AppPalette.isDark(context);
        final double imageSize = ResponsiveHelper.isTab(context) ? 170 : 118;

        return FadeSlideIn(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF3A1F25), const Color(0xFF1C2A2E)]
                    : [const Color(0xFFFFE7E0), const Color(0xFFFFF6E5)],
              ),
              border: Border.all(color: AppPalette.accent.withValues(alpha: .25)),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.accent.withValues(alpha: .15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
                child: Row(children: [
                  PulseGlow(
                    color: AppPalette.accent,
                    radius: 14,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppPalette.offerGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        getTranslated(fromAsterTheme ? 'dont_miss_the_chance' : 'deal_of_the_day', context) ?? '',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: AppPalette.accent),
                      ),
                      Text(
                        getTranslated(fromAsterTheme ? 'lets_shopping_today' : 'deal_of_the_day', context) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ]),
                  ),
                ]),
              ),

              // Product
              PressableScale(
                scale: .98,
                onTap: () => ProductPricing.openDetails(product),
                child: GlassContainer(
                  blur: false,
                  radius: 22,
                  padding: const EdgeInsets.all(10),
                  color: dark ? AppPalette.darkGlass : Colors.white.withValues(alpha: .92),
                  showShadow: false,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Stack(clipBehavior: Clip.none, children: [
                      ProductImageTile(product: product, size: imageSize, radius: 18),
                      if (ProductPricing.hasDiscount(product))
                        PositionedDirectional(
                          top: 6,
                          start: 6,
                          child: DiscountBadge(
                              label: ProductPricing.discountLabel(context, product), small: true),
                        ),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: imageSize,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: Text(
                                  product.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    height: 1.3,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              GlassFavouriteButton(productId: product.id),
                            ]),
                            if (ProductPricing.rating(product) > 0)
                              RatingPill(
                                  rating: ProductPricing.rating(product),
                                  count: product.reviewCount),
                            const Spacer(),
                            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Expanded(child: ProductPriceText(product: product, large: true)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: AppPalette.offerGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppPalette.accent.withValues(alpha: .3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text(getTranslated('grab_this_deal', context) ?? '',
                                      style: textBold.copyWith(
                                          color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                                ]),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
