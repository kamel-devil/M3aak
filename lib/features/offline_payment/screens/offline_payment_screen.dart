import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/shipping_details_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final double payableAmount;
  final Function callback;
  const OfflinePaymentScreen(
      {super.key, required this.payableAmount, required this.callback});

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  TextEditingController paymentController = TextEditingController();
  final GlobalKey<FormState> offlineFormKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickMethodImage({
    required CheckoutController checkoutProvider,
    required int index,
  }) async {
    final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 90);
    if (pickedImage == null) {
      return;
    }

    final String imageName = pickedImage.path.split('/').last;
    checkoutProvider.inputFieldControllerList[index].text = imageName;
    checkoutProvider.setOfflineMethodInputValue(index, pickedImage.path,
        notify: true);
  }

  void _removeMethodImage(CheckoutController checkoutProvider, int index) {
    checkoutProvider.inputFieldControllerList[index].clear();
    checkoutProvider.setOfflineMethodInputValue(index, null, notify: true);
  }

  /// Required customer inputs of the selected method that are still empty.
  bool _hasMissingRequired(CheckoutController checkoutProvider) {
    final methods = checkoutProvider.offlinePaymentModel?.offlineMethods ?? [];
    if (methods.isEmpty || checkoutProvider.offlineMethodSelectedIndex < 0) return true;
    final infos = methods[checkoutProvider.offlineMethodSelectedIndex].methodInformations ?? [];
    for (int i = 0; i < infos.length; i++) {
      if (infos[i].isRequired == 1 &&
          (i >= checkoutProvider.inputFieldControllerList.length ||
              checkoutProvider.inputFieldControllerList[i].text.trim().isEmpty)) {
        return true;
      }
    }
    return false;
  }

  String _label(String? raw) => (raw ?? '').replaceAll('_', ' ').trim().isEmpty
      ? ''
      : (raw ?? '').replaceAll('_', ' ').capitalize();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('pay_by_transfer', context)),
      body: Consumer<CheckoutController>(builder: (context, checkoutProvider, _) {
        final methods = checkoutProvider.offlinePaymentModel?.offlineMethods ?? [];
        final int selected = checkoutProvider.offlineMethodSelectedIndex;
        final OfflineMethods? method = (selected >= 0 && selected < methods.length) ? methods[selected] : null;
        final infos = method?.methodInformations ?? [];
        final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            FadeSlideIn(child: _AmountHero(amount: widget.payableAmount)),
            const SizedBox(height: 18),

            if (methods.isNotEmpty) ...[
              Text(getTranslated('transfer_method', context) ?? '',
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (int index = 0; index < methods.length; index++)
                  _MethodChip(
                    label: methods[index].methodName ?? '',
                    selected: index == selected,
                    onTap: () => checkoutProvider.setOfflinePaymentMethodSelectedIndex(index),
                  ),
              ]),
              const SizedBox(height: 14),
            ],

            if (method != null)
              FadeSlideIn(index: 1, child: _AccountCard(method: method, label: _label)),
            const SizedBox(height: 14),

            FadeSlideIn(index: 2, child: GlassContainer(
              blur: false,
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: offlineFormKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(getTranslated('confirm_transfer', context) ?? '',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),

                  for (int index = 0; index < infos.length && index < checkoutProvider.inputFieldControllerList.length; index++) ...[
                    const SizedBox(height: 14),
                    if ((infos[index].isImage ?? 0) == 1) ...[
                      _FieldLabel(text: _label(infos[index].customerInput), required: infos[index].isRequired == 1),
                      const SizedBox(height: 8),
                      checkoutProvider.inputFieldControllerList[index].text.isEmpty
                          ? _UploadBox(onTap: () => _pickMethodImage(checkoutProvider: checkoutProvider, index: index))
                          : _UploadedReceipt(
                              path: index < checkoutProvider.offlineMethodInputValueList.length
                                  ? checkoutProvider.offlineMethodInputValueList[index] : null,
                              fileName: checkoutProvider.inputFieldControllerList[index].text,
                              onChange: () => _pickMethodImage(checkoutProvider: checkoutProvider, index: index),
                              onRemove: () => _removeMethodImage(checkoutProvider, index),
                            ),
                    ] else
                      CustomTextFieldWidget(
                        controller: checkoutProvider.inputFieldControllerList[index],
                        required: infos[index].isRequired == 1,
                        labelText: _label(infos[index].customerInput),
                        hintText: _label(infos[index].customerPlaceholder),
                        onChanged: (value) {
                          checkoutProvider.setOfflineMethodInputValue(index, value);
                          setState(() {});
                        },
                        validator: (value) => infos[index].isRequired == 1
                            ? ValidateCheck.validateEmptyText(value, _label(infos[index].customerInput))
                            : null,
                      ),
                  ],

                  const SizedBox(height: 14),
                  _FieldLabel(text: getTranslated('note', context) ?? '', optional: true),
                  const SizedBox(height: 8),
                  CustomTextFieldWidget(
                    controller: paymentController,
                    hintText: getTranslated('transfer_note_hint', context),
                  ),
                ]),
              ),
            )),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppPalette.secondary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.secondary.withValues(alpha: .25)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.verified_user_outlined, size: 18, color: AppPalette.secondary),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(getTranslated('transfer_review_note', context) ?? '',
                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, height: 1.6, color: textColor))),
              ]),
            ),
          ],
        );
      }),
      bottomNavigationBar: Consumer<CheckoutController>(builder: (context, checkoutProvider, _) {
        return Consumer<CouponController>(builder: (context, couponProvider, _) {
          return Consumer<AddressController>(builder: (context, locationProvider, _) {
            final bool ready = !_hasMissingRequired(checkoutProvider);
            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: .96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
                  boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .10), blurRadius: 30, offset: const Offset(0, -10))],
                ),
                child: checkoutProvider.isLoading
                    ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
                    : _PayButton(
                        amount: widget.payableAmount,
                        onTap: !ready ? null : () {
                          if (offlineFormKey.currentState?.validate() ?? false) {
                            String paymentNote = paymentController.text.trim();
                            String orderNote = checkoutProvider.orderNoteController.text.trim();
                            String couponCode = couponProvider.discount != null && couponProvider.discount != 0
                                ? couponProvider.couponCode : '';
                            String couponCodeAmount = couponProvider.discount != null && couponProvider.discount != 0
                                ? couponProvider.discount.toString() : '0';
                            String addressId = checkoutProvider.addressIndex != null
                                ? locationProvider.addressList![checkoutProvider.addressIndex!].id.toString() : '';

                            String billingAddressId = (Provider.of<SplashController>(context, listen: false)
                                        .configModel!.billingInputByCustomer == 1)
                                ? !checkoutProvider.sameAsBilling
                                    ? locationProvider.addressList![checkoutProvider.billingAddressIndex!].id.toString()
                                    : locationProvider.addressList![checkoutProvider.addressIndex!].id.toString()
                                : '';

                            checkoutProvider.placeOrder(
                              callback: widget.callback,
                              paymentNote: paymentNote,
                              addressID: addressId,
                              billingAddressId: billingAddressId,
                              orderNote: orderNote,
                              couponCode: couponCode,
                              couponAmount: couponCodeAmount,
                              isfOffline: true,
                            );
                          }
                        },
                      ),
              ),
            );
          });
        });
      }),
    );
  }
}

