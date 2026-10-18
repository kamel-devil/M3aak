import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Grid product card: framed packshot, discount + favourite on the image,
/// two-line name, rating, price and an animated quick-add button.
class ProductWidget extends StatelessWidget {
  final Product productModel;
  final int productNameLine;
  final double? margin;
  const ProductWidget(
      {super.key,
      required this.productModel,
      this.productNameLine = 2,
      this.margin});

  @override
  Widget build(BuildContext context) {
    final Product p = productModel;
    final double rating = ProductPricing.rating(p);
    final TextStyle nameStyle = textMedium.copyWith(
      fontSize: Dimensions.fontSizeDefault,
      height: 1.3,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return Padding(
      padding: EdgeInsets.all(margin ?? Dimensions.paddingSizeExtraSmall),
      child: PressableScale(
        scale: .97,
        haptic: false,
        onTap: () => ProductPricing.openDetails(p),
        child: GlassContainer(
          blur: false,
          radius: 24,
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LayoutBuilder(
              builder: (context, constraints) => Stack(children: [
                ProductImageTile(
                    product: p, size: constraints.maxWidth, radius: 18),
                if (ProductPricing.hasDiscount(p))
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: DiscountBadge(
                        label: ProductPricing.discountLabel(context, p),
                        small: true),
                  ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: GlassFavouriteButton(productId: p.id),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed height keeps prices aligned across the grid.
                  SizedBox(
                    height: (nameStyle.fontSize! * nameStyle.height!) *
                        productNameLine,
                    child: Text(
                      p.name ?? '',
                      maxLines: productNameLine,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 18,
                    child: rating > 0
                        ? RatingPill(rating: rating, count: p.reviewCount)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(child: ProductPriceText(product: p)),
                    const SizedBox(width: 6),
                    QuickAddCartButton(product: p),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
