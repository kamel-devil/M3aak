import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:kk_thotix_m3aak/common/basewidget/slider_product_shimmer_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product/enums/product_type.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/title_row_widget.dart';
import 'package:provider/provider.dart';

/// Horizontal carousel of compact product tiles, two rows when there are
/// enough products.
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
        const double cardHeight = 104;
        const double cardSpacing = 10;
        final bool twoRows = products.length > 4;
        final double listHeight =
            twoRows ? (cardHeight * 2) + cardSpacing : cardHeight;
        final double cardWidth = isTab ? 360.0 : MediaQuery.of(context).size.width * .78;
        final int columns = twoRows ? (products.length / 2).ceil() : products.length;

        return FadeSlideIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleRowWidget(
                title: getTranslated('latest_products', context),
                onTap: () => RouterHelper.getViewAllProductScreenRoute(
                  productType: ProductType.latestProduct,
                  action: RouteAction.push,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: listHeight + 12,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 12),
                  itemCount: columns,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, column) {
                    final int top = twoRows ? column * 2 : column;
                    final int bottom = top + 1;
                    return SizedBox(
                      width: cardWidth,
                      child: Column(children: [
                        SizedBox(
                            height: cardHeight,
                            child: ProductRowTile(product: products[top], imageSize: 84)),
                        if (twoRows && bottom < products.length) ...[
                          const SizedBox(height: cardSpacing),
                          SizedBox(
                              height: cardHeight,
                              child: ProductRowTile(product: products[bottom], imageSize: 84)),
                        ],
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
