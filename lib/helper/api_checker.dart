import 'dart:developer';

import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/data/model/error_response.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class ApiChecker {
  static void checkApi(ApiResponseModel apiResponse, {bool firebaseResponse = false}) {

    dynamic errorResponse = apiResponse.error is String ? apiResponse.error :  ErrorResponse.fromJson(apiResponse.error);
    if(apiResponse.error == "Failed to load data - status code: 401") {
      Provider.of<AuthController>(Get.context!,listen: false).clearSharedData();
    }else if(apiResponse.response?.statusCode == 500){
      showCustomSnackBar(getTranslated('internal_server_error', Get.context!), Get.context!);
    }else if(apiResponse.response?.statusCode == 503){
      showCustomSnackBar(apiResponse.response?.data['message'] , Get.context!);
    }else {
      log("==ff=>${apiResponse.error}");
      String? errorMessage = apiResponse.error.toString();
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        log(errorResponse.toString());
        //errorMessage = errorResponse.errors?[0].message;
      }
      showCustomSnackBar(firebaseResponse ? errorResponse?.replaceAll('_', ' ') : errorMessage, Get.context!);
    }
  }


  static ErrorResponse getError(ApiResponseModel apiResponse){
    ErrorResponse error;

    try{
      error = ErrorResponse.fromJson(apiResponse.response?.data);
    }catch(e){
      if(apiResponse.error is String){
        error = ErrorResponse(errors: [Errors(code: '', message: apiResponse.error.toString())]);

      }else{
        error = ErrorResponse.fromJson(apiResponse.error);
      }
    }
    return error;
  }
}