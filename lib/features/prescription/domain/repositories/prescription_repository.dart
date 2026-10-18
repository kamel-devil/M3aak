import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kk_thotix_m3aak/data/datasource/remote/dio/dio_client.dart';
import 'package:kk_thotix_m3aak/data/datasource/remote/exception/api_error_handler.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class PrescriptionRepository {
  final DioClient? dioClient;
  PrescriptionRepository({required this.dioClient});

  Future<ApiResponseModel> getList(int offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.prescriptionUri}?limit=10&offset=$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<http.StreamedResponse> create(List<XFile> images, String notes) async {
    final request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl.replaceAll(RegExp(r'/+$'), '')}${AppConstants.prescriptionUri}'));
    request.headers.addAll(<String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}',
    });
    for (final image in images) {
      final Uint8List bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('images[]', bytes,
          filename: basename(image.path), contentType: MediaType('image', 'jpeg')));
    }
    if (notes.trim().isNotEmpty) {
      request.fields['notes'] = notes.trim();
    }
    return request.send();
  }

  Future<ApiResponseModel> delete(int id) async {
    try {
      final response = await dioClient!.delete('${AppConstants.prescriptionUri}/$id');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
