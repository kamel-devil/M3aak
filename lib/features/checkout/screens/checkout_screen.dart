import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/checkout_ui.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/address/controllers/address_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/checkout_condition_checkbox.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/shipping/controllers/shipping_controller.dart';
import 'package:kk_thotix_m3aak/helper/cart_healper.dart';
import 'package:kk_thotix_m3aak/helper/debounce_helper.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/coupon/controllers/coupon_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/whatsapp_support_button_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/choose_payment_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/coupon_apply_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/shipping_details_widget.dart';
import 'package:kk_thotix_m3aak/features/checkout/widgets/wallet_payment_widget.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromProductDetails;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  final int? sellerId;
  final bool onlyDigital;
  final bool hasPhysical;
  final int quantity;

  const CheckoutScreen({super.key, required this.cartList, this.fromProductDetails = false,
    required this.discount, required this.tax, required this.totalOrderAmount, required this.shippingFee,
    this.sellerId, this.onlyDigital = false, required this.quantity, required this.hasPhysical});


  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();


  final FocusNode _orderNoteNode = FocusNode();
  double _order = 0;
  double _tax = 0;
  late bool _billingAddress;
  double? _couponDiscount;
  double? _referralDiscount;

  DebounceHelper debounceHelper = DebounceHelper(milliseconds: 500);
  SplashController  splashController= Provider.of<SplashController>(Get.context!, listen: false);


  @override
  void initState() {
    super.initState();
    Provider.of<AddressController>(context, listen: false).getAddressList();
    Provider.of<CheckoutController>(context, listen: false).getReferralAmount('0');
    Provider.of<CouponController>(context, listen: false).removePrevCouponData();
    Provider.of<CartController>(context, listen: false).getCartData(context);
    Provider.of<CheckoutController>(context, listen: false).resetPaymentMethod();
    Provider.of<ShippingController>(context, listen: false).getChosenShippingMethod(context);
    if(splashController.configModel != null &&
        splashController.configModel!.offlinePayment != null)
    {
      Provider.of<CheckoutController>(context, listen: false).getOfflinePaymentList();
    }

    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()){
      Provider.of<CouponController>(context, listen: false).getAvailableCouponList();
    }

    if(Provider.of<CheckoutController>(context, listen: false).isAcceptTerms){
      Provider.of<CheckoutController>(context, listen: false).toggleTermsCheck(isUpdate: false);
    }

    _billingAddress = Provider.of<SplashController>(Get.context!, listen: false).configModel!.billingInputByCustomer == 1;
    Provider.of<CheckoutController>(context, listen: false).clearData();

    if(splashController.configModel?.systemTaxIncludeStatus != 1) {
      _tax = widget.tax;
    }

  }

  @override
  Widget build(BuildContext context) {
    _order = widget.totalOrderAmount + widget.discount;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar: Consumer<AddressController>(
        builder: (context, locationProvider,_) {
          return Consumer<CheckoutController>(
            builder: (context, orderProvider, child) {
              return Consumer<CouponController>(
                builder: (context, couponProvider, _) {
                  if(splashController.configModel?.systemTaxIncludeStatus != 1) {
                    _tax = CartHelper().calculateVatTax(Provider.of<CartController>(context, listen: false).cartList);
                  }
                  return Consumer<CartController>(
                    builder: (context, cartProvider,_) {
                      return Consumer<ProfileController>(
                        builder: (context, profileProvider,_) {
                          final double payable = _order + widget.shippingFee - widget.discount
                              - (orderProvider.referralAmount?.amount ?? 0) - (couponProvider.discount ?? 0) + _tax;
                          final String? supportPhone = Provider.of<SplashController>(context, listen: false).configModel?.companyPhone;
                          return orderProvider.isLoading ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center, children: [
                              SizedBox(width: 30,height: 30,child: CircularProgressIndicator())]) :

                          SafeArea(
                            top: false,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: .96),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
                                boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .10), blurRadius: 30, offset: const Offset(0, -10))],
                              ),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const CheckoutConditionCheckBox(),
                                const SizedBox(height: 10),
                                Row(children: [
                                  if ((supportPhone ?? '').isNotEmpty) ...[
                                    WhatsAppSupportButton(
                                      compact: true,
                                      phoneNumber: supportPhone,
                                      orderDetails: 'السلام عليكم\n\n🛒 تفاصيل الطلب:\n━━━━━━━━━━━━━━━━\n📌 عدد المنتجات: ${widget.quantity}\n💰 الإجمالي: ${PriceConverter.convertPrice(context, payable)}\n📍 الشحن: ${PriceConverter.convertPrice(context, widget.shippingFee)}\n\nأتمنى إتمام الطلب بنجاح',
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                Expanded(child: _ConfirmButton(total: payable, onTap: (orderProvider.isLoading || !orderProvider.isAcceptTerms) ? null : () async {
                                  if(orderProvider.addressIndex == null && widget.hasPhysical) {
                                    RouterHelper.getSavedAddressListRoute(fromGuest: !Provider.of<AuthController>(context, listen: false).isLoggedIn());
                                    showCustomSnackBar(getTranslated('select_a_shipping_address', context), context, isToaster: true);
                                  } else if((orderProvider.billingAddressIndex == null && !widget.hasPhysical &&  !_billingAddress)) {
                                    showCustomSnackBar(getTranslated('you_cant_place_order_of_digital_product_without_billing_address', context), context, isToaster: true);
                                  }
                                  // else if((orderProvider.billingAddressIndex == null && !widget.hasPhysical && !orderProvider.sameAsBilling && _billingAddress) || (orderProvider.billingAddressIndex == null && _billingAddress && !orderProvider.sameAsBilling)){
                                  //   RouterHelper.getSavedBillingAddressListRoute(fromGuest: !Provider.of<AuthController>(context, listen: false).isLoggedIn());
                                  //   showCustomSnackBar(getTranslated('select_a_billing_address', context), context, isToaster: true);
                                  // }
                                  else {
                                    if(!orderProvider.isCheckCreateAccount || (orderProvider.isCheckCreateAccount && (passwordFormKey.currentState?.validate() ?? false))) {
                                      String orderNote = orderProvider.orderNoteController.text.trim();
                                      String couponCode = couponProvider.discount != null && couponProvider.discount != 0? couponProvider.couponCode : '';
                                      String couponCodeAmount = couponProvider.discount != null && couponProvider.discount != 0?
                                      couponProvider.discount.toString() : '0';


                                      String addressId =  orderProvider.addressIndex != null ?
                                      locationProvider.addressList![orderProvider.addressIndex!].id.toString() : '';

                                      String billingAddressId = (_billingAddress) ?
                                      !orderProvider.sameAsBilling && orderProvider.billingAddressIndex != null ?
                                      locationProvider.addressList![orderProvider.billingAddressIndex!].id.toString() : (orderProvider.addressIndex != null ? locationProvider.addressList![orderProvider.addressIndex!].id.toString() : '') : '';



                                      if(orderProvider.paymentMethodIndex != -1) {
                                        orderProvider.digitalPaymentPlaceOrder(
                                            orderNote: orderNote,
                                            customerId: Provider.of<AuthController>(context, listen: false).isLoggedIn() ?
                                            profileProvider.userInfoModel?.id.toString() : Provider.of<AuthController>(context, listen: false).getGuestToken(),
                                            addressId: addressId,
                                            billingAddressId: billingAddressId,
                                            couponCode: couponCode,
                                            couponDiscount: couponCodeAmount,
                                            paymentMethod: orderProvider.selectedDigitalPaymentMethodName);

                                      } else if (orderProvider.isCODChecked && !widget.onlyDigital){
                                        orderProvider.placeOrder(callback: _callback,
                                            addressID : addressId,
                                            couponCode : couponCode,
                                            couponAmount : couponCodeAmount,
                                            billingAddressId : billingAddressId,
                                            orderNote : orderNote);
                                      }

                                      else if(orderProvider.isOfflineChecked){
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> OfflinePaymentScreen(payableAmount: _order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + _tax, callback: _callback)));
                                        RouterHelper.getOfflinePaymentScreen(payableAmount: (_order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + _tax), callback: _callback);
                                      }

                                      else if(orderProvider.isWalletChecked) {
                                        showAnimatedDialog(context, WalletPaymentWidget(
                                            currentBalance: profileProvider.balance ?? 0,
                                            orderAmount: _order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + _tax,
                                            onTap: (){if(profileProvider.balance! <
                                                (_order + widget.shippingFee - widget.discount - (_referralDiscount ?? 0) - _couponDiscount! + _tax)){
                                              showCustomSnackBar(getTranslated('insufficient_balance', context), context, isToaster: true);
                                            }else{
                                              Navigator.pop(context);
                                              orderProvider.placeOrder(callback: _callback,wallet: true,
                                                  addressID : addressId,
                                                  couponCode : couponCode,
                                                  couponAmount : couponCodeAmount,
                                                  billingAddressId : billingAddressId,
                                                  orderNote : orderNote);
                                            }}), dismissible: false, willFlip: true);
                                      }
                                      else {
                                        showModalBottomSheet(
                                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                          builder: (c) {
                                            return PaymentMethodBottomSheetWidget(onlyDigital: widget.onlyDigital);
                                          },
                                        );
                                      }
                                    }
                                  }
                                },
                                )),
                                ]),
                              ]),
                            ));


                        }
                      );
                    }
                  );
                }
              );
            }
          );
        }
      ),

      appBar: CustomAppBar(title: getTranslated('checkout', context)),
      body: Consumer<CheckoutController>(
        builder: (context, orderProvider, _) {
          _couponDiscount = Provider.of<CouponController>(context).discount ?? 0;
          _referralDiscount = orderProvider.referralAmount?.amount ?? 0;
          final bool taxIncluded = splashController.configModel?.systemTaxIncludeStatus == 1;
          final double total = _order + widget.shippingFee - (_referralDiscount ?? 0) - widget.discount - _couponDiscount! + _tax;
          final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
          final thumbs = widget.cartList.where((c) => (c.thumbnailFullUrl?.path ?? '').isNotEmpty).toList();
          final String instructions = splashController.configModel?.orderInstructions ?? '';

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const CheckoutStepper(),

              FadeSlideIn(child: ShippingDetailsWidget(
                hasPhysical: widget.hasPhysical,
                billingAddress: _billingAddress,
                passwordFormKey: passwordFormKey,
              )),
              const SizedBox(height: 14),

              if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) ...[
                FadeSlideIn(index: 1, child: CouponApplyWidget(couponController: _controller, orderAmount: _order)),
                const SizedBox(height: 14),
              ],

              FadeSlideIn(index: 2, child: ChoosePaymentWidget(onlyDigital: widget.onlyDigital)),
              const SizedBox(height: 14),

              FadeSlideIn(index: 3, child: CheckoutCard(
                title: getTranslated('order_summary', context),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${widget.quantity} ${getTranslated(widget.quantity > 1 ? 'items' : 'item', context)}',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppPalette.primaryDeep)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (thumbs.isNotEmpty) ...[
                    Row(children: [
                      for (int i = 0; i < thumbs.length && i < 4; i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppPalette.tint(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppPalette.glassBorder(context)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomImageWidget(image: thumbs[i].thumbnailFullUrl!.path!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      if (thumbs.length > 4)
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('+${thumbs.length - 4}',
                              style: textBold.copyWith(color: AppPalette.primaryDeep)),
                        ),
                    ]),
                    const SizedBox(height: 10),
                  ],

                  CheckoutSummaryRow(
                    label: getTranslated('sub_total', context) ?? '',
                    value: PriceConverter.convertPrice(context, _order),
                  ),
                  CheckoutSummaryRow(
                    label: getTranslated('shipping_fee', context) ?? '',
                    value: PriceConverter.convertPrice(context, widget.shippingFee),
                  ),
                  CheckoutSummaryRow(
                    label: getTranslated('discount', context) ?? '',
                    value: '${widget.discount > 0 ? '− ' : ''}${PriceConverter.convertPrice(context, widget.discount)}',
                    valueColor: widget.discount > 0 ? AppPalette.success : null,
                  ),
                  CheckoutSummaryRow(
                    label: getTranslated('coupon_voucher', context) ?? '',
                    value: '${_couponDiscount! > 0 ? '− ' : ''}${PriceConverter.convertPrice(context, _couponDiscount)}',
                    valueColor: _couponDiscount! > 0 ? AppPalette.success : Theme.of(context).hintColor,
                  ),
                  if (!taxIncluded)
                    CheckoutSummaryRow(
                      label: getTranslated('tax', context) ?? '',
                      value: PriceConverter.convertPrice(context, _tax),
                    ),
                  if ((_referralDiscount ?? 0) > 0)
                    CheckoutSummaryRow(
                      label: getTranslated('referral_discount', context) ?? '',
                      value: '− ${PriceConverter.convertPrice(context, _referralDiscount)}',
                      valueColor: AppPalette.success,
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, thickness: 1.2, color: AppPalette.glassBorder(context)),
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(getTranslated('total_payable', context) ?? '',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
                      if (taxIncluded)
                        Text(getTranslated('inc_vat_tax', context) ?? '',
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                    ])),
                    const SizedBox(width: 12),
                    Text(PriceConverter.convertPrice(context, total),
                        style: textBold.copyWith(fontSize: 22, color: AppPalette.primaryDeep)),
                  ]),
                ]),
              )),

              if (instructions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppPalette.warning.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppPalette.warning.withValues(alpha: .35)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.schedule_rounded, size: 20, color: Color.lerp(AppPalette.warning, Colors.black, .35)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(instructions, style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall + 1,
                      height: 1.6,
                      color: AppPalette.isDark(context) ? AppPalette.warning : Color.lerp(AppPalette.warning, Colors.black, .55),
                    ))),
                  ]),
                ),
              ],
              const SizedBox(height: 14),

              FadeSlideIn(index: 4, child: CheckoutCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: getTranslated('note_for_pharmacist', context) ?? '',
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
                    TextSpan(text: '  (${getTranslated('optional', context)})',
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                  ])),
                  const SizedBox(height: 10),
                  CustomTextFieldWidget(
                    hintText: getTranslated('note_hint', context),
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.done,
                    maxLines: 3,
                    focusNode: _orderNoteNode,
                    controller: orderProvider.orderNoteController,
                  ),
                ]),
              )),
            ],
          );
        },
      ),
    );
  }


  void _callback(bool isSuccess, String message, String orderID, bool createAccount) async {
    if(isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');

        Future.delayed(Duration(milliseconds: 300), () {
          showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
            icon: Icons.check,
            title: getTranslated(createAccount ? 'order_placed_Account_Created' : 'order_placed', Get.context!),
            description: getTranslated('your_order_placed', Get.context!),
            isFailed: false,
          ), dismissible: false, willFlip: true);
        });

      });
    }else {
      showCustomSnackBar(message, context, isToaster: true);
    }
  }

}

/// Gradient "confirm order" button carrying the payable total.
class _ConfirmButton extends StatelessWidget {
  final double total;
  final VoidCallback? onTap;
  const _ConfirmButton({required this.total, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
            Expanded(child: Text(getTranslated('confirm_order', context) ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: fg))),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: enabled ? Colors.white.withValues(alpha: .2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(PriceConverter.convertPrice(context, total),
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: fg)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
