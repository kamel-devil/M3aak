import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/slider_product_shimmer_widget.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product/enums/product_type.dart';
import 'package:kk_thotix_m3aak/features/product/widgets/latest_product/latest_product_widget.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/title_row_widget.dart';
import 'package:provider/provider.dart';

class LatestProductListWidget extends StatelessWidget {
  const LatestProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (ctx, c) => c.latestProductModel,
      builder: (context, model, child) {
        final products = model?.products ?? [];

        if (model == null) {
          return const SliderProductShimmerWidget();
        }

        if (products.isEmpty) {
          return const SizedBox();
        }

        final bool isTab = ResponsiveHelper.isTab(context);
        // Each row card height = image height + vertical padding
        const double cardHeight = 108;
        const double cardSpacing = 10;
        final bool twoRows = products.length > 4;
        final double listHeight = twoRows
            ? (cardHeight * 2) + cardSpacing
            : cardHeight;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: TitleRowWidget(
                  title: getTranslated('latest_products', context),
                  onTap: () => RouterHelper.getViewAllProductScreenRoute(
                    productType: ProductType.latestProduct,
                    action: RouteAction.push,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: listHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final cardWidth = isTab ? 360.0 : 280.0;

                    if (twoRows) {
                      // Build in pairs: even index is top row, odd is bottom
                      if (index.isOdd) return const SizedBox.shrink();

                      final topProduct = products[index];
                      final bottomIndex = index + 1;
                      final hasBottom = bottomIndex < products.length;

                      return SizedBox(
                        width: cardWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: LatestProductWidget(productModel: topProduct),
                            ),
                            if (hasBottom) ...[
                              const SizedBox(height: cardSpacing),
                              Expanded(
                                child: LatestProductWidget(productModel: products[bottomIndex]),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: LatestProductWidget(productModel: products[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}
