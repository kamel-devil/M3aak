import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/checkout/controllers/checkout_controller.dart';
import 'package:kk_thotix_m3aak/features/coupon/domain/models/coupon_item_model.dart';
import 'package:kk_thotix_m3aak/features/coupon/domain/models/coupon_model.dart';
import 'package:kk_thotix_m3aak/features/coupon/domain/services/coupon_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class CouponController extends ChangeNotifier {
  final CouponServiceInterface? couponRepo;
  CouponController({required this.couponRepo});

  CouponModel? _coupon;
  double? _discount;
  bool _isLoading = false;
  CouponModel? get coupon => _coupon;
  double? get discount => _discount;
  bool get isLoading => _isLoading;
  String _couponCode = '';
  String get couponCode => _couponCode;

  void removeCoupon() async {
    _discount = null;
    _couponCode = '';
    Provider.of<CheckoutController>(Get.context!, listen: false).getReferralAmount('0');
    await Provider.of<CartController>(Get.context!, listen: false).getCartData(Get.context!);
    notifyListeners();
  }



  Future<void> applyCoupon(BuildContext context,String coupon, double order) async {
    _isLoading = true;
    _discount = 0;
    notifyListeners();
    ApiResponseModel apiResponse = await couponRepo!.get(coupon);
    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      _couponCode = coupon;
      Map map = apiResponse.response!.data;
      String dis = map['coupon_discount'].toString();
      if(map['coupon_discount'] !=null){
        _discount = double.parse(dis);
      }

      showCustomSnackBar('${getTranslated('you_got', Get.context!)} '
        '${PriceConverter.convertPrice(Get.context!, _discount)} '
        '${getTranslated('discount', Get.context!)}', Get.context!, isError: false, isToaster: true);
      await Provider.of<CartController>(Get.context!, listen: false).getCartData(Get.context!, couponCode: coupon);
      Provider.of<CheckoutController>(Get.context!, listen: false).getReferralAmount(PriceConverter.convertPriceWithoutSymbol(Get.context!, _discount));
    } else {
      showCustomSnackBar(apiResponse.response?.data, Get.context!, isToaster: true);
    }
    _isLoading = false;
    notifyListeners();
  }



  List<Coupons>? couponList;
  CouponItemModel? couponItemModel;
  Future<void> getCouponList(BuildContext context,int offset) async {
    _isLoading = true;
    ApiResponseModel apiResponse = await couponRepo!.getList(offset : offset);
    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      couponList = [];
      _isLoading = false;
      couponList!.addAll(CouponItemModel.fromJson(apiResponse.response!.data).coupons!);
      couponItemModel = CouponItemModel.fromJson(apiResponse.response!.data);
    }
    _isLoading = false;
    notifyListeners();
  }


  List<Coupons>? availableCouponList;
  Future<void> getAvailableCouponList() async {
    availableCouponList = [];
    ApiResponseModel apiResponse = await couponRepo!.getAvailableCouponList();
    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      apiResponse.response?.data.forEach((coupon)=> availableCouponList?.add(Coupons.fromJson(coupon)));
    }
    notifyListeners();
  }


  int couponCurrentIndex = 0;
  void setCurrentIndex(int index) {
    couponCurrentIndex = index;
    notifyListeners();
  }


  Future<void> getSellerWiseCouponList(int sellerId, int offset) async {
    _isLoading = true;
    ApiResponseModel apiResponse = await couponRepo!.getSellerCouponList(sellerId, offset);
    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      couponItemModel = CouponItemModel.fromJson(apiResponse.response!.data);
    } else {
      showCustomSnackBar(apiResponse.response!.data, Get.context!, isToaster: true);
    }
    _isLoading = false;
    notifyListeners();
  }


  void removePrevCouponData() {
    _coupon = null;
    _isLoading = false;
    _discount = null;
    _coupon = null;
  }
}
