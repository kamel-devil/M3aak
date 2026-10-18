import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/coupon_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class CouponApplyWidget extends StatelessWidget {
  final TextEditingController couponController;
  final double orderAmount;
  const CouponApplyWidget({super.key, required this.couponController, required this.orderAmount});

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponController>(
      builder: (context, couponProvider, _) {
        final bool applied = couponProvider.discount != null && couponProvider.discount != 0;
        final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

        void openSheet() => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (c) => CouponBottomSheetWidget(orderAmount: orderAmount),
        );

        return GlassContainer(
          blur: false,
          radius: 24,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: applied ? AppPalette.success.withValues(alpha: .14) : AppPalette.accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(applied ? Icons.verified_rounded : Icons.confirmation_number_outlined,
                  color: applied ? AppPalette.success : AppPalette.accent, size: 20),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: applied
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(couponProvider.couponCode, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
                      Text('− ${PriceConverter.convertPrice(context, couponProvider.discount)}',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.success)),
                    ])
                  : InkWell(
                      onTap: openSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppPalette.tint(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppPalette.glassBorder(context)),
                        ),
                        child: Text(getTranslated('have_a_coupon', context) ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                      ),
                    ),
            ),
            const SizedBox(width: 10),

            applied
                ? IconButton(
                    tooltip: getTranslated('remove', context),
                    onPressed: () => couponProvider.removeCoupon(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppPalette.error.withValues(alpha: .1),
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.close_rounded, color: AppPalette.error, size: 20),
                  )
                : PressableScale(
                    onTap: openSheet,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: textColor ?? Colors.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(getTranslated('apply', context) ?? '',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor)),
                    ),
                  ),
          ]),
        );
      },
    );
  }
}
