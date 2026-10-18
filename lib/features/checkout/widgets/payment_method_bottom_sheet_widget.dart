
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/common/basewidget/no_internet_screen_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/change_amount_widget.dart';
import 'package:kk_thotix_m3aak/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/custom_check_box_widget.dart';
import 'package:provider/provider.dart';

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final bool onlyDigital;
  const PaymentMethodBottomSheetWidget({super.key, required this.onlyDigital,});
  @override
  PaymentMethodBottomSheetWidgetState createState() => PaymentMethodBottomSheetWidgetState();
}
class PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  final TextEditingController changeAmountTextController = TextEditingController();
  final ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;
  CheckoutController checkoutController = Provider.of<CheckoutController>(Get.context!, listen: false);

  @override
  void initState() {
    changeAmountTextController.text = '${Provider.of<CheckoutController>(context, listen: false).cashChangesAmount ?? ''}';
    final bool hasOfflineMethods = checkoutController.offlinePaymentModel?.offlineMethods?.isNotEmpty ?? false;

    if (hasOfflineMethods) {
      if (!checkoutController.isOfflineChecked) {
        checkoutController.setOfflineChecked('offline', notify: false);
      }
      if (checkoutController.offlineMethodSelectedIndex < 0) {
        checkoutController.setOfflinePaymentMethodSelectedIndex(0, notify: false);
      }
    } else if((configModel?.cashOnDelivery ?? false) && !widget.onlyDigital && !checkoutController.isCODChecked) {
      checkoutController.setOfflineChecked('cod', notify: false);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Consumer<CheckoutController>(
      builder: (context, checkoutController, _) {
        final offlineMethods = checkoutController.offlinePaymentModel?.offlineMethods ?? [];
        final bool showCod = (configModel?.cashOnDelivery ?? false) && !widget.onlyDigital;
        final bool showWallet = configModel?.walletStatus == 1 && Provider.of<AuthController>(context, listen: false).isLoggedIn();
        final bool showOffline = configModel?.offlinePayment != null && offlineMethods.isNotEmpty;
        final bool showDigital = (configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false);

        return PopScope(
          onPopInvokedWithResult: (_, __){
            if(checkoutController.isCODChecked) {
              checkoutController.onChangeCashChangesAmount(double.tryParse(changeAmountTextController.text));
            }else {
              checkoutController.onChangeCashChangesAmount(null);
            }
          },
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Theme.of(context).hintColor.withValues(alpha: .35),
                ))),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: Text(getTranslated('choose_payment_method', context) ?? '',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: textColor))),
                  IconButton(
                    tooltip: getTranslated('close', context),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppPalette.tint(context),
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(Icons.close_rounded, size: 20, color: textColor),
                  ),
                ]),
                const SizedBox(height: 12),

                Flexible(
                  child: SingleChildScrollView(
                    child: _isPaymentMethodsAvailable(Get.context!, offlineMethods)
                        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                            if (showCod) ...[
                              _PaymentOption(
                                icon: Icons.payments_outlined,
                                color: AppPalette.primary,
                                title: getTranslated('cash_on_delivery', context) ?? '',
                                subtitle: getTranslated('cash_on_delivery_hint', context),
                                selected: checkoutController.isCODChecked,
                                onTap: () => checkoutController.setOfflineChecked('cod'),
                              ),
                              ChangeAmountWidget(changeAmountTextController: changeAmountTextController),
                              const SizedBox(height: 10),
                            ],

                            if (showOffline) ...[
                              _PaymentOption(
                                icon: Icons.account_balance_outlined,
                                color: AppPalette.primaryDeep,
                                title: getTranslated('pay_offline', context) ?? '',
                                subtitle: getTranslated('offline_payment_hint', context),
                                selected: checkoutController.isOfflineChecked,
                                onTap: () => checkoutController.setOfflineChecked('offline'),
                                expanded: checkoutController.isOfflineChecked
                                    ? Wrap(spacing: 8, runSpacing: 8, children: [
                                        for (int index = 0; index < offlineMethods.length; index++)
                                          ChoiceChip(
                                            label: Text(offlineMethods[index].methodName ?? ''),
                                            selected: checkoutController.offlineMethodSelectedIndex == index,
                                            onSelected: (_) => checkoutController.setOfflinePaymentMethodSelectedIndex(index),
                                            showCheckmark: false,
                                            labelStyle: textBold.copyWith(
                                              fontSize: Dimensions.fontSizeSmall + 1,
                                              color: checkoutController.offlineMethodSelectedIndex == index ? Colors.white : textColor,
                                            ),
                                            selectedColor: Theme.of(context).primaryColor,
                                            backgroundColor: Theme.of(context).cardColor,
                                            side: BorderSide(color: checkoutController.offlineMethodSelectedIndex == index
                                                ? Theme.of(context).primaryColor : AppPalette.glassBorder(context)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                      ])
                                    : null,
                              ),
                              const SizedBox(height: 10),
                            ],

                            if (showWallet) ...[
                              _PaymentOption(
                                icon: Icons.account_balance_wallet_outlined,
                                color: AppPalette.warning,
                                title: getTranslated('pay_via_wallet', context) ?? '',
                                subtitle: getTranslated('wallet_payment_hint', context),
                                selected: checkoutController.isWalletChecked,
                                onTap: () => checkoutController.setOfflineChecked('wallet'),
                              ),
                              const SizedBox(height: 10),
                            ],

                            if (showDigital) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 6, bottom: 6),
                                child: Row(children: [
                                  Text(getTranslated('pay_via_online', context) ?? '',
                                      style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor)),
                                  const SizedBox(width: 6),
                                  Icon(Icons.lock_outline_rounded, size: 14, color: Theme.of(context).hintColor),
                                  const SizedBox(width: 2),
                                  Expanded(child: Text(getTranslated('fast_and_secure', context) ?? '',
                                      style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor))),
                                ]),
                              ),
                              Consumer<SplashController>(builder: (context, configProvider, _) {
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: configProvider.configModel?.paymentMethods?.length ?? 0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return CustomCheckBoxWidget(index: index,
                                      icon: '${configProvider.configModel?.paymentMethodImagePath}/'
                                          '${configProvider.configModel?.paymentMethods?[index].additionalDatas?.gatewayImage ?? ''}',
                                      name: configProvider.configModel!.paymentMethods![index].keyName!,
                                      title: configProvider.configModel!.paymentMethods![index].additionalDatas?.gatewayTitle ?? '',
                                    );
                                  },
                                );
                              }),
                            ],
                          ])
                        : const NoInternetOrDataScreenWidget(isNoInternet: false, message: 'no_payment_method_available_right_now'),
                  ),
                ),
                const SizedBox(height: 14),

                PressableScale(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (showCod) {
                      checkoutController.updatePaymentSelection();
                    }
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Text(getTranslated('save', context) ?? '',
                        style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                  ),
                ),
              ]),
            ),
          ),
        );
      }
    );
  }
}

