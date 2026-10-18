import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/features/order_details/widgets/order_details_widget.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Ordered items; long orders show the first few with a "show all" toggle.
class OrderProductListWidget extends StatefulWidget {
  final String? orderType;
  final String? orderId;
  final bool fromTrack;
  final int? isGuest;
  const OrderProductListWidget({super.key, this.orderType,  this.fromTrack = false, this.isGuest, this.orderId});

  @override
  State<OrderProductListWidget> createState() => _OrderProductListWidgetState();
}

class _OrderProductListWidgetState extends State<OrderProductListWidget> {
  static const int _collapsedCount = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsController>(
      builder: (context, orderDetailsController, _) {
        final int total = orderDetailsController.orderDetails!.length;
        final bool collapsible = total > _collapsedCount + 1;
        final int shown = (!collapsible || _expanded) ? total : _collapsedCount;

        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: shown,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) => OrderDetailsWidget(
                orderDetailsModel: orderDetailsController.orderDetails![i],
                isGuest: widget.isGuest,
                fromTrack: widget.fromTrack,
                callback: () {showCustomSnackBar('${getTranslated('review_submitted_successfully', context)}', context, isError: false);},
                orderType: widget.orderType!,
                paymentStatus: orderDetailsController.orders!.paymentStatus!,
                orderId: widget.orderId!,
                index: i,
              ),
            ),
          ),
          if (collapsible)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: OutlinedButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: .45)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    _expanded
                        ? getTranslated('show_less', context) ?? ''
                        : '${getTranslated('show_all_products', context)} ($total)',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: AppPalette.primaryDeep),
                  ),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppPalette.primaryDeep),
                ]),
              ),
            ),
        ]);
      },
    );
  }
}
