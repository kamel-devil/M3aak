import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/checkout_ui.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

class OrderAmountCalculation extends StatelessWidget {
  final double itemTotalAmount;
  final double discount;
  final double? eeDiscount;
  final double tax;
  final double shippingCost;
  final double referAndEarnDiscount;
  final OrderDetailsController orderProvider;
  const OrderAmountCalculation(
      {super.key,
      required this.itemTotalAmount,
      required this.discount,
      this.eeDiscount,
      required this.tax,
      required this.shippingCost,
      required this.orderProvider,
      required this.referAndEarnDiscount});

  @override
  Widget build(BuildContext context) {
    final order = orderProvider.orders!;
    final bool pos = order.orderType == "POS";
    final double coupon = order.discountAmount ?? 0;
    final double total = itemTotalAmount + shippingCost - referAndEarnDiscount - (eeDiscount ?? 0) - coupon - discount + tax;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    String minus(double v) => '${v > 0 ? '− ' : ''}${PriceConverter.convertPrice(context, v)}';
    Color? saving(double v) => v > 0 ? AppPalette.success : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(getTranslated('payment_summary', context) ?? '',
            style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
        const SizedBox(height: 6),
        CheckoutSummaryRow(label: getTranslated('sub_total', context) ?? '',
            value: PriceConverter.convertPrice(context, itemTotalAmount)),
        if (!pos)
          CheckoutSummaryRow(label: getTranslated('shipping_fee', context) ?? '',
              value: PriceConverter.convertPrice(context, shippingCost)),
        CheckoutSummaryRow(label: getTranslated('discount', context) ?? '', value: minus(discount), valueColor: saving(discount)),
        if (pos)
          CheckoutSummaryRow(label: getTranslated('extra_discount', context) ?? '',
              value: minus(eeDiscount ?? 0), valueColor: saving(eeDiscount ?? 0)),
        CheckoutSummaryRow(label: getTranslated('coupon_voucher', context) ?? '', value: minus(coupon), valueColor: saving(coupon)),
        CheckoutSummaryRow(label: getTranslated('tax', context) ?? '', value: PriceConverter.convertPrice(context, tax)),
        if (referAndEarnDiscount > 0)
          CheckoutSummaryRow(label: getTranslated('referral_discount', context) ?? '',
              value: minus(referAndEarnDiscount), valueColor: AppPalette.success),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1.2, color: AppPalette.glassBorder(context)),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getTranslated('total_payable', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
            if (order.taxModel == 'include')
              Text(getTranslated('inc_vat_tax', context) ?? '',
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
          ])),
          const SizedBox(width: 12),
          Text(PriceConverter.convertPrice(context, total),
              style: textBold.copyWith(fontSize: 22, color: AppPalette.primaryDeep)),
        ]),

        if (pos) ...[
          const SizedBox(height: 8),
          CheckoutSummaryRow(label: getTranslated('paid_amount', context) ?? '',
              value: PriceConverter.convertPrice(context, order.paidAmount)),
          CheckoutSummaryRow(label: getTranslated('change_amount', context) ?? '',
              value: PriceConverter.convertPrice(context,
                  (order.paidAmount ?? 0) - double.parse((itemTotalAmount + shippingCost - (eeDiscount ?? 0) - coupon - discount + tax).toStringAsFixed(2)))),
        ],
      ]),
    );
  }
}
