import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/checkout_ui.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class ChoosePaymentWidget extends StatelessWidget {
  final bool onlyDigital;
  const ChoosePaymentWidget({super.key, required this.onlyDigital});

  @override
  Widget build(BuildContext context) {
    void openSheet() => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => PaymentMethodBottomSheetWidget(onlyDigital: onlyDigital),
    );

    return Consumer<CheckoutController>(
      builder: (context, orderProvider, _) {
        return Consumer<SplashController>(
          builder: (context, configProvider, _) {
            final config = configProvider.configModel;
            Widget? leading;
            String? title;
            String? subtitle;
            IconData icon = Icons.payments_outlined;

            if (orderProvider.paymentMethodIndex != -1) {
              final data = config!.paymentMethods![orderProvider.paymentMethodIndex].additionalDatas;
              title = data?.gatewayTitle ?? '';
              subtitle = getTranslated('digital_payment', context);
              leading = Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: CustomImageWidget(image: '${config.paymentMethodImagePath}/${data?.gatewayImage ?? ''}', fit: BoxFit.contain),
              );
            } else if (orderProvider.isCODChecked) {
              title = getTranslated('cash_on_delivery', context);
              subtitle = getTranslated('cash_on_delivery_hint', context);
              icon = Icons.payments_outlined;
            } else if (orderProvider.isOfflineChecked) {
              title = getTranslated('offline_payment', context);
              subtitle = getTranslated('offline_payment_hint', context);
              icon = Icons.account_balance_outlined;
            } else if (orderProvider.isWalletChecked) {
              title = getTranslated('wallet_payment', context);
              subtitle = getTranslated('wallet_payment_hint', context);
              icon = Icons.account_balance_wallet_outlined;
            }

            return CheckoutCard(
              icon: Icons.credit_card_rounded,
              iconColor: AppPalette.secondary,
              title: getTranslated('payment_method', context),
              trailing: title != null ? CheckoutChangeButton(onTap: openSheet) : null,
              child: title != null
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                      ),
                      child: Row(children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title, style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color,
                          )),
                          if ((subtitle ?? '').isNotEmpty)
                            Text(subtitle!, style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                            )),
                        ])),
                        const SizedBox(width: 8),
                        leading ?? Icon(icon, color: AppPalette.primaryDeep, size: 26),
                      ]),
                    )
                  : PressableScale(
                      onTap: openSheet,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppPalette.tint(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.glassBorder(context)),
                        ),
                        child: Row(children: [
                          Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(getTranslated('choose_payment_method', context) ?? '',
                              style: textMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                          Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor),
                        ]),
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
