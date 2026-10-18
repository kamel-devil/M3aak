import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/domain/models/loyalty_point_model.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/domain/services/loyalty_point_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';

class LoyaltyPointController extends ChangeNotifier {
  final LoyaltyPointServiceInterface loyaltyPointServiceInterface;
  LoyaltyPointController({required this.loyaltyPointServiceInterface});


  bool _isConvert = false;
  bool get isConvert => _isConvert;

  LoyaltyPointModel? _loyaltyPointModel;
  LoyaltyPointModel? get loyaltyPointModel => _loyaltyPointModel;

  String? _selectedFilterBy;
  String? get selectedFilterBy => _selectedFilterBy;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  Set<String>? _selectedEarnByList;
  Set<String>? get selectedEarnByList => _selectedEarnByList;




  Future<void> getLoyaltyPointList(BuildContext context, int offset, {
    bool reload = false,
    bool isUpdate = true,
    String? filterBy,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? transactionTypes,

  }) async {
    if(reload || offset == 1) {
      _loyaltyPointModel = null;

      if(isUpdate) {
        notifyListeners();
      }
    }

    ApiResponseModel apiResponse = await loyaltyPointServiceInterface.getList(
      offset : offset, filterBy: filterBy, startDate: startDate,
      endDate: endDate, transactionTypes: transactionTypes,
    );

    if (apiResponse.response?.data != null && apiResponse.response?.statusCode == 200) {
      final LoyaltyPointModel parsedLoyaltyPointModelResponse = LoyaltyPointModel.fromJson(apiResponse.response?.data);
      if(offset == 1) {
        _loyaltyPointModel = parsedLoyaltyPointModelResponse;
      }else {
        _loyaltyPointModel?.offset = parsedLoyaltyPointModelResponse.offset;
        _loyaltyPointModel?.totalLoyaltyPoint = parsedLoyaltyPointModelResponse.totalLoyaltyPoint;
        _loyaltyPointModel?.loyaltyPointList?.addAll(parsedLoyaltyPointModelResponse.loyaltyPointList ?? []);

      }

    } else {
      _loyaltyPointModel?.loyaltyPointList = [];
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }


  Future convertPointToCurrency(BuildContext context, int point) async {
    _isConvert = true;
    notifyListeners();
    ApiResponseModel apiResponse = await loyaltyPointServiceInterface.convertPointToCurrency(point);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      _isConvert = false;
      showCustomSnackBar("${getTranslated('point_converted_successfully', Get.context!)}", Get.context!, isError: false);
    }else{
      _isConvert = false;
      showCustomSnackBar("${getTranslated('point_converted_failed', Get.context!)}", Get.context!);
    }
    notifyListeners();
  }





  void setSelectedProductType({String? type, bool isUpdate = true}){
    _selectedFilterBy = type;

    if(isUpdate){
      notifyListeners();
    }
  }



  void setSelectedDate({required DateTime? startDate, required DateTime? endDate}) async {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }


  void onUpdateEarnBy(String value, {bool isUpdate = true}) {
    _selectedEarnByList ??= <String>{};

    // Toggle logic
    if (!_selectedEarnByList!.add(value)) {
      _selectedEarnByList!.remove(value);
    }

    if (isUpdate) {
      notifyListeners();
    }
  }

  void initFilterData(){

    _selectedFilterBy = _loyaltyPointModel?.filterBy;
    _selectedEarnByList = _loyaltyPointModel?.transactionTypes?.toSet();

    _startDate = _loyaltyPointModel?.startDate;
    _endDate = _loyaltyPointModel?.endDate;


  }



}
