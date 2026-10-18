import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/prescription/domain/models/prescription_model.dart';
import 'package:kk_thotix_m3aak/features/prescription/domain/repositories/prescription_repository.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';

class PrescriptionController with ChangeNotifier {
  static const int maxImages = 5;

  final PrescriptionRepository prescriptionRepository;
  PrescriptionController({required this.prescriptionRepository});

  PrescriptionListModel? prescriptionList;
  final List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> getPrescriptions(int offset) async {
    if (offset == 1) {
      prescriptionList = null;
      notifyListeners();
    }
    _isLoading = true;
    final ApiResponseModel apiResponse = await prescriptionRepository.getList(offset);
    if (apiResponse.response?.statusCode == 200) {
      final parsed = PrescriptionListModel.fromJson(apiResponse.response!.data);
      if (offset == 1 || prescriptionList == null) {
        prescriptionList = parsed;
      } else {
        prescriptionList!.prescriptions.addAll(parsed.prescriptions);
        prescriptionList!.offset = parsed.offset;
        prescriptionList!.totalSize = parsed.totalSize;
      }
    } else if (offset == 1) {
      prescriptionList = PrescriptionListModel();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickImages({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final int remaining = maxImages - _pickedImages.length;
    if (remaining <= 0) {
      showCustomSnackBar('${getTranslated('max_images_allowed', Get.context!)} $maxImages', Get.context!);
      return;
    }
    if (fromCamera) {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) _pickedImages.add(photo);
    } else {
      final List<XFile> files = await picker.pickMultiImage(imageQuality: 85);
      _pickedImages.addAll(files.take(remaining));
    }
    notifyListeners();
  }

  void removeImage(int index) {
    _pickedImages.removeAt(index);
    notifyListeners();
  }

  void clearPicked() {
    _pickedImages.clear();
  }

  Future<bool> submit(String notes) async {
    if (_pickedImages.isEmpty) {
      showCustomSnackBar(getTranslated('please_add_prescription_photo', Get.context!), Get.context!);
      return false;
    }
    _isSubmitting = true;
    notifyListeners();

    bool success = false;
    try {
      final response = await prescriptionRepository.create(_pickedImages, notes);
      if (response.statusCode == 200) {
        success = true;
        _pickedImages.clear();
        showCustomSnackBar(getTranslated('prescription_sent', Get.context!), Get.context!, isError: false);
        getPrescriptions(1);
      } else {
        final body = await http.Response.fromStream(response);
        showCustomSnackBar(_errorMessage(body), Get.context!);
      }
    } catch (_) {
      showCustomSnackBar(getTranslated('something_went_wrong', Get.context!), Get.context!);
    }
    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          return '${data['errors'][0]['message']}';
        }
        if (data['message'] != null) return '${data['message']} (${response.statusCode})';
      }
    } catch (_) {}
    return '${getTranslated('something_went_wrong', Get.context!)} (${response.statusCode})';
  }

  Future<bool> delete(int id) async {
    final ApiResponseModel apiResponse = await prescriptionRepository.delete(id);
    if (apiResponse.response?.statusCode == 200) {
      prescriptionList?.prescriptions.removeWhere((p) => p.id == id);
      prescriptionList?.totalSize = (prescriptionList?.totalSize ?? 1) - 1;
      notifyListeners();
      showCustomSnackBar(getTranslated('prescription_deleted', Get.context!), Get.context!, isError: false);
      return true;
    }
    showCustomSnackBar(getTranslated('something_went_wrong', Get.context!), Get.context!);
    return false;
  }
}
