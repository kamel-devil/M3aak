import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/product_shimmer_widget.dart';
import 'package:kk_thotix_m3aak/features/brand/controllers/brand_controller.dart';
import 'package:kk_thotix_m3aak/features/category/controllers/category_controller.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';
import 'package:kk_thotix_m3aak/features/search_product/widgets/partial_matched_widget.dart';
import 'package:kk_thotix_m3aak/features/search_product/widgets/search_product_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    Provider.of<SearchProductController>(context, listen: false)
        .cleanSearchProduct();
    Provider.of<SearchProductController>(context, listen: false)
        .initHistoryList();
    Provider.of<SearchProductController>(context, listen: false)
        .setInitialFilerData();

    Provider.of<CategoryController>(context, listen: false)
        .resetChecked(null, false);
    Provider.of<SearchProductController>(context, listen: false)
        .setFilterApply(isFiltered: false, isSorted: false, isUpdate: false);
    Provider.of<CategoryController>(context, listen: false)
        .selectedCategoryIds
        .clear();
    Provider.of<BrandController>(context, listen: false)
        .selectedBrandIds
        .clear();
    Provider.of<SearchProductController>(context, listen: false)
        .selectedSellerAuthorIds
        .clear();
    Provider.of<SearchProductController>(context, listen: false)
        .sellerPublishingHouseIds
        .clear();
    Provider.of<SearchProductController>(context, listen: false)
        .publishingHouseIds
        .clear();
    Provider.of<SearchProductController>(context, listen: false)
        .selectedAuthorIds
        .clear();
    // Provider.of<SearchProductController>(context, listen: false).resetChecked(null, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('search_product', context)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding:
                        const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    child: const SearchSuggestion()),

                //const SizedBox(height: Dimensions.paddingSizeDefault),

                Consumer<SearchProductController>(
                  builder: (context, searchProvider, child) {
                    return (searchProvider.isLoading &&
                            searchProvider.searchedProduct == null)
                        ? ProductShimmer(
                            isHomePage: false,
                            isEnabled: searchProvider.searchedProduct == null)
                        : (searchProvider.searchedProduct != null &&
                                searchProvider.isClear)
                            ? ((searchProvider.searchedProduct != null &&
                                        searchProvider
                                                .searchedProduct?.products !=
                                            null &&
                                        searchProvider.searchedProduct!
                                            .products!.isNotEmpty) ||
                                    (searchProvider.isSortingApplied ||
                                        searchProvider.isFilterApplied))
                                ? Column(children: [
                                    const SearchProductWidget(),
                                    if (searchProvider.searchedProduct !=
                                            null &&
                                        (searchProvider.searchedProduct
                                                    ?.totalSize ??
                                                0) >
                                            (searchProvider.searchedProduct
                                                    ?.products?.length ??
                                                0))
                                      Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          child: searchProvider
                                                  .isPaginationLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : CustomButton(
                                                  buttonText: getTranslated(
                                                      'see_more', context),
                                                  onTap: () {
                                                    searchProvider.searchProduct(
                                                        query: searchProvider
                                                            .searchController
                                                            .text,
                                                        offset: (searchProvider
                                                                    .searchedProduct
                                                                    ?.offset ??
                                                                1) +
                                                            1);
                                                  }))
                                  ])
                                : const NoInternetOrDataScreenWidget(
                                    isNoInternet: false)
                            : const _SearchIdleView();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Idle search state: recent searches, popular tags and category shortcuts.
class _SearchIdleView extends StatelessWidget {
  const _SearchIdleView();

  @override
  Widget build(BuildContext context) {
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    Widget header(String title, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(children: [
        Container(width: 4, height: 18, margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(gradient: AppPalette.brandGradient, borderRadius: BorderRadius.circular(4))),
        Expanded(child: Text(title, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor))),
        if (trailing != null) trailing,
      ]),
    );

    return Consumer<SearchProductController>(builder: (context, searchProvider, _) {
      final tags = Provider.of<SplashController>(context, listen: false).configModel?.popularTags ?? [];
      final categories = Provider.of<CategoryController>(context).categoryList;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (searchProvider.historyList.isNotEmpty) ...[
          header(getTranslated('search_history', context) ?? '',
            trailing: TextButton(
              onPressed: () => searchProvider.clearSearchAddress(),
              style: TextButton.styleFrom(minimumSize: const Size(44, 36), padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: Text(getTranslated('clear_all', context) ?? '',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: AppPalette.error)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassContainer(
              blur: false,
              radius: 22,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: [
                for (int index = 0; index < searchProvider.historyList.length && index < 6; index++) ...[
                  if (index > 0) Divider(height: 1, indent: 52, color: AppPalette.glassBorder(context)),
                  InkWell(
                    onTap: () => searchProvider.searchProduct(query: searchProvider.historyList[index], offset: 1),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
                      child: Row(children: [
                        Icon(Icons.history_rounded, size: 20, color: Theme.of(context).hintColor),
                        const SizedBox(width: 18),
                        Expanded(child: Text(searchProvider.historyList[index],
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor))),
                        IconButton(
                          tooltip: getTranslated('delete', context),
                          onPressed: () => searchProvider.removeSearchAddress(index),
                          icon: Icon(Icons.close_rounded, size: 18, color: Theme.of(context).hintColor),
                        ),
                      ]),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],

        if (tags.isNotEmpty) ...[
          header(getTranslated('popular_tag', context) ?? ''),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final tag in tags)
                if ((tag.tag ?? '').isNotEmpty)
                  PressableScale(
                    onTap: () => searchProvider.searchProduct(query: tag.tag!, offset: 1),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppPalette.glass(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.glassBorder(context)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.trending_up_rounded, size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
                          child: Text(tag.tag!, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: textMedium.copyWith(color: textColor)),
                        ),
                      ]),
                    ),
                  ),
            ]),
          ),
        ],

        if (categories.isNotEmpty) ...[
          header(getTranslated('browse_categories', context) ?? ''),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: categories.length > 8 ? 8 : categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 10, childAspectRatio: .74,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return PressableScale(
                onTap: () => RouterHelper.getBrandCategoryRoute(
                  isBrand: false,
                  id: category.id,
                  name: category.name,
                  categoryModel: category,
                  isAllProduct: true,
                ),
                child: Column(children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GlassContainer(
                      blur: false,
                      radius: 20,
                      padding: const EdgeInsets.all(12),
                      child: CustomImageWidget(image: '${category.imageFullUrl?.path}', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(category.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
                ]),
              );
            },
          ),
        ],
      ]);
    });
  }
}
