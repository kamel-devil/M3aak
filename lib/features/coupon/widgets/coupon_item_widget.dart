import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/coupon/domain/models/coupon_item_model.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/date_converter.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Ticket-style coupon: coloured value stub, conditions, dashed code with copy.
class CouponItemWidget extends StatelessWidget {
  final Coupons coupons;
  final bool fromCheckout;
  final Function(String?)? onCopy;
  const CouponItemWidget({super.key, required this.coupons,  this.fromCheckout = false, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final bool freeDelivery = coupons.couponType == 'free_delivery';
    final bool percent = coupons.discountType == 'percentage';
    final DateTime? expiry = DateTime.tryParse(coupons.planExpireDate ?? '');
    final bool expired = expiry != null && expiry.isBefore(DateTime.now());
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    final LinearGradient stubGradient = expired
        ? const LinearGradient(colors: [Color(0xFFB9C7C5), Color(0xFF9DB0AD)])
        : freeDelivery
            ? AppPalette.offerGradient
            : AppPalette.brandGradient;

    final String shop = coupons.seller != null
        ? coupons.seller?.shop?.name ?? ''
        : coupons.sellerId == 0
            ? getTranslated('on_all_shop', context) ?? ''
            : Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name ?? AppConstants.appName;

    Future<void> copy() async {
      onCopy?.call(coupons.code);
      await Clipboard.setData(ClipboardData(text: coupons.code ?? ''));
      if (context.mounted && onCopy == null) {
        showCustomSnackBar(getTranslated('copied', context), context, isError: false);
      }
    }

    return Padding(
      padding: fromCheckout ? const EdgeInsets.only(top: 10) : const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Opacity(
        opacity: expired ? .6 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppPalette.glassBorder(context)),
            boxShadow: AppPalette.softShadow(context),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(gradient: stubGradient),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (freeDelivery) ...[
                      const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(getTranslated('free_delivery', context) ?? '', textAlign: TextAlign.center,
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                    ] else ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(percent ? '${coupons.discount?.toStringAsFixed(0)}%' : PriceConverter.convertPrice(context, coupons.discount),
                            textDirection: TextDirection.ltr,
                            style: textBold.copyWith(color: Colors.white, fontSize: 24, height: 1.1)),
                      ),
                      const SizedBox(height: 2),
                      Text(getTranslated('off', context) ?? '',
                          style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ]),
                ),
                CustomPaint(size: const Size(2, double.infinity), painter: _DashPainter(AppPalette.glassBorder(context))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((coupons.title ?? '').isNotEmpty ? coupons.title! : shop,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
                      const SizedBox(height: 2),
                      Text('${getTranslated('available_from', context)} ${PriceConverter.convertPrice(context, coupons.minPurchase)} · $shop',
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .35)),
                            ),
                            child: Text(coupons.code ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.ltr,
                                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, letterSpacing: 1.5, color: AppPalette.primaryDeep)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: expired ? null : copy,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(52, 36),
                            backgroundColor: textColor,
                            foregroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(getTranslated('copy', context) ?? '',
                              style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                        ),
                      ]),
                      if (coupons.planExpireDate != null) ...[
                        const SizedBox(height: 6),
                        Text(expired
                                ? getTranslated('expired', context) ?? ''
                                : '${getTranslated('valid_till', context)} ${DateConverter.estimatedDateYear(DateTime.parse(coupons.planExpireDate!))}',
                            style: textMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1,
                                color: expired ? Theme.of(context).hintColor : const Color(0xFFA15C00))),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2;
    double y = 6;
    while (y < size.height - 6) {
      canvas.drawLine(Offset(1, y), Offset(1, y + 5), paint);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}
