import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_shimmer_widget.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Horizontal row of equal compact product cards.
class RelatedProductWidget extends StatelessWidget {
  const RelatedProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, prodProvider, child) {
        final list = prodProvider.relatedProductList;
        if (list == null) {
          return ProductShimmer(isHomePage: false, isEnabled: true);
        }
        if (list.isEmpty) return const SizedBox();

        return SizedBox(
          height: 268,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: 4),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => FadeSlideIn(
              index: index < 6 ? index : 6,
              child: _CompactProductCard(product: list[index]),
            ),
          ),
        );
      },
    );
  }
}

class _CompactProductCard extends StatelessWidget {
  const _CompactProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => ProductPricing.openDetails(product),
      child: GlassContainer(
        blur: false,
        radius: 22,
        width: 156,
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ProductImageTile(product: product, size: 140, radius: 16),
            PositionedDirectional(top: 6, end: 6, child: GlassFavouriteButton(productId: product.id)),
          ]),
          const SizedBox(height: 8),
          Text(product.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall + 1,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
          const Spacer(),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: ProductPriceText(product: product)),
            const SizedBox(width: 6),
            QuickAddCartButton(product: product, size: 34),
          ]),
        ]),
      ),
    );
  }
}
