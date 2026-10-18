import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/shipping_details_widget.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Verification code box plus order type / payment status / method tiles.
class OrderPaymentInfoWidget extends StatelessWidget {
  const OrderPaymentInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsController>(
      builder: (context, orderProvider, child) {
        final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;
        final order = orderProvider.orders!;
        final bool showCode = configModel?.orderVerification == 1 && order.orderType != 'POS'
            && (order.verificationCode ?? '').isNotEmpty;
        final bool paid = order.paymentStatus == 'paid';
        final String method = order.paymentMethod ?? '';
        final String? translatedMethod = method.isEmpty ? null : getTranslated(method, context);
        final String methodLabel = (translatedMethod == null || translatedMethod == method)
            ? (method.isEmpty ? '' : method.replaceAll('_', ' ').capitalize())
            : translatedMethod;
        final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

        Widget tile(String label, String value, {Color? valueColor, Color? bg}) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: bg ?? AppPalette.tint(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: Theme.of(context).hintColor)),
              const SizedBox(height: 4),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: valueColor ?? textColor)),
            ]),
          ),
        );

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (showCode) ...[
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .35)),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(getTranslated('verification_code_hint', context) ?? '',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                    Text(order.verificationCode ?? '',
                        textDirection: TextDirection.ltr,
                        style: textBold.copyWith(fontSize: 24, letterSpacing: 6, color: textColor)),
                  ])),
                  IconButton(
                    tooltip: getTranslated('copy', context),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: order.verificationCode ?? ''));
                      showCustomSnackBar(getTranslated('copied', context), context, isError: false);
                    },
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      backgroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppPalette.primaryDeep),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            Row(children: [
              tile(getTranslated('order_type', context) ?? '',
                  order.orderType == 'POS' ? getTranslated('pos_order_small', context) ?? '' : getTranslated('regular', context) ?? ''),
              const SizedBox(width: 8),
              tile(
                getTranslated('PAYMENT_STATUS', context) ?? '',
                (order.paymentStatus ?? '').isNotEmpty
                    ? getTranslated(order.paymentStatus, context) ?? order.paymentStatus!
                    : getTranslated('digital_payment', context) ?? '',
                valueColor: paid ? AppPalette.success : AppPalette.error,
                bg: (paid ? AppPalette.success : AppPalette.error).withValues(alpha: .09),
              ),
              const SizedBox(width: 8),
              tile(getTranslated('payment_method', context) ?? '', methodLabel),
            ]),
          ]),
        );
      },
    );
  }
}
