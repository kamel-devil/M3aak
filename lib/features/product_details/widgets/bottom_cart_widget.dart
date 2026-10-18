import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/helper/product_helper.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/features/product_details/domain/models/product_details_model.dart';
import 'package:kk_thotix_m3aak/features/product_details/widgets/cart_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/helper/shop_helper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class BottomCartWidget extends StatefulWidget {
  final ProductDetailsModel? product;
  const BottomCartWidget({super.key, required this.product});

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget> {
  bool vacationIsOn = false;
  bool temporaryClose = false;

  @override
  void initState() {
    super.initState();

    vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: widget.product?.seller?.shop?.vacationStartDate,
      endDate: widget.product?.seller?.shop?.vacationEndDate,
      vacationDurationType: widget.product?.seller?.shop?.vacationDurationType,
      vacationStatus: widget.product?.seller?.shop?.vacationStatus,
      isInHouseSeller: widget.product?.addedBy == 'admin',
    );


    if(widget.product?.addedBy == 'admin') {
      if(widget.product != null && (Provider.of<SplashController>(context, listen: false).configModel?.inhouseTemporaryClose?.status ?? false)){
        temporaryClose = true;
      }else{
        temporaryClose = false;
      }
    } else {
      if(widget.product != null && widget.product!.seller != null && widget.product!.seller!.shop!.temporaryClose!){
        temporaryClose = true;
      }else{
        temporaryClose = false;
      }
    }
  }


  void _openCartSheet() {
    if (vacationIsOn || temporaryClose) {
      showCustomSnackBar(getTranslated('this_shop_is_close_now', context), context, isToaster: true);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (con) => CartBottomSheetWidget(
        product: widget.product,
        callback: () => showCustomSnackBar(getTranslated('added_to_cart', context), context, isError: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color ink = Theme.of(context).textTheme.bodyLarge!.color!;
    final p = widget.product;
    final range = ProductHelper.getProductPriceRange(p);
    final bool clearance = (p?.clearanceSale?.discountAmount ?? 0) > 0;
    final String? price = range.start == null ? null : PriceConverter.convertPrice(
      context,
      range.start,
      discount: clearance ? p?.clearanceSale?.discountAmount : p?.discount,
      discountType: clearance ? p?.clearanceSale?.discountType : p?.discountType,
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppPalette.isDark(context) ? const Color(0xF20E2328) : Colors.white.withValues(alpha: .96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
          boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .12), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: Row(children: [
          // Cart shortcut with live badge.
          PressableScale(
            onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppPalette.tint(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                Icon(Icons.shopping_bag_outlined, color: ink, size: 24),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: Consumer<CartController>(builder: (context, cart, _) {
                    if (cart.cartList.isEmpty) return const SizedBox.shrink();
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(cart.cartList.length),
                      tween: Tween(begin: .4, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                        constraints: BoxConstraints(minWidth: ResponsiveHelper.isTab(context) ? 22 : 18),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: AppPalette.offerGradient,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text('${cart.cartList.length}',
                            textAlign: TextAlign.center,
                            style: textBold.copyWith(fontSize: 9, color: Colors.white)),
                      ),
                    );
                  }),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 10),

          // Primary action.
          Expanded(
            child: PressableScale(
              onTap: _openCartSheet,
              scale: .97,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primary.withValues(alpha: .35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(children: [
                  const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(getTranslated('add_to_cart', context)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
                  ),
                  if (price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(price, style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white)),
                    ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
