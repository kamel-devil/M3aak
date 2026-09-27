import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/reorder/domain/services/re_order_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';


class ReOrderController with ChangeNotifier {
  final ReOrderServiceInterface reOrderServiceInterface;
  ReOrderController({required this.reOrderServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  Future<ApiResponseModel> reorder({String? orderId}) async {
    _isLoading =true;
    notifyListeners();
    ApiResponseModel apiResponse = await reOrderServiceInterface.reorder(orderId!);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Provider.of<CartController>(Get.context!, listen: false).setIsCartLoading();
      showCustomSnackBar(apiResponse.response?.data['message'], Get.context!, isError: false);
      RouterHelper.getCartScreenRoute(action: RouteAction.push);
    }else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }

}
