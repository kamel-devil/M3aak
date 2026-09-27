import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/discount_tag_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/favourite_button_widget.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/controllers/theme_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// todo - remove commented code - zianur
// class ProductWidget extends StatelessWidget {
//   final Product productModel;
//   final int productNameLine;
//   const ProductWidget({super.key, required this.productModel, this.productNameLine = 2});
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;
//     double ratting = (productModel.rating?.isNotEmpty ?? false) ?  double.parse('${productModel.rating?[0].average}') : 0;
//
//     return InkWell(onTap: () {
//       Navigator.push(context, PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 1000),
//         pageBuilder: (context, anim1, anim2) => ProductDetails(productId: productModel.id, slug: productModel.slug),
//       ));
//     },
//       child: Container(
//         margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall), border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.10), width: 1),
//           color: Theme.of(context).highlightColor,
//           boxShadow: [BoxShadow(
//             color: Theme.of(context).primaryColor.withValues(alpha:0.05),
//             spreadRadius: 0, blurRadius: 10,
//             offset: const Offset(9, 5),
//           )],
//         ),
//         child: Stack(children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//
//             LayoutBuilder(builder: (context, boxConstraint)=> ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(Dimensions.radiusDefault),
//                 topRight: Radius.circular(Dimensions.radiusDefault),
//               ),
//               child: Stack(children: [
//
//                 Container(
//                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall), border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.10), width: 1),
//                     color: Theme.of(context).highlightColor,
//                     boxShadow: [BoxShadow(
//                       color: Theme.of(context).primaryColor.withValues(alpha:0.05),
//                       spreadRadius: 0, blurRadius: 10,
//                       offset: const Offset(0, 0),
//                     )],
//                   ),
//                   margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(Dimensions.paddingSizeEight),
//                     child: CustomImageWidget(
//                       image: '${productModel.thumbnailFullUrl?.path}',
//                       fit: BoxFit.cover,
//                       height: boxConstraint.maxWidth * 0.82,
//                       width: boxConstraint.maxWidth,
//                     ),
//                   ),
//                 ),
//
//                 if(productModel.currentStock! == 0 && productModel.productType == 'physical')...[
//                   Container(
//                     height: boxConstraint.maxWidth * 0.82,
//                     width: boxConstraint.maxWidth,
//                     color: Colors.black.withValues(alpha:0.4),
//                   ),
//
//                   Positioned.fill(child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       width: boxConstraint.maxWidth,
//                       decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.error.withValues(alpha:0.4),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(Dimensions.radiusSmall),
//                             topRight: Radius.circular(Dimensions.radiusSmall),
//                           )
//                       ),
//                       child: Text(
//                         getTranslated('out_of_stock', context)??'',
//                         style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   )),
//
//                 ],
//
//               ],
//               ),
//             )),
//
//             // Product Details
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//                 if(ratting > 0) Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//                   const Icon(Icons.star_rate_rounded, color: Colors.orange, size: Dimensions.paddingSizeDefault),
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 2.0),
//                     child: Text(ratting.toStringAsFixed(1), style: textRegular.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                     )),
//                   ),
//
//                   Text('(${productModel.reviewCount.toString()})', style: textRegular.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: Theme.of(context).hintColor),
//                   ),
//                 ]),
//
//                 Text(productModel.name ?? '', textAlign: TextAlign.center, style: textBold.copyWith(
//                     fontSize: Dimensions.fontSizeDefault,
//                     color: Theme.of(context).textTheme.bodyLarge?.color
//                 ), maxLines: productNameLine, overflow: TextOverflow.ellipsis),
//
//                 if(hasDiscount())
//                   Text(PriceConverter.convertPrice(context, productModel.unitPrice), style: titleRegular.copyWith(
//                     color: Theme.of(context).hintColor,
//                     decoration: TextDecoration.lineThrough,
//                     decorationColor: Theme.of(context).hintColor,
//                     fontSize: Dimensions.fontSizeSmall,
//                   )),
//
//                 Text(
//                   PriceConverter.convertPrice(
//                     context, productModel.unitPrice,
//                     discountType: (productModel.clearanceSale?.discountAmount ?? 0)  > 0
//                         ? productModel.clearanceSale?.discountType
//                         : productModel.discountType,
//                     discount: (productModel.clearanceSale?.discountAmount ?? 0)  > 0
//                         ? productModel.clearanceSale?.discountAmount
//                         : productModel.discount,
//                   ),
//                   style: robotoBold.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeDefault),
//                 ),
//
//               ]),
//             ),
//           ]),
//
//           // Off
//
//           ((productModel.discount! > 0) || (productModel.clearanceSale != null)) ?
//           DiscountTagWidget(productModel: productModel) : const SizedBox.shrink(),
//
//           Positioned(top: 18, right: isLtr ? 16 : null, left: !isLtr ? 16 : null,
//             child: FavouriteButtonWidget(
//               backgroundColor: Provider.of<ThemeController>(context).darkTheme
//                   ? Theme.of(context).cardColor
//                   : Theme.of(context).primaryColor,
//               productId: productModel.id,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   bool hasDiscount() => (productModel.discount != null && productModel.discount! > 0) || (productModel.clearanceSale?.discountAmount ?? 0) > 0;
// }

