import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/order/domain/models/order_model.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/reorder/controllers/re_order_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';


class OrderWidget extends StatelessWidget {
  final Orders? orderModel;
  const OrderWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {

    double orderAmount = 0;
    double tax = 0;

    if(orderModel?.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;

      double coupon = 0;
      double shipping = 0;
      if (orderModel?.details != null && orderModel!.details!.isNotEmpty ) {
        coupon = orderModel?.discountAmount ?? 0;
        shipping = orderModel?.shippingCost ?? 0;
        tax = orderModel?.totalTaxAmount ?? 0;

        for (var orderDetails in orderModel!.details!) {
          itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.qty!);
          discount = discount + orderDetails.discount!;
          // tax = tax + orderDetails.tax!;
        }
        if(orderModel!.orderType == 'POS'){
          if(orderModel!.extraDiscountType == 'percent'){
            eeDiscount = itemsPrice * (orderModel!.extraDiscount!/100);
          }else{
            eeDiscount = orderModel!.extraDiscount;
          }
        }
      }
      double subTotal = itemsPrice +tax - discount;

      orderAmount = subTotal + shipping - coupon - eeDiscount!;




      // double ? _extraDiscountAnount = 0;
      // if(orderModel.extraDiscount != null){
      //   _extraDiscountAnount = PriceConverter.convertWithDiscount(context, orderModel.totalProductPrice, orderModel.extraDiscount, orderModel.extraDiscountType == 'percent' ? 'percent' : 'amount' );
      //   if(_extraDiscountAnount != null) {
      //     double percentAmount = _extraDiscountAnount!;
      //     _extraDiscountAnount = orderModel.totalProductPrice! - percentAmount;
      //   }
      // }
      //
      // double totalDiscount = (_extraDiscountAnount! + orderModel.totalProductDiscount!);
      // double totalOrderAmount = (orderModel.totalProductPrice! + orderModel.totalTaxAmount!);
      //
      // orderAmount = totalOrderAmount - totalDiscount;
      //
      // orderAmount = orderModel.orderAmount! - orderModel.totalTaxAmount!;


    }




    final Orders order = orderModel!;
    final _StatusStyle status = _StatusStyle.of(order.orderStatus);
    final bool running = _StatusStyle.runningSteps.containsKey(order.orderStatus);
    final bool delivered = order.orderStatus == 'delivered';
    final bool canReorder = delivered && order.orderType != 'POS';
    final String shopImage = order.sellerIs == 'admin'
        ? Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.imageFullUrl?.path ?? ''
        : '${order.seller?.shop?.imageFullUrl?.path}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall + 2),
      child: PressableScale(
        scale: .98,
        haptic: false,
        onTap: () => RouterHelper.getOrderDetailsScreenRoute(action: RouteAction.push, orderId: order.id!),
        child: GlassContainer(
          blur: false,
          radius: 24,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header: shop, number, date, status.
            Row(children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.tint(context), width: 1.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: CustomImageWidget(
                    image: shopImage,
                    fit: BoxFit.contain,
                    placeholder: Images.pharmacyIcon,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${getTranslated('order', context)} #${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: 2),
                  Text(DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(order.createdAt!)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: AppPalette.isDark(context) ? .22 : .13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(getTranslated('${order.orderStatus}', context) ?? '',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: status.color)),
              ),
            ]),

            // Progress tracker for running orders.
            if (running) ...[
              const SizedBox(height: 14),
              _OrderTracker(doneSteps: _StatusStyle.runningSteps[order.orderStatus]!),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Theme.of(context).dividerColor),
            ),

            // Footer: count, total, action.
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${order.orderDetailsCount ?? 0} ${getTranslated('products', context)}',
                      style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      PriceConverter.convertPrice(
                          context, order.orderType == 'POS' ? orderAmount : order.orderAmount),
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ]),
              ),
              if (running && order.orderType != 'POS')
                _OrderAction(
                  label: getTranslated('TRACK_ORDER', context) ?? '',
                  onTap: () => RouterHelper.getTrackingResultRoute(
                      action: RouteAction.push, orderID: order.id.toString()),
                )
              else if (canReorder)
                Consumer<ReOrderController>(builder: (context, reorder, _) {
                  return _OrderAction(
                    label: getTranslated('re_order', context) ?? '',
                    filled: true,
                    loading: reorder.isLoading,
                    onTap: () => reorder.reorder(orderId: order.id.toString()),
                  );
                })
              else
                _OrderAction(
                  label: getTranslated('details', context) ?? '',
                  onTap: () => RouterHelper.getOrderDetailsScreenRoute(
                      action: RouteAction.push, orderId: order.id!),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Status colour + how far along the delivery tracker a running order is.
class _StatusStyle {
  const _StatusStyle(this.color);
  final Color color;

  static const Map<String, int> runningSteps = {
    'pending': 0,
    'confirmed': 1,
    'processing': 2,
    'out_for_delivery': 3,
  };

  static _StatusStyle of(String? status) {
    switch (status) {
      case 'pending':
        return const _StatusStyle(Color(0xFFB97800));
      case 'confirmed':
        return const _StatusStyle(AppPalette.primaryDeep);
      case 'processing':
        return const _StatusStyle(Color(0xFF1D5FA8));
      case 'out_for_delivery':
        return const _StatusStyle(Color(0xFF5B3FC4));
      case 'delivered':
        return const _StatusStyle(Color(0xFF11764E));
      case 'canceled':
      case 'failed':
      case 'fail_to_delivered':
      case 'returned':
        return const _StatusStyle(Color(0xFFB4233A));
      default:
        return const _StatusStyle(AppPalette.lightInkSoft);
    }
  }
}

class _OrderTracker extends StatelessWidget {
  const _OrderTracker({required this.doneSteps});
  final int doneSteps;

  static const List<String> _keys = ['step_confirmed', 'step_preparing', 'step_on_the_way', 'step_delivered'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        for (int i = 0; i < _keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: i < doneSteps ? 1 : 0),
              duration: Duration(milliseconds: 500 + i * 180),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppPalette.tint(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ]),
      const SizedBox(height: 6),
      Row(children: [
        for (int i = 0; i < _keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Text(getTranslated(_keys[i], context) ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: (i < doneSteps ? textMedium : textRegular).copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall + 0.5,
                  color: i < doneSteps ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                )),
          ),
        ],
      ]),
    ]);
  }
}

class _OrderAction extends StatelessWidget {
  const _OrderAction({required this.label, required this.onTap, this.filled = false, this.loading = false});

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: loading ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 96),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled ? AppPalette.brandGradient : null,
          color: filled ? null : AppPalette.tint(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: filled
              ? [BoxShadow(color: AppPalette.primary.withValues(alpha: .30), blurRadius: 12, offset: const Offset(0, 5))]
              : null,
        ),
        child: loading
            ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: filled ? Colors.white : Theme.of(context).primaryColor,
                )),
      ),
    );
  }
}