class _AmountHero extends StatelessWidget {
  final double amount;
  const _AmountHero({required this.amount});

  @override
  Widget build(BuildContext context) {
    Widget step(String n, String label, bool active) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: active ? .22 : .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withValues(alpha: .3),
              shape: BoxShape.circle,
            ),
            child: Text(n, style: textBold.copyWith(fontSize: 11, color: active ? AppPalette.primaryDeep : Colors.white)),
          ),
          const SizedBox(width: 5),
          Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: textBold.copyWith(fontSize: 11, color: Colors.white))),
        ]),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .28), blurRadius: 30, offset: const Offset(0, 14))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(children: [
          PositionedDirectional(
            end: -50,
            bottom: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .10), width: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getTranslated('amount_to_transfer', context) ?? '',
                  style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeDefault)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(PriceConverter.convertPrice(context, amount),
                    style: textBold.copyWith(color: Colors.white, fontSize: 32, height: 1.3)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                step('1', getTranslated('choose_method_step', context) ?? '', true),
                const SizedBox(width: 6),
                step('2', getTranslated('transfer_step', context) ?? '', false),
                const SizedBox(width: 6),
                step('3', getTranslated('upload_receipt_step', context) ?? '', false),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MethodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 48, minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: selected ? AppPalette.brandGradient : null,
            color: selected ? null : AppPalette.glass(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? Colors.transparent : AppPalette.glassBorder(context)),
            boxShadow: [BoxShadow(
              color: AppPalette.primary.withValues(alpha: selected ? .3 : 0),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.account_balance_wallet_outlined, size: 18,
                color: selected ? Colors.white : Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(label, style: textBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            )),
          ]),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final OfflineMethods method;
  final String Function(String?) label;
  const _AccountCard({required this.method, required this.label});

  @override
  Widget build(BuildContext context) {
    final fields = method.methodFields ?? [];
    return GlassContainer(
      blur: false,
      radius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: Theme.of(context).primaryColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppPalette.success),
          const SizedBox(width: 6),
          Expanded(child: Text(getTranslated('pay_on_this_account', context) ?? '',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: AppPalette.success))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(method.methodName ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.primaryDeep)),
          ),
        ]),
        for (final field in fields) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
            decoration: BoxDecoration(color: AppPalette.tint(context), borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label(field.inputName),
                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                const SizedBox(height: 2),
                Text(field.inputData ?? '',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      letterSpacing: .5,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
              ])),
              if ((field.inputData ?? '').isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: field.inputData!));
                    showCustomSnackBar(getTranslated('copied', context), context, isError: false);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    foregroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(getTranslated('copy', context) ?? '',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).cardColor)),
                ),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  final bool optional;
  const _FieldLabel({required this.text, this.required = false, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(text: text, style: textBold.copyWith(
        fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color,
      )),
      if (required) const TextSpan(text: ' *', style: TextStyle(color: AppPalette.error)),
      if (optional)
        TextSpan(text: '  (${getTranslated('optional', context)})', style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
        )),
    ]));
  }
}

