import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/search_product/controllers/search_product_controller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SearchSuggestion extends StatefulWidget {
  final bool fromCompare;
  final int? id;

  const SearchSuggestion({super.key, this.fromCompare = false, this.id});
  @override
  State<SearchSuggestion> createState() => _SearchSuggestionState();
}

class _SearchSuggestionState extends State<SearchSuggestion>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed((const Duration(milliseconds: 500))).then((_) {
      if (mounted) {
        FocusScope.of(Get.context!).requestFocus(
            Provider.of<SearchProductController>(Get.context!, listen: false)
                .searchFocusNode);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Clear search state when app resumes to clean up after navigation
      Provider.of<SearchProductController>(Get.context!, listen: false)
          .cleanSearchProduct(notify: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: Consumer<SearchProductController>(
          builder: (context, searchProvider, _) {
        return SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Autocomplete<SuggestionOptionData>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final String query = textEditingValue.text.trim().toLowerCase();
                if (query.isEmpty || searchProvider.suggestionOptions.isEmpty) {
                  return const Iterable<SuggestionOptionData>.empty();
                }
                return searchProvider.suggestionOptions.where(
                  (option) => option.name.toLowerCase().contains(query),
                );
              },
              optionsViewOpenDirection: OptionsViewOpenDirection.down,
              optionsViewBuilder: (context,
                  Function(SuggestionOptionData) onSelected, options) {
                return Material(
                    elevation: 0,
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                              onTap: () {
                                RouterHelper.getProductDetailsRoute(
                                  action: RouteAction.push,
                                  productId: option.id,
                                  slug: option.slug,
                                );
                                searchProvider.cleanSearchProduct(notify: true);
                                // if(widget.fromCompare){
                                //   searchProvider.setSelectedProductId(originalIndex, widget.id);
                                //   Navigator.of(context).pop();
                                // }else{
                                //   // Navigate to product details with slug and productId
                                //   if (originalIndex >= 0 && originalIndex < searchProvider.slugList.length) {
                                //     String slug = searchProvider.slugList[originalIndex];
                                //     int productId = searchProvider.idList[originalIndex];
                                //     RouterHelper.getProductDetailsRoute(
                                //       action: RouteAction.push,
                                //       productId: productId,
                                //       slug: slug,
                                //     );
                                //     searchProvider.cleanSearchProduct(notify: true);
                                //   }
                                // }
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault),
                                            child: Icon(Icons.history,
                                                color:
                                                    Theme.of(context).hintColor,
                                                size: 25)),
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall),
                                                child: SubstringHighlight(
                                                  text: option.name,
                                                  textStyle:
                                                      textRegular.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color!
                                                                  .withValues(
                                                                      alpha:
                                                                          .5),
                                                          fontSize: Dimensions
                                                              .fontSizeLarge),
                                                  term: searchProvider
                                                      .searchController.text,
                                                  textStyleHighlight:
                                                      textMedium.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color,
                                                          fontSize: Dimensions
                                                              .fontSizeLarge),
                                                ))),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeDefault),
                                            child: Icon(
                                                CupertinoIcons.arrow_up_left,
                                                color:
                                                    Theme.of(context).hintColor,
                                                size: 25))
                                      ])));
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        itemCount: options.length));
              },
              onSelected: (selectedOption) {
                if (kDebugMode) {
                  print(selectedOption.name);
                }
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                searchProvider.searchController = controller;
                searchProvider.searchFocusNode = focusNode;

                return Hero(
                  tag: 'search',
                  child: Material(
                    child: TextFormField(
                      controller: controller,
                      focusNode: searchProvider.searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: (val) {
                        searchProvider.onSuggestionQueryChanged(val);
                      },
                      onFieldSubmitted: (value) {
                        if (controller.text.trim().isNotEmpty) {
                          searchProvider
                              .saveSearchAddress(controller.text.toString());
                          // Navigate to product details if matching suggestion exists
                          if (searchProvider.suggestionOptions.isNotEmpty) {
                            final SuggestionOptionData firstSuggestion =
                                searchProvider.suggestionOptions.first;
                            RouterHelper.getProductDetailsRoute(
                              action: RouteAction.push,
                              productId: firstSuggestion.id,
                              slug: firstSuggestion.slug,
                            );
                            searchProvider.cleanSearchProduct(notify: true);
                            controller.clear();
                          } else {
                            searchProvider.searchProduct(
                                query: controller.text.toString(), offset: 1);
                          }
                        } else {
                          showCustomSnackBar(
                              getTranslated('enter_somethings', context),
                              context);
                        }
                      },
                      style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall),
                              borderSide: BorderSide(color: Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall),
                              borderSide: BorderSide(color: Colors.grey[300]!)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall),
                              borderSide: BorderSide(color: Colors.grey[300]!)),
                          hintText: getTranslated('search_product', context),
                          suffixIcon: SizedBox(
                            width: controller.text.isNotEmpty ? 70 : 50,
                            child: Row(
                              children: [
                                if (controller.text.isNotEmpty)
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          controller.clear();
                                          searchProvider.cleanSearchProduct(
                                              notify: true);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.clear,
                                        size: 20,
                                      )),
                                InkWell(
                                  onTap: () {
                                    if (controller.text.trim().isNotEmpty) {
                                      focusNode.unfocus();
                                      searchProvider.saveSearchAddress(
                                          controller.text.toString());
                                      searchProvider.searchProduct(
                                          query: controller.text.toString(),
                                          offset: 1);
                                    } else {
                                      showCustomSnackBar(
                                          getTranslated(
                                              'enter_somethings', context),
                                          context);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                        width: 40,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(Dimensions
                                                        .paddingSizeSmall))),
                                        child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  Dimensions.paddingSizeSmall),
                                              child: Image.asset(Images.search,
                                                  color: Colors.white),
                                            ))),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
