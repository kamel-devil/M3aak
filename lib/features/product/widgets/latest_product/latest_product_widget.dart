import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/discount_tag_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/favourite_button_widget.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/controllers/localization_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/color_resources.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

class LatestProductWidget extends StatefulWidget {
  final Product productModel;
  const LatestProductWidget({super.key, required this.productModel});

  @override
  State<LatestProductWidget> createState() => _LatestProductWidgetState();
}

class _LatestProductWidgetState extends State<LatestProductWidget> {
  bool _pressed = false;

  void _addToCart() {
    final AuthController authController =
        Provider.of<AuthController>(context, listen: false);

    if (!authController.isLoggedIn()) {
      showCustomSnackBar(
          getTranslated('please_login_first', context) ?? 'Please login first',
          context);
      return;
    }

    final Product p = widget.productModel;
    final CartModelBody cart = CartModelBody(
      productId: p.id,
      variant:
          p.colors != null && p.colors!.isNotEmpty ? p.colors![0].name : '',
      color: p.colors != null && p.colors!.isNotEmpty ? p.colors![0].code : '',
      quantity: 1,
    );

    Provider.of<CartController>(context, listen: false).addToCartAPI(
      cart,
      context,
      p.choiceOptions ?? [],
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr =
        Provider.of<LocalizationController>(context, listen: false).isLtr;
    final Color brandColor = Theme.of(context).primaryColor;
    final Product p = widget.productModel;
    final double rating = p.rating?.isNotEmpty == true
        ? double.tryParse(p.rating![0].average ?? '0') ?? 0
        : 0;
    final bool inStock =
        (p.currentStock ?? 0) > 0 || p.productType != 'physical';
    final bool hasDiscount = (p.discount != null && p.discount! > 0) ||
        (p.clearanceSale?.discountAmount ?? 0) > 0;
    final imgSize = ResponsiveHelper.isTab(context) ? 110.0 : 90.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => RouterHelper.getProductDetailsRoute(
        action: RouteAction.push,
        productId: p.id,
        slug: p.slug!,
      ),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: .07)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                      child: Stack(
                        children: [
                          CustomImageWidget(
                            image: '${p.thumbnailFullUrl?.path}',
                            height: imgSize,
                            width: imgSize,
                            fit: BoxFit.cover,
                          ),
                          if (!inStock)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withValues(alpha: .45),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Text(
                                    getTranslated('out_of_stock', context) ??
                                        '',
                                    style: textBold.copyWith(
                                        color: Colors.white,
                                        fontSize:
                                            Dimensions.fontSizeExtraSmall),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rating row
                            if (rating > 0) ...[
                              Row(children: [
                                const Icon(Icons.star_rounded,
                                    color: ColorResources.starRating, size: 13),
                                const SizedBox(width: 2),
                                Text(rating.toStringAsFixed(1),
                                    style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)),
                                const SizedBox(width: 2),
                                Text('(${p.reviewCount ?? 0})',
                                    style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor)),
                              ]),
                              const SizedBox(height: 3),
                            ],

                            // Name
                            Text(
                              p.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                height: 1.3,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Prices + add button
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (hasDiscount)
                                        Text(
                                          PriceConverter.convertPrice(
                                              context, p.unitPrice),
                                          style: textRegular.copyWith(
                                            color: Theme.of(context).hintColor,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor:
                                                Theme.of(context).hintColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      Text(
                                        PriceConverter.convertPrice(
                                          context,
                                          p.unitPrice,
                                          discountType: (p.clearanceSale
                                                          ?.discountAmount ??
                                                      0) >
                                                  0
                                              ? p.clearanceSale?.discountType
                                              : p.discountType,
                                          discount: (p.clearanceSale
                                                          ?.discountAmount ??
                                                      0) >
                                                  0
                                              ? p.clearanceSale?.discountAmount
                                              : p.discount,
                                        ),
                                        style: textBold.copyWith(
                                          color: brandColor,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: _addToCart,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: brandColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.add_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Discount tag
              if (hasDiscount)
                DiscountTagWidget(
                  productModel: p,
                  positionedTop: 0,
                  topLeftBorderRadius: 20,
                  bottomRightBorderRadius: 12,
                ),

              // Favourite
              Positioned(
                top: 6,
                right: isLtr ? 8 : null,
                left: !isLtr ? 8 : null,
                child: FavouriteButtonWidget(
                  backgroundColor: Theme.of(context).primaryColor,
                  productId: p.id,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