class _UploadBox extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadBox({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: AppPalette.tint(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .45), width: 1.5),
          ),
          child: Column(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(Icons.file_upload_outlined, color: Theme.of(context).primaryColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(getTranslated('tap_to_upload_receipt', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 2),
            Text(getTranslated('upload_receipt_hint', context) ?? '', textAlign: TextAlign.center,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          ]),
        ),
      ),
    );
  }
}

class _UploadedReceipt extends StatelessWidget {
  final String? path;
  final String fileName;
  final VoidCallback onChange;
  final VoidCallback onRemove;
  const _UploadedReceipt({required this.path, required this.fileName, required this.onChange, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bool hasFile = path != null && path!.isNotEmpty && !kIsWeb && File(path!).existsSync();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 64,
            height: 80,
            child: hasFile
                ? Image.file(File(path!), fit: BoxFit.cover)
                : Container(color: AppPalette.tint(context),
                    child: Icon(Icons.image_outlined, color: Theme.of(context).primaryColor)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_rounded, size: 16, color: AppPalette.success),
            const SizedBox(width: 4),
            Flexible(child: Text(getTranslated('receipt_attached', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: AppPalette.success))),
          ]),
          const SizedBox(height: 4),
          Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
        ])),
        const SizedBox(width: 8),
        Column(mainAxisSize: MainAxisSize.min, children: [
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 36),
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(getTranslated('checkout_change', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.primaryDeep)),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 36),
              backgroundColor: AppPalette.error.withValues(alpha: .1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(getTranslated('remove', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.error)),
          ),
        ]),
      ]),
    );
  }
}

class _PayButton extends StatelessWidget {
  final double amount;
  final VoidCallback? onTap;
  const _PayButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color fg = enabled ? Colors.white : Theme.of(context).hintColor;
    return Semantics(
      button: true,
      enabled: enabled,
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: enabled ? AppPalette.brandGradient : null,
            color: enabled ? null : Theme.of(context).hintColor.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
              color: AppPalette.primary.withValues(alpha: enabled ? .35 : 0),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )],
          ),
          child: Row(children: [
            Expanded(child: Text(getTranslated('confirm_payment', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: fg))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: enabled ? Colors.white.withValues(alpha: .2) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(PriceConverter.convertPrice(context, amount),
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: fg)),
            ),
          ]),
        ),
      ),
    );
  }
}
