import 'package:kk_thotix_m3aak/interface/repo_interface.dart';
import 'package:dio/dio.dart';

abstract class SearchProductRepositoryInterface implements RepositoryInterface{

  Future<dynamic> getSearchProductList(String query, String? categoryIds, String? brandIds, String? authorIds, String? publishingIds, String? sort, String? priceMin, String? priceMax, int offset, String? productType, {String? code});
  Future<dynamic> getSearchProductName(String name, {CancelToken? cancelToken});
  Future<dynamic> saveSearchProductName(String searchAddress);
  List<String> getSavedSearchProductName();
  Future<bool> clearSavedSearchProductName();
  Future<dynamic> getAuthorList(int? sellerId);
  Future<dynamic> getPublishingHouse(int? sellerId);
}