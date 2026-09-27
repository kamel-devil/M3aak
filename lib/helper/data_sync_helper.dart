import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';
import 'package:kk_thotix_m3aak/data/local/cache_response.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';

class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
  }) async {
    final localResponse = await fetchFromLocal();

    if (localResponse.isSuccess) {
      final decoded = normalizeJson(localResponse.response!.response);

      // if cache was double-encoded, decode again
      final decoded2 = normalizeJson(decoded);

      onResponse(decoded2, DataSourceEnum.local);
    }

    final clientResponse = await fetchFromClient();
    if (clientResponse.isSuccess) {
      final decoded = normalizeJson(clientResponse.response?.data);
      final decoded2 = normalizeJson(decoded);

      onResponse(decoded2, DataSourceEnum.client);
    } else {
      ApiChecker.checkApi(clientResponse);
    }
  }

}
dynamic normalizeJson(dynamic data) {
  if (data is String) {
    try {
      return jsonDecode(data);
    } catch (_) {
      return data; // keep as-is if it's not JSON
    }
  }
  return data;
}