import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class ProductShimmerItemWidget extends StatelessWidget {
  const ProductShimmerItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).highlightColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ]),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).cardColor,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(bottom: 0),
              decoration: BoxDecoration(
                color: Provider.of<ThemeController>(context).darkTheme ?
                Theme.of(context).primaryColor.withValues(alpha:.05) :
                Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(top: Dimensions.paddingSizeDefault),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 60, color: Colors.white),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(height: 18, color: Colors.white),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(height: 10, width: 70, color: Colors.white),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Container(height: 16, width: 90, color: Colors.white),
                      ]),
                    ),
                    Container(height: 36, width: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