/// Selectable payment option card with an optional expanded area.
class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? expanded;

  const _PaymentOption({required this.icon, required this.color, required this.title, this.subtitle,
    required this.selected, required this.onTap, this.expanded});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: .07) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? primary : AppPalette.glassBorder(context), width: selected ? 1.5 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: selected ? LinearGradient(colors: [color, Color.lerp(color, Colors.black, .2)!]) : null,
                  color: selected ? null : color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: selected ? Colors.white : color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault + 1,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
                if ((subtitle ?? '').isNotEmpty)
                  Text(subtitle!, style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              ])),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? primary : Colors.transparent,
                  border: Border.all(color: selected ? primary : Theme.of(context).hintColor.withValues(alpha: .5), width: 2),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
            ]),
            if (expanded != null) ...[
              const SizedBox(height: 12),
              expanded!,
            ],
          ]),
        ),
      ),
    );
  }
}


bool _isPaymentMethodsAvailable(BuildContext context, List<OfflineMethods>? offlineMethods){
  final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;

  bool isCashOnDeliveryOn = configModel?.cashOnDelivery ?? false;
  bool isWalletOn = configModel?.walletStatus == 1 && Provider.of<AuthController>(context, listen: false).isLoggedIn();
  bool isOnlinePaymentMethodsOn = configModel?.paymentMethods?.isNotEmpty ?? false;
  bool isOfflinePaymentMethodsOn = offlineMethods?.isNotEmpty ?? false;

  return isCashOnDeliveryOn || isWalletOn || isOnlinePaymentMethodsOn || isOfflinePaymentMethodsOn;
}
