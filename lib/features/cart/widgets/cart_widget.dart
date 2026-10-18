import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_loader_widget.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/cart/widgets/cart_quantity_button_widget.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/min_order_quanty_widget.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class CartWidget extends StatelessWidget {
  final CartModel? cartModel;
  final int index;
  final bool fromCheckout;
  final Color highLightColor;
  const CartWidget({
    super.key,
    this.cartModel,
    required this.index,
    required this.fromCheckout,
    required this.highLightColor,
  });

  @override
  Widget build(BuildContext context) {
    bool minOrderQty = (cartModel?.productInfo?.minimumOrderQty ?? 0) > 1 &&
      (cartModel?.quantity == null || (cartModel?.quantity ?? 0)  < (cartModel?.productInfo?.minimumOrderQty ?? 1));
    final bool highlighted = highLightColor != Theme.of(context).cardColor && minOrderQty;

    return Consumer<CartController>(builder: (context, cartProvider, _) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeSmall,
          Dimensions.paddingSizeSmall,
          0,
        ),
        child: Slidable(
          key: ValueKey(cartModel?.id),
          endActionPane: ActionPane(
            extentRatio: .25,
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (value) {
                  cartProvider.removeFromCartAPI(cartModel?.id, index);
                },
                borderRadius: BorderRadius.circular(20),
                backgroundColor: AppPalette.error.withValues(alpha: 0.12),
                foregroundColor: AppPalette.error,
                icon: CupertinoIcons.delete_solid,
                label: getTranslated('delete', context),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: highlighted
                  ? highLightColor
                  : (AppPalette.isDark(context) ? Colors.white.withValues(alpha: .04) : Colors.white.withValues(alpha: .75)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (cartModel?.isChecked ?? false)
                    ? Theme.of(context).primaryColor.withValues(alpha: .35)
                    : AppPalette.glassBorder(context),
                width: 1.2,
              ),
            ),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: Checkbox(
                      key: UniqueKey(),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).primaryColor;
                        }
                        return Colors.transparent;
                      }),
                      side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                        width: 2,
                        color: (cartModel?.isChecked ?? false)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).hintColor.withValues(alpha: 0.50),
                      )),
                      checkColor: Colors.white,
                      value: cartModel!.isChecked!,
                      onChanged: (bool? value) async {
                        showDialog(
                          context: context,
                          builder: (ctx) => const CustomLoaderWidget(),
                        );
                        await cartProvider.addRemoveCartSelectedItem(
                          [cartModel!.id!],
                          cartModel!.isChecked! ? false : true,
                        );
                        Navigator.of(Get.context!).pop();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                _CartProductImageWidget(cartModel: cartModel),
                const SizedBox(width: 12),

                Expanded(child: _CartProductDetailsWidget(cartModel: cartModel, index: index)),
              ]),
              MinOrderQuantityWidget(minOrderQty: cartModel?.productInfo?.minimumOrderQty ?? 1, currentQty: cartModel?.quantity),
            ]),
          ),
        ),
      );
    });
  }
}


/// Horizontal "- qty +" stepper pill.
class _CartQuantityControlsWidget extends StatelessWidget {
  final CartModel? cartModel;
  final int index;
  const _CartQuantityControlsWidget({
    required this.cartModel,
    required this.index,
  });

  Widget _spinner(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SizedBox(
      width: 14, height: 14,
      child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppPalette.tint(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        cartModel?.decrement ?? false ? _spinner(context) : CartQuantityButton(
          isIncrement: false,
          index: index,
          quantity: cartModel!.quantity,
          maxQty: cartModel!.productInfo!.totalCurrentStock,
          cartModel: cartModel,
          minimumOrderQuantity: cartModel!.productInfo!.minimumOrderQty,
          digitalProduct: cartModel!.productType == "digital" ? true : false,
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Container(
            key: ValueKey(cartModel!.quantity),
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              cartModel!.quantity.toString(),
              style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ),

        cartModel?.increment ?? false ? _spinner(context) : CartQuantityButton(
          index: index,
          isIncrement: true,
          quantity: cartModel!.quantity,
          maxQty: cartModel!.productInfo?.totalCurrentStock,
          cartModel: cartModel,
          minimumOrderQuantity: cartModel!.productInfo!.minimumOrderQty,
          digitalProduct: cartModel!.productType == "digital" ? true : false,
        ),
      ]),
    );
  }
}


class _CartProductDetailsWidget extends StatelessWidget {
  final CartModel? cartModel;
  final int index;
  const _CartProductDetailsWidget({required this.cartModel, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool shopClosed = cartModel!.shop != null &&
        (cartModel!.shop!.temporaryClose! || cartModel!.shop!.vacationStatus!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: cartModel?.productId, slug: cartModel?.slug);
          },
          child: Text(
            cartModel!.name!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              height: 1.3,
              color: shopClosed ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),

        // Variation
        if (cartModel!.variant != null && cartModel!.variant!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cartModel?.variant ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
            ),
          ),

        // Shipping cost
        if (cartModel!.shippingType != 'order_wise')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.local_shipping_outlined, size: 14, color: Theme.of(context).hintColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${getTranslated('shipping_cost', context)}: ${PriceConverter.convertPrice(context, cartModel!.shippingCost)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),
              ),
            ]),
          ),

        // Out of stock warning
        if (cartModel!.quantity! > cartModel!.productInfo!.totalCurrentStock! && cartModel?.productType == "physical")
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "${getTranslated("out_of_stock", context)}",
              style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.error),
            ),
          ),

        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              if (cartModel!.discount! > 0)
                Text(
                  PriceConverter.convertPrice(context, cartModel!.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  PriceConverter.convertPrice(context, cartModel!.price, discount: cartModel!.discount, discountType: 'amount'),
                  maxLines: 1,
                  style: robotoBold.copyWith(
                    color: shopClosed ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ]),
          ),
          _CartQuantityControlsWidget(cartModel: cartModel, index: index),
        ]),
      ],
    );
  }
}

class _CartProductImageWidget extends StatelessWidget {
  final CartModel? cartModel;
  const _CartProductImageWidget({required this.cartModel});

  @override
  Widget build(BuildContext context) {
    const double size = 82;
    return InkWell(
      onTap: () {
        RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: cartModel?.productId, slug: cartModel?.slug);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
          border: Border.all(color: AppPalette.tint(context), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(fit: StackFit.expand, children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(image: '${cartModel?.productInfo?.thumbnailFullUrl?.path}', fit: BoxFit.cover),
              ),
            ),
            if (cartModel!.isProductAvailable! == 0)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: Text(
                  "${getTranslated("not_available", context)}",
                  textAlign: TextAlign.center,
                  style: textMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