class ProductWidget extends StatefulWidget {
  final Product productModel;
  final int productNameLine;
  final double? margin;
  const ProductWidget(
      {super.key,
      required this.productModel,
      this.productNameLine = 1,
      this.margin});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _pressed = false;

  void _openProductDetails() {
    RouterHelper.getProductDetailsRoute(
      action: RouteAction.push,
      productId: widget.productModel.id,
      slug: widget.productModel.slug,
    );
  }

  Future<void> _addToCartWithQuantityOne() async {
    final Product productModel = widget.productModel;
    final bool hasConfigurableOptions =
        (productModel.choiceOptions?.isNotEmpty ?? false) ||
            (productModel.colors?.isNotEmpty ?? false) ||
            (productModel.variation?.isNotEmpty ?? false) ||
            (productModel.digitalVariation?.isNotEmpty ?? false);

    if (hasConfigurableOptions) {
      _openProductDetails();
      return;
    }

    final bool inStock = (productModel.currentStock ?? 0) > 0 ||
        productModel.productType != 'physical';
    if (!inStock) {
      showCustomSnackBar(getTranslated('out_of_stock', context), context);
      return;
    }

    final cartController = Provider.of<CartController>(context, listen: false);
    final apiResponse =
        await cartController.cartServiceInterface!.addToCartListData(
      CartModelBody(
        productId: productModel.id,
        variant: '',
        color: '',
        quantity: 1,
      ),
      productModel.choiceOptions ?? [],
      const [],
      0,
      null,
      null,
    );

    if (!mounted) {
      return;
    }

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      showCustomSnackBar(
        apiResponse.response!.data['message'],
        context,
        isError: apiResponse.response!.data['status'] == 0,
        isToaster: true,
      );
      cartController.getCartData(context);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final Color brandColor = Theme.of(context).primaryColor;
    final Product productModel = widget.productModel;
    final double ratting = (productModel.rating?.isNotEmpty ?? false)
        ? double.parse('${productModel.rating?[0].average}')
        : 0;
    final bool inStock = (productModel.currentStock ?? 0) > 0 ||
        productModel.productType != 'physical';
    final String subtitle = (productModel.unit?.isNotEmpty ?? false)
        ? productModel.unit!
        : (productModel.brand?.name ??
            getTranslated('product', context) ??
            'Product');

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openProductDetails,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: EdgeInsets.all(
                  widget.margin ?? Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: .08)),
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  LayoutBuilder(
                      builder: (context, boxConstraint) => ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Stack(children: [
                              Container(
                                margin: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall)
                                    .copyWith(bottom: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0xFFF1F3FA),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CustomImageWidget(
                                    image:
                                        '${productModel.thumbnailFullUrl?.path}',
                                    fit: BoxFit.cover,
                                    height: boxConstraint.maxWidth * 0.98,
                                    width: boxConstraint.maxWidth,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeSmall,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: inStock
                                        ? const Color(0xFFE8F9EF)
                                        : const Color(0xFFFFECEC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    inStock
                                        ? (getTranslated('in_stock', context) ??
                                            'In stock')
                                        : (getTranslated(
                                                'out_of_stock', context) ??
                                            'Out of stock'),
                                    style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: inStock
                                          ? const Color(0xFF21B66F)
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeSmall,
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AutoSizeText(
                            productModel.name ?? '',
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (ratting > 0)
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Color(0xFFF5A524), size: 16),
                                  const SizedBox(width: 2),
                                  Text(ratting.toStringAsFixed(1),
                                      style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      )),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${PriceConverter.longToShortPrice(productModel.reviewCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                                    style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor),
                                  ),
                                ]),
                          if (hasDiscount()) ...[
                            const SizedBox(height: 4),
                            Text(
                                PriceConverter.convertPrice(
                                    context, productModel.unitPrice),
                                style: titleRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                )),
                          ],
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  PriceConverter.convertPrice(
                                    context,
                                    productModel.unitPrice,
                                    discountType: (productModel.clearanceSale
                                                    ?.discountAmount ??
                                                0) >
                                            0
                                        ? productModel
                                            .clearanceSale?.discountType
                                        : productModel.discountType,
                                    discount: (productModel.clearanceSale
                                                    ?.discountAmount ??
                                                0) >
                                            0
                                        ? productModel
                                            .clearanceSale?.discountAmount
                                        : productModel.discount,
                                  ),
                                  style: robotoBold.copyWith(
                                    color: Provider.of<ThemeController>(context)
                                            .darkTheme
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : brandColor,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _addToCartWithQuantityOne,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: brandColor,
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ]),
                if (hasDiscount())
                  DiscountTagWidget(
                      productModel: productModel,
                      positionedTop: 0,
                      topLeftBorderRadius: 20,
                      bottomRightBorderRadius: 16),
                Positioned(
                  top: Dimensions.paddingSizeDefault,
                  right: isLtr ? Dimensions.paddingSizeDefault : null,
                  left: !isLtr ? Dimensions.paddingSizeDefault : null,
                  child: FavouriteButtonWidget(
                    backgroundColor:
                        Provider.of<ThemeController>(context).darkTheme
                            ? Theme.of(context).cardColor
                            : Theme.of(context).primaryColor,
                    productId: productModel.id,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  bool hasDiscount() =>
      (widget.productModel.discount != null &&
          widget.productModel.discount! > 0) ||
      (widget.productModel.clearanceSale?.discountAmount ?? 0) > 0;
}
