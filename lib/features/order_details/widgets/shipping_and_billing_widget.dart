import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';

/// Delivery address: a map strip with a pin, then clear name/phone/address rows.
class ShippingAndBillingWidget extends StatelessWidget {
  final OrderDetailsController orderProvider;

  const ShippingAndBillingWidget({super.key, required this.orderProvider});

  @override
  Widget build(BuildContext context) {
    final order = orderProvider.orders!;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    if (order.orderType == 'POS') {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.homePagePadding),
        child: Row(children: [
          Expanded(child: Text(getTranslated('pos_order', context)!,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor))),
          IconButton(
            tooltip: getTranslated('download', context),
            onPressed: orderProvider.isInvoiceLoading
                ? null
                : () => orderProvider.getOrderInvoice(order.id.toString(), context),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              backgroundColor: AppPalette.tint(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: orderProvider.isInvoiceLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded, color: AppPalette.primaryDeep, size: 20),
          ),
        ]),
      );
    }

    final address = order.shippingAddressData;
    if (address == null) return const SizedBox();

    Widget row(IconData icon, Widget child) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 17, color: AppPalette.primaryDeep),
      ),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: const EdgeInsets.only(top: 7), child: child)),
    ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 104,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(Images.mapBg, fit: BoxFit.cover),
          Container(color: Theme.of(context).cardColor.withValues(alpha: .25)),
          Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .35), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 22),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(getTranslated('delivery_address', context) ?? '',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault + 1, color: textColor)),
          const SizedBox(height: 10),
          row(Icons.person_outline_rounded, Row(children: [
            Expanded(child: Text(address.contactPersonName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor))),
            const SizedBox(width: 8),
            Text(address.phone ?? '', textDirection: TextDirection.ltr,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).hintColor)),
          ])),
          const SizedBox(height: 10),
          row(Icons.location_on_outlined, Text(address.address ?? '', maxLines: 3, overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall + 1, height: 1.6, color: textColor))),
        ]),
      ),
    ]);
  }
}
