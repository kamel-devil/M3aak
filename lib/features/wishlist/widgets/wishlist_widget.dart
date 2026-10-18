import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_directionality_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/wishlist/domain/models/wishlist_model.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/wishlist/widgets/remove_from_wishlist_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';

/// Wishlist grid card: image with remove heart, discount tag, name, price, cart button.
class WishListWidget extends StatelessWidget {
  final WishlistModel? wishlistModel;
  final int? index;
  const WishListWidget({super.key, this.wishlistModel, this.index});

  @override
  Widget build(BuildContext context) {
    final product = wishlistModel?.productFullInfo;
    final bool clearance = (product?.clearanceSale?.discountAmount ?? 0) > 0;
    final bool hasDiscount = (product?.discount ?? 0) > 0 || clearance;
    final bool outOfStock = product?.productType != 'digital' && (product?.currentStock ?? 0) < 1;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    void openDetails() => RouterHelper.getProductDetailsRoute(
      action: RouteAction.push,
      productId: product?.id,
      slug: product?.slug,
      isFromWishList: true,
    );

    final String discountLabel = !hasDiscount ? '' : (clearance
        ? PriceConverter.percentageCalculation(context, product?.unitPrice, product?.clearanceSale?.discountAmount, product?.clearanceSale?.discountType)
        : PriceConverter.percentageCalculation(context, product?.unitPrice, product?.discount, product?.discountType));

    return PressableScale(
      onTap: openDetails,
      child: GlassContainer(
        blur: false,
        radius: 22,
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1.08,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(fit: StackFit.expand, children: [
                Container(
                  color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: CustomImageWidget(image: '${product?.thumbnailFullUrl?.path}', fit: BoxFit.contain),
                ),
                if (outOfStock)
                  Container(
                    color: Colors.white.withValues(alpha: .55),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppPalette.error, borderRadius: BorderRadius.circular(8)),
                      child: Text(getTranslated('stock_out', context) ?? '',
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall + 1)),
                    ),
                  ),
                if (hasDiscount)
                  PositionedDirectional(
                    top: 6,
                    start: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(gradient: AppPalette.offerGradient, borderRadius: BorderRadius.circular(8)),
                      child: Text(discountLabel, textDirection: TextDirection.ltr,
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)),
                    ),
                  ),
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: IconButton(
                    tooltip: getTranslated('remove', context),
                    onPressed: () => showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (_) => RemoveFromWishlistBottomSheet(productId: product?.id, index: index),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      minimumSize: const Size(36, 36),
                      fixedSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.favorite_rounded, color: AppPalette.accent, size: 19),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text(product?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall + 1, height: 1.4, color: textColor)),
          const Spacer(),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: CustomDirectionalityWidget(child: Text(_getProductPrice(context),
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: AppPalette.primaryDeep))),
              ),
              if (hasDiscount)
                CustomDirectionalityWidget(child: Text(PriceConverter.convertPrice(context, product?.unitPrice),
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      color: Theme.of(context).hintColor,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Theme.of(context).hintColor,
                    ))),
            ])),
            const SizedBox(width: 6),
            Semantics(
              button: true,
              label: getTranslated('add_to_cart', context),
              child: InkWell(
                onTap: openDetails,
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: outOfStock ? null : AppPalette.brandGradient,
                    color: outOfStock ? Theme.of(context).hintColor.withValues(alpha: .2) : null,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.add_shopping_cart_rounded, size: 17,
                      color: outOfStock ? Theme.of(context).hintColor : Colors.white),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  String _getProductPrice(BuildContext context) {
    final product = wishlistModel?.productFullInfo;
    final bool clearance = (product?.clearanceSale?.discountAmount ?? 0) > 0;
    return PriceConverter.convertPrice(
      context, product?.unitPrice,
      discountType: clearance ? product?.clearanceSale?.discountType : product?.discountType,
      discount: clearance ? product?.clearanceSale?.discountAmount : product?.discount,
    );
  }
}
