import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/cart/domain/models/cart_model.dart';
import 'package:kk_thotix_m3aak/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:kk_thotix_m3aak/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class CheckoutController with ChangeNotifier {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? _shippingIndex;
  bool _isLoading = false;
  bool _isCheckCreateAccount = false;
  bool _newUser = false;

  int _paymentMethodIndex = -1;
  bool _onlyDigital = true;
  bool get onlyDigital => _onlyDigital;
  int? get addressIndex => _addressIndex;
  int? get shippingIndex => _shippingIndex;
  bool get isLoading => _isLoading;
  int get paymentMethodIndex => _paymentMethodIndex;
  bool get isCheckCreateAccount => _isCheckCreateAccount;

  bool _changeAmountShow = false;
  bool get changeAmountShow => _changeAmountShow;

  double? _cashChangesAmount;
  double? get cashChangesAmount => _cashChangesAmount;

  ReferralAmount? _referralAmount;
  ReferralAmount? get referralAmount => _referralAmount;

  String selectedPaymentName = '';
  void setSelectedPayment(String payment) {
    selectedPaymentName = payment;
    notifyListeners();
  }

  bool _isAcceptTerms = false;
  bool get isAcceptTerms => _isAcceptTerms;

  final TextEditingController orderNoteController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  List<String> inputValueList = [];
  List<String?> offlineMethodInputValueList = [];

  Future<void> placeOrder(
      {required Function callback,
      String? addressID,
      String? couponCode,
      String? couponAmount,
      String? billingAddressId,
      String? orderNote,
      String? transactionId,
      String? paymentNote,
      int? id,
      String? name,
      bool isfOffline = false,
      bool wallet = false}) async {
    inputValueList = [];
    for (int fieldIndex = 0;
        fieldIndex < inputFieldControllerList.length;
        fieldIndex++) {
      final TextEditingController textEditingController =
          inputFieldControllerList[fieldIndex];
      final String? customValue =
          (fieldIndex >= 0 && fieldIndex < offlineMethodInputValueList.length)
              ? offlineMethodInputValueList[fieldIndex]
              : null;
      inputValueList.add((customValue?.isNotEmpty ?? false)
          ? customValue!.trim()
          : textEditingController.text.trim());
    }

    _isLoading = true;
    _newUser = false;
    notifyListeners();
    ApiResponseModel apiResponse;
    isfOffline
        ? apiResponse = await checkoutServiceInterface.offlinePaymentPlaceOrder(
            addressID,
            couponCode,
            couponAmount,
            billingAddressId,
            orderNote,
            keyList,
            inputValueList,
            isImageList,
            offlineMethodSelectedId,
            offlineMethodSelectedName,
            paymentNote,
            _isCheckCreateAccount,
            passwordController.text.trim())
        : wallet
            ? apiResponse =
                await checkoutServiceInterface.walletPaymentPlaceOrder(
                    addressID,
                    couponCode,
                    couponAmount,
                    billingAddressId,
                    orderNote,
                    _isCheckCreateAccount,
                    passwordController.text.trim())
            : apiResponse =
                await checkoutServiceInterface.cashOnDeliveryPlaceOrder(
                addressID: addressID,
                couponCode: couponCode,
                couponDiscountAmount: couponAmount,
                billingAddressId: billingAddressId,
                orderNote: orderNote,
                isCheckCreateAccount: _isCheckCreateAccount,
                password: passwordController.text.trim(),
                cashChangeAmount: _cashChangesAmount,
                currentCurrencyCode:
                    Provider.of<SplashController>(Get.context!, listen: false)
                        .myCurrency
                        ?.code,
              );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _isCheckCreateAccount = false;
      _isLoading = false;
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      if (!Provider.of<AuthController>(Get.context!, listen: false)
          .isLoggedIn()) {
        _newUser = apiResponse.response!.data['new_user'];
      }

      String message = apiResponse.response!.data.toString();
      callback(true, message, '', _newUser);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setAddressIndex(int index) {
    _addressIndex = index;
    // Automatically set billing address to same as shipping address when sameAsBilling is true
    if (sameAsBilling) {
      _billingAddressIndex = index;
    }
    notifyListeners();
  }

  void setBillingAddressIndex(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }

  void resetPaymentMethod() {
    _paymentMethodIndex = -1;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
  }

  void shippingAddressNull() {
    _addressIndex = null;
    notifyListeners();
  }

  void billingAddressNull() {
    _billingAddressIndex = null;
    notifyListeners();
  }

  void setSelectedShippingAddress(int index) {
    _shippingIndex = index;
    notifyListeners();
  }

  void setSelectedBillingAddress(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }

  bool isOfflineChecked = true;
  bool isCODChecked = false;
  bool isWalletChecked = false;

  void setOfflineChecked(String type, {bool notify = true}) {
    if (type == 'offline') {
      isOfflineChecked = !isOfflineChecked;
      isCODChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
      setOfflinePaymentMethodSelectedIndex(0);
    } else if (type == 'cod') {
      isCODChecked = !isCODChecked;
      isOfflineChecked = false;
      isWalletChecked = false;
      _paymentMethodIndex = -1;
    } else if (type == 'wallet') {
      isWalletChecked = !isWalletChecked;
      isOfflineChecked = false;
      isCODChecked = false;
      _paymentMethodIndex = -1;
    }

    if (notify) {
      notifyListeners();
    }
  }

  String selectedDigitalPaymentMethodName = '';

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    selectedDigitalPaymentMethodName = name;
    isCODChecked = false;
    isWalletChecked = false;
    isOfflineChecked = false;
    notifyListeners();
  }

  void digitalOnly(bool value, {bool isUpdate = false}) {
    _onlyDigital = value;
    if (isUpdate) {
      notifyListeners();
    }
  }

  OfflinePaymentModel? offlinePaymentModel;
  Future<ApiResponseModel> getOfflinePaymentList() async {
    ApiResponseModel apiResponse =
        await checkoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      offlinePaymentModel =
          OfflinePaymentModel.fromJson(apiResponse.response?.data);
      if (offlinePaymentModel?.offlineMethods?.isNotEmpty ?? false) {
        isOfflineChecked = true;
        isCODChecked = false;
        isWalletChecked = false;
        _paymentMethodIndex = -1;
        setOfflinePaymentMethodSelectedIndex(0, notify: false);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  List<TextEditingController> inputFieldControllerList = [];
  List<String?> keyList = [];
  List<bool> isImageList = [];
  int offlineMethodSelectedIndex = -1;
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}) {
    keyList = [];
    isImageList = [];
    inputFieldControllerList = [];
    offlineMethodInputValueList = [];
    offlineMethodSelectedIndex = index;
    if (offlinePaymentModel != null &&
        offlinePaymentModel!.offlineMethods != null &&
        offlinePaymentModel!.offlineMethods!.isNotEmpty) {
      offlineMethodSelectedId =
          offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!
          .offlineMethods![offlineMethodSelectedIndex].methodName!;
    }

    if (offlinePaymentModel!.offlineMethods != null &&
        offlinePaymentModel!.offlineMethods!.isNotEmpty &&
        offlinePaymentModel!
            .offlineMethods![index].methodInformations!.isNotEmpty) {
      for (int i = 0;
          i <
              offlinePaymentModel!
                  .offlineMethods![index].methodInformations!.length;
          i++) {
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!
            .offlineMethods![index].methodInformations![i].customerInput);
        isImageList.add((offlinePaymentModel!
                    .offlineMethods![index].methodInformations![i].isImage ??
                0) ==
            1);
        offlineMethodInputValueList.add(null);
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  void setOfflineMethodInputValue(int index, String? value,
      {bool notify = false}) {
    if (index < 0) return;
    if (index >= offlineMethodInputValueList.length) {
      offlineMethodInputValueList = List<String?>.from(
        [
          ...offlineMethodInputValueList,
          ...List<String?>.filled(
              index - offlineMethodInputValueList.length + 1, null)
        ],
      );
    }
    offlineMethodInputValueList[index] = value;
    if (notify) {
      notifyListeners();
    }
  }

  Future<ApiResponseModel> digitalPaymentPlaceOrder(
      {String? orderNote,
      String? customerId,
      String? addressId,
      String? billingAddressId,
      String? couponCode,
      String? couponDiscount,
      String? paymentMethod}) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse =
        await checkoutServiceInterface.digitalPaymentPlaceOrder(
            orderNote,
            customerId,
            addressId,
            billingAddressId,
            couponCode,
            couponDiscount,
            paymentMethod,
            _isCheckCreateAccount,
            passwordController.text.trim());

    if (apiResponse.response != null &&
        apiResponse.response?.statusCode == 200) {
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      _isLoading = false;

      RouterHelper.getDigitalPaymentScreenRoute(
        url: apiResponse.response?.data['redirect_link'] ?? '',
        fromWallet: false,
        action: RouteAction.pushReplacement,
      );
    } else if (apiResponse.error == 'Already registered ') {
      _isLoading = false;
      showCustomSnackBar(
          '${getTranslated(apiResponse.error, Get.context!)}', Get.context!);
    } else if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 403) {
      _isLoading = false;
      showCustomSnackBar(
          '${getTranslated(apiResponse.error, Get.context!)}', Get.context!);
    } else {
      _isLoading = false;
      showCustomSnackBar(
          '${getTranslated('payment_method_not_properly_configured', Get.context!)}',
          Get.context!);
    }
    notifyListeners();
    return apiResponse;
  }

  bool sameAsBilling = true;
  void setSameAsBilling() {
    sameAsBilling = !sameAsBilling;
    // When toggling to sameAsBilling, sync the billing address with shipping address
    if (sameAsBilling && _addressIndex != null) {
      _billingAddressIndex = _addressIndex;
    } else if (!sameAsBilling) {
      // When toggling to different billing, reset billing address
      _billingAddressIndex = null;
    }
    notifyListeners();
  }

  void clearData() {
    orderNoteController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isCheckCreateAccount = false;
    _cashChangesAmount = null;
  }

  void setIsCheckCreateAccount(bool isCheck, {bool update = true}) {
    _isCheckCreateAccount = isCheck;
    if (update) {
      notifyListeners();
    }
  }

  void toggleChangeAmountShow() {
    _changeAmountShow = !_changeAmountShow;
    notifyListeners();
  }

  void onChangeCashChangesAmount(double? amount) => _cashChangesAmount = amount;

  Future<ApiResponseModel> getReferralAmount(String? amount) async {
    ApiResponseModel apiResponse =
        await checkoutServiceInterface.getReferralAmount(amount);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _referralAmount = ReferralAmount.fromJson(apiResponse.response.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  void toggleTermsCheck({bool isUpdate = true}) {
    _isAcceptTerms = !_isAcceptTerms;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void updatePaymentSelection() {
    notifyListeners();
  }
}
