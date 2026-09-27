import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/shipping_details_widget.dart';
import 'package:kk_thotix_m3aak/features/offline_payment/widgets/offline_card_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('offline_payment', context)),
      body:
          Consumer<CheckoutController>(builder: (context, checkoutProvider, _) {
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child: SizedBox(
                                height: 100,
                                child: Image.asset(Images.offlinePayment))),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          child: Text(
                              '${getTranslated('offline_payment_helper_text', context)}',
                              textAlign: TextAlign.center,
                              style: textRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault)),
                        ),
                        if (checkoutProvider.offlinePaymentModel != null &&
                            checkoutProvider
                                    .offlinePaymentModel!.offlineMethods !=
                                null &&
                            checkoutProvider.offlinePaymentModel!
                                .offlineMethods!.isNotEmpty)
                          SizedBox(
                              height: 190,
                              child: RepaintBoundary(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: checkoutProvider
                                        .offlinePaymentModel!
                                        .offlineMethods!
                                        .length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            if (checkoutProvider
                                                        .offlinePaymentModel
                                                        ?.offlineMethods !=
                                                    null &&
                                                checkoutProvider
                                                    .offlinePaymentModel!
                                                    .offlineMethods!
                                                    .isNotEmpty) {
                                              checkoutProvider
                                                  .setOfflinePaymentMethodSelectedIndex(
                                                      index);
                                            }
                                          },
                                          child: OfflineCardWidget(
                                              offlinePaymentModel:
                                                  checkoutProvider
                                                      .offlinePaymentModel!
                                                      .offlineMethods![index],
                                              index: index));
                                    }),
                              )),
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: Text(
                                    '${getTranslated('amount', context)} : ${PriceConverter.convertPrice(context, widget.payableAmount)}',
                                    style: textBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge)))),
                        Text(
                          '${getTranslated('payment_info', context)}',
                          style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        Form(
                          key: offlineFormKey,
                          child: RepaintBoundary(
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: checkoutProvider
                                    .offlinePaymentModel!
                                    .offlineMethods![checkoutProvider
                                        .offlineMethodSelectedIndex]
                                    .methodInformations
                                    ?.length,
                                itemBuilder: (context, index) {
                                  MethodInformations? methodInformation =
                                      checkoutProvider
                                          .offlinePaymentModel!
                                          .offlineMethods![checkoutProvider
                                              .offlineMethodSelectedIndex]
                                          .methodInformations?[index];
                                  final bool isImageInput =
                                      (methodInformation?.isImage ?? 0) == 1;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeDefault),
                                    child: isImageInput
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomTextFieldWidget(
                                                controller: checkoutProvider
                                                        .inputFieldControllerList[
                                                    index],
                                                required: methodInformation
                                                        ?.isRequired ==
                                                    1,
                                                readOnly: true,
                                                onTap: () => _pickMethodImage(
                                                  checkoutProvider:
                                                      checkoutProvider,
                                                  index: index,
                                                ),
                                                labelText:
                                                    '${methodInformation?.customerInput}'
                                                        .replaceAll('_', ' ')
                                                        .capitalize(),
                                                hintText:
                                                    '${methodInformation?.customerPlaceholder}'
                                                        .replaceAll('_', ' ')
                                                        .capitalize(),
                                                validator: (value) {
                                                  if (methodInformation
                                                          ?.isRequired ==
                                                      1) {
                                                    return ValidateCheck
                                                        .validateEmptyText(
                                                            value,
                                                            '${methodInformation?.customerInput}'
                                                                .replaceAll(
                                                                    '_', ' ')
                                                                .capitalize());
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                              ),
                                              if (checkoutProvider
                                                  .inputFieldControllerList[
                                                      index]
                                                  .text
                                                  .isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      top: Dimensions
                                                          .paddingSizeSmall),
                                                  child: Text(
                                                    checkoutProvider
                                                        .inputFieldControllerList[
                                                            index]
                                                        .text,
                                                    style: textRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                            ],
                                          )
                                        : CustomTextFieldWidget(
                                            controller: checkoutProvider
                                                    .inputFieldControllerList[
                                                index],
                                            required:
                                                methodInformation?.isRequired ==
                                                    1,
                                            labelText:
                                                '${methodInformation?.customerInput}'
                                                    .replaceAll('_', ' ')
                                                    .capitalize(),
                                            hintText:
                                                '${methodInformation?.customerPlaceholder}'
                                                    .replaceAll('_', ' ')
                                                    .capitalize(),
                                            onChanged: (value) =>
                                                checkoutProvider
                                                    .setOfflineMethodInputValue(
                                                        index, value),
                                            validator: (value) {
                                              if (methodInformation
                                                      ?.isRequired ==
                                                  1) {
                                                return ValidateCheck
                                                    .validateEmptyText(
                                                        value,
                                                        '${methodInformation?.customerInput}'
                                                            .replaceAll(
                                                                '_', ' ')
                                                            .capitalize());
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                  );
                                }),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFieldWidget(
                          controller: paymentController,
                          labelText: getTranslated('note', context),
                          hintText: getTranslated('note', context),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ])))
        ]);
      }),
      bottomNavigationBar:
          Consumer<CheckoutController>(builder: (context, checkoutProvider, _) {
        return Consumer<ProfileController>(
            builder: (context, profileProvider, _) {
          return Consumer<CouponController>(
              builder: (context, couponProvider, _) {
            return Consumer<AddressController>(
                builder: (context, locationProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  isLoading: checkoutProvider.isLoading,
                  onTap: () {
                    if (offlineFormKey.currentState?.validate() ?? false) {
                      String paymentNote = paymentController.text.trim();
                      String orderNote =
                          checkoutProvider.orderNoteController.text.trim();
                      String couponCode = couponProvider.discount != null &&
                              couponProvider.discount != 0
                          ? couponProvider.couponCode
                          : '';
                      String couponCodeAmount =
                          couponProvider.discount != null &&
                                  couponProvider.discount != 0
                              ? couponProvider.discount.toString()
                              : '0';
                      String addressId = checkoutProvider.addressIndex != null
                          ? locationProvider
                              .addressList![checkoutProvider.addressIndex!].id
                              .toString()
                          : '';

                      String billingAddressId = (Provider.of<SplashController>(
                                      context,
                                      listen: false)
                                  .configModel!
                                  .billingInputByCustomer ==
                              1)
                          ? !checkoutProvider.sameAsBilling
                              ? locationProvider
                                  .addressList![
                                      checkoutProvider.billingAddressIndex!]
                                  .id
                                  .toString()
                              : locationProvider
                                  .addressList![checkoutProvider.addressIndex!]
                                  .id
                                  .toString()
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
                  buttonText: getTranslated('proceed', context),
                ),
              );
            });
          });
        });
      }),
    );
  }
}
