
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_directionality_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/product_details/controllers/product_details_controller.dart';
import 'package:kk_thotix_m3aak/features/product_details/domain/models/product_details_model.dart';
import 'package:kk_thotix_m3aak/features/review/controllers/review_controller.dart';
import 'package:kk_thotix_m3aak/helper/color_helper.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/product_helper.dart';
import 'package:kk_thotix_m3aak/localization/app_localization.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';


class ProductTitleWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final String? averageRatting;
  const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});

  @override
  Widget build(BuildContext context) {

    ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(productModel);
    double? startingPrice = priceRange.start;
    double? endingPrice = priceRange.end;

    return productModel != null? GlassContainer(
      blur: false,
      radius: 26,
      margin: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Consumer<ProductDetailsController>(
        builder: (context, details, child) {
          final bool physical = productModel!.productType != 'digital';
          final bool inStock = !physical || (productModel!.currentStock ?? 0) > 0;
          Widget badge(IconData icon, String label, Color color) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
            ]),
          );

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Wrap(spacing: 6, runSpacing: 6, children: [
              if (physical)
                badge(inStock ? Icons.check_rounded : Icons.block_rounded,
                    getTranslated(inStock ? 'in_stock' : 'out_of_stock', context) ?? '',
                    inStock ? AppPalette.success : AppPalette.error),
              if ((details.orderCount ?? 0) > 0)
                badge(Icons.shopping_bag_outlined, '${details.orderCount} ${getTranslated('orders', context)}', AppPalette.primaryDeep),
            ]),
            const SizedBox(height: 10),

            Text(
                productModel!.name ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, height: 1.35, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 3,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CustomDirectionalityWidget(
                child: Text(
                  '${startingPrice != null ?
                      PriceConverter.convertPrice(
                        context,
                        startingPrice,
                        discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                            ? productModel?.clearanceSale?.discountAmount
                            : productModel?.discount,
                        discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                            ? productModel?.clearanceSale?.discountType
                            : productModel?.discountType,
                      )
                      : ''}'
                  '${endingPrice != null
                      ? ' - ${PriceConverter.convertPrice(
                            context,
                            endingPrice,
                            discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                ? productModel?.clearanceSale?.discountAmount
                                : productModel?.discount,
                            discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                ? productModel?.clearanceSale?.discountType
                                : productModel?.discountType,
                          )}'
                      : ''}',
                  style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeOverLarge,
                  ),
                ),
              ),

              if((productModel!.discount != null && productModel!.discount! > 0) || (productModel!.clearanceSale != null && productModel!.clearanceSale!.discountAmount! > 0) )...[
                const SizedBox(width: Dimensions.paddingSizeSmall),

                CustomDirectionalityWidget(
                  child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
                      '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                      style: textRegular.copyWith(color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeDefault,
                          decoration: TextDecoration.lineThrough, decorationColor: Theme.of(context).hintColor)),
                ),
              ],
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),


            if (productModel!.reviews != null && productModel!.reviews!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.star_rounded, color: AppPalette.warning, size: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      (double.tryParse(averageRatting ?? '0') ?? 0).toStringAsFixed(1),
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Text(
                    '(${PriceConverter.longToShortPrice(productModel?.reviewsCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: Dimensions.paddingSizeSmall),


            Consumer<ReviewController>(
              builder: (context, reviewController, _) {
                return Row(children: [

                  if(reviewController.reviewList != null && (reviewController.reviewList?.length ?? 0) > 0)
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${reviewController.reviewList != null ? reviewController.reviewList!.length : 0} ',
                      style: textMedium.copyWith(
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),

                    TextSpan(
                      text: '${getTranslated('reviews', context)} ',
                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ])),


                  if((details.wishCount ?? 0) > 0)
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '${(reviewController.reviewList?.length ?? 0) > 0 ? ' | ' : ''}${details.wishCount}', style: textMedium.copyWith(
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                    )),

                    TextSpan(
                        text: ' ${getTranslated('wish_listed', context)}',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ])),

                ]);
              }),

              Consumer<ReviewController>(
                builder: (context, reviewController, _) {
                  if(((details.wishCount ?? 0) > 0) || ((reviewController.reviewList != null && (reviewController.reviewList?.length ?? 0) > 0))) {
                    return const SizedBox(height: Dimensions.paddingSizeSmall);
                  }
                  return SizedBox();
                }
              ),

            if(_isVariationAvailable()) ...[
              Text(
                '${getTranslated('available', context)}',
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],

            /// Available color
            productModel!.colors != null && productModel!.colors!.isNotEmpty ?
            Row(children: [

              Text('${getTranslated('color', context)} : ', style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Expanded(child: SizedBox(height: Dimensions.paddingSizeLarge, child: ListView.separated(
                itemCount: productModel!.colors!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Center(child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                      child: Container(
                        width: Dimensions.marginSizeAuthSmall,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorHelper.hexCodeToColor(productModel?.colors?[index].code),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppPalette.glassBorder(context), width: 2),
                        ),
                      ),
                  ));
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSizeDefaultAddress),
              ))),
            ]) : const SizedBox(),

            productModel!.colors != null &&  productModel!.colors!.isNotEmpty ?
            const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

            productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty ?
            ListView.builder(
              shrinkWrap: true,
              itemCount: productModel!.choiceOptions!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text('${productModel!.choiceOptions![index].title?.toCapitalized()} : ', style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: SizedBox(height: Dimensions.paddingSizeExtraLarge, child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: productModel!.choiceOptions![index].options!.length,
                        itemBuilder: (context, i) {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraExtraSmall,
                              horizontal: Dimensions.paddingSizeSmall
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.18)),
                            ),
                            child: Text(
                                productModel!.choiceOptions![index].options![i].trim(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSizeSmall),
                      )),
                    )),

                  ],
                );
              },
            ) : const SizedBox(),
          ]);
        },
      ),
    ) : const SizedBox();
  }

  bool _isVariationAvailable() => ((productModel!.colors != null && productModel!.colors!.isNotEmpty) && productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty);
}


