import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Gradient hero: order number, date, status, delivery tracker and invoice.
class OrderDetailsStatusWidget extends StatelessWidget {
  const OrderDetailsStatusWidget({super.key});

  static const Map<String, int> _progress = {
    'pending': 0,
    'confirmed': 1,
    'processing': 2,
    'out_for_delivery': 3,
    'delivered': 4,
  };

  static const List<(String, IconData)> _steps = [
    ('step_placed', Icons.schedule_rounded),
    ('step_confirmed', Icons.check_rounded),
    ('step_preparing', Icons.inventory_2_outlined),
    ('step_on_the_way', Icons.local_shipping_outlined),
    ('step_delivered', Icons.home_rounded),
  ];

  static Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFB97800);
      case 'confirmed':
        return AppPalette.primaryDeep;
      case 'processing':
        return const Color(0xFF1D5FA8);
      case 'out_for_delivery':
        return const Color(0xFF5B3FC4);
      case 'delivered':
        return const Color(0xFF11764E);
      default:
        return const Color(0xFFB4233A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsController>(builder: (context, orderProvider, _) {
      final order = orderProvider.orders!;
      final int? done = _progress[order.orderStatus];

      return FadeSlideIn(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppPalette.primaryDeep.withValues(alpha: .28),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getTranslated('order_number', context) ?? '',
                      style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall + 1)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('#${order.id}',
                        style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeOverLarge)),
                  ),
                  Text(DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(order.createdAt!)),
                      style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(
                      shape: BoxShape.circle, color: _statusColor(order.orderStatus),
                    )),
                    const SizedBox(width: 6),
                    Text(getTranslated('${order.orderStatus}', context) ?? '',
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: _statusColor(order.orderStatus))),
                  ]),
                ),
                if (order.orderType != 'POS') ...[
                  const SizedBox(height: 10),
                  Semantics(
                    button: true,
                    label: getTranslated('download', context),
                    child: PressableScale(
                      onTap: orderProvider.isInvoiceLoading
                          ? null
                          : () => orderProvider.getOrderInvoice(order.id.toString(), context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: .45)),
                        ),
                        child: orderProvider.isInvoiceLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ]),
            ]),

            if (done != null) ...[
              const SizedBox(height: 18),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (int i = 0; i < _steps.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: i <= done ? 1 : 0),
                          duration: Duration(milliseconds: 400 + 150 * i),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .28),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: v,
                              child: Container(decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(2),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 50,
                    child: Column(children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= done ? Colors.white : Colors.white.withValues(alpha: .16),
                          border: i <= done ? null : Border.all(color: Colors.white.withValues(alpha: .5), width: 1.5),
                          boxShadow: i == done
                              ? [BoxShadow(color: Colors.white.withValues(alpha: .28), spreadRadius: 5)]
                              : null,
                        ),
                        child: Icon(_steps[i].$2, size: 15,
                            color: i <= done ? AppPalette.primaryDeep : Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(getTranslated(_steps[i].$1, context) ?? '',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: (i == done ? textBold : textRegular).copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall + 1,
                              height: 1.3,
                              color: Colors.white.withValues(alpha: i <= done ? 1 : .8))),
                    ]),
                  ),
                ],
              ]),
            ],
          ]),
        ),
      );
    });
  }
}
