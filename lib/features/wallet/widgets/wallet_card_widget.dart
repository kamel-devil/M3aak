import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/wallet/controllers/wallet_controller.dart';
import 'package:kk_thotix_m3aak/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key, required this.tooltipController, required this.focusNode,
    required this.inputAmountController});

  final JustTheController tooltipController;
  final FocusNode focusNode;
  final TextEditingController inputAmountController;

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(builder: (context, walletController, _) {
      final double balance = walletController.walletTransactionModel?.totalWalletBalance ?? 0;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Text(getTranslated('wallet_amount', context)!,
              style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeDefault)),
          if (canAddFundToWallet(context)) ...[
            const SizedBox(width: 6),
            JustTheTooltip(backgroundColor: Colors.black87,
                controller: tooltipController,
                preferredDirection: AxisDirection.down,
                tailLength: 10,
                tailBaseWidth: 20,
                content: Container(width: MediaQuery.of(context).size.width * 0.57,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text(getTranslated('if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button', context)!,
                        style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))),
                child: InkWell(onTap: () => tooltipController.showTooltip(),
                    child: const Padding(padding: EdgeInsets.all(6),
                        child: Icon(Icons.info_outline_rounded, color: Colors.white, size: 18)))),
          ],
        ]),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(PriceConverter.convertPrice(context, balance),
              style: textBold.copyWith(color: Colors.white, fontSize: 32)),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            if (canAddFundToWallet(context)) {
              showDialog(context: context, builder: (BuildContext context) {
                return AddFundDialogueWidget(focusNode: focusNode, inputAmountController: inputAmountController);
              });
            } else {
              showCustomSnackBar(getTranslated('add_fund_is_not_configured', context), context);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(getTranslated('add_fund', context) ?? '',
                  style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
            ]),
          ),
        ),
      ]);
    });
  }

  bool canAddFundToWallet(BuildContext context) {
    return Provider.of<SplashController>(context, listen: false).configModel?.addFundsToWallet == 1 &&
          (Provider.of<SplashController>(context, listen: false).configModel?.digitalPayment ?? false) &&
        (Provider.of<SplashController>(context, listen: false).configModel?.paymentMethods?.isNotEmpty ?? false);
  }
}
