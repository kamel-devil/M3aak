import 'package:kk_thotix_m3aak/features/search_product/domain/repositories/search_product_repository_interface.dart';
import 'package:kk_thotix_m3aak/features/search_product/domain/services/search_product_service_interface.dart';
import 'package:dio/dio.dart';

class SearchProductService implements SearchProductServiceInterface{
  SearchProductRepositoryInterface searchProductRepositoryInterface;
  SearchProductService({required this.searchProductRepositoryInterface});

  @override
  Future<bool> clearSavedSearchProductName() async{
    return searchProductRepositoryInterface.clearSavedSearchProductName();
  }

  @override
  List<String> getSavedSearchProductName(){
    return searchProductRepositoryInterface.getSavedSearchProductName();
  }

  @override
  Future getSearchProductList(String query, String? categoryIds, String? brandIds, String? authorIds, String? publishingIds, String? sort, String? priceMin, String? priceMax, int offset, String? productType, {String? code}) async{
    return await searchProductRepositoryInterface.getSearchProductList(query, categoryIds, brandIds, authorIds, publishingIds, sort, priceMin, priceMax, offset, productType, code: code);
  }

  @override
  Future getSearchProductName(String name, {CancelToken? cancelToken}) async{
    return searchProductRepositoryInterface.getSearchProductName(name, cancelToken: cancelToken);
  }

  @override
  Future saveSearchProductName(String searchAddress) async{
    return await searchProductRepositoryInterface.saveSearchProductName(searchAddress);
  }

  @override
  Future getAuthorList(int? sellerId){
    return searchProductRepositoryInterface.getAuthorList(sellerId);
  }

  @override
  Future getPublishingHouse(int? sellerId){
    return searchProductRepositoryInterface.getPublishingHouse(sellerId);
  }


}