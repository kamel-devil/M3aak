import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_shimmer_item_widget.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

class ProductShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isHomePage;
  const ProductShimmer({super.key, required this.isEnabled, required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
      child: GridView.builder(

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isTab(context)? 3: 2,
        crossAxisSpacing: 10,mainAxisSpacing: 10,
        childAspectRatio: (1 / 1.5),),
        itemCount: 10,
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return const ProductShimmerItemWidget();
        },
      ),
    );
  }
}

