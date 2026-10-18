import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/product/controllers/product_controller.dart';
import 'package:kk_thotix_m3aak/features/product/widgets/home_category_item_widget.dart';
import 'package:provider/provider.dart';

class HomeCategoryProductWidget extends StatelessWidget {
  final bool isHomePage;
  const HomeCategoryProductWidget({super.key, required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, homeCategoryProductController, child) {
        // Categories without products would only show a lonely title.
        final categories = homeCategoryProductController.homeCategoryProductList
            .where((c) => c.products?.isNotEmpty ?? false)
            .toList();
        return categories.isNotEmpty ?
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return HomeCategoryProductItemWidget(homeCategoryProduct: categories[index],
                index: index, isHomePage: isHomePage);
            },
            childCount: categories.length,
          ),
        ) : SliverToBoxAdapter(child: const SizedBox());
      },
    );
  }
}


