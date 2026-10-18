import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_widget.dart';
import 'package:kk_thotix_m3aak/features/deal/controllers/featured_deal_controller.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:kk_thotix_m3aak/common/basewidget/pharmacy_product_parts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';


class FeaturedDealsListWidget extends StatelessWidget {
  final bool isHomePage;
  const FeaturedDealsListWidget({super.key, this.isHomePage = true});

  @override
  Widget build(BuildContext context) {

    return isHomePage?
    Consumer<FeaturedDealController>(
      builder: (context, featuredDealProvider, child) {
        return featuredDealProvider.featuredDealProductList != null? featuredDealProvider.featuredDealProductList!.isNotEmpty ?
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 128,
            viewportFraction: 0.86,
            autoPlay: true,
            pauseAutoPlayOnTouch: true,
            pauseAutoPlayOnManualNavigate: true,
            pauseAutoPlayInFiniteScroll: true,
            enlargeFactor: 0.12,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            disableCenter: true,
            onPageChanged: (index, reason) => featuredDealProvider.changeSelectedIndex(index)
          ),
          itemCount: featuredDealProvider.featuredDealProductList?.length,
          itemBuilder: (context, index, _) => Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
            child: ProductRowTile(product: featuredDealProvider.featuredDealProductList![index], imageSize: 96),
          ),
        ) : const SizedBox() : const FindWhatYouNeedShimmer();
      }):

    Consumer<FeaturedDealController>(
      builder: (context, featuredDealProvider, _) {
        return RepaintBoundary(
          child: MasonryGridView.count(
            itemCount: featuredDealProvider.featuredDealProductList?.length,
            crossAxisCount: ResponsiveHelper.isTab(context) ? 3 : 2,
            padding: const EdgeInsets.all(0),
            itemBuilder: (BuildContext context, int index) => ProductWidget(productModel: featuredDealProvider.featuredDealProductList![index]),
          ),
        );
      }
    );
  }
}


