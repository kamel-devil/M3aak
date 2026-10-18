import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/product/domain/models/product_model.dart';
import 'package:kk_thotix_m3aak/features/product/domain/services/seller_product_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';
import 'package:kk_thotix_m3aak/features/shop/domain/models/shop_again_from_recent_store_model.dart';
import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';
import 'package:kk_thotix_m3aak/helper/data_sync_helper.dart';

class SellerProductController extends ChangeNotifier {
  final SellerProductServiceInterface? sellerProductServiceInterface;
  SellerProductController({required this.sellerProductServiceInterface});

  ProductModel? sellerProduct;
  ProductModel? sellerMoreProduct;

  bool _isFilterApply = false;
  bool  get isFilterApply => _isFilterApply;

  Future <ApiResponseModel> getSellerProductList(String sellerId, int offset, String productId, {
    bool reload = true,
    String search = '',
    String? categoryIds = '[]',
    String? brandIds = '[]',
    String? authorIds = '[]',
    String? publishingIds = '[]',
    String? productType = 'all',
  }) async {

    ApiResponseModel apiResponse = await sellerProductServiceInterface!.getSellerProductList(
      sellerId, offset.toString(),
      productId, categoryIds : categoryIds,
      brandIds: brandIds, search: search,
      authorIds: authorIds, publishingIds: publishingIds,
      productType: productType
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
      if(offset == 1){
        sellerProduct = parsedProductModelResponse;
      }else{
        sellerProduct?.products?.addAll(parsedProductModelResponse.products!);
        sellerProduct?.offset = (parsedProductModelResponse.offset!);
        sellerProduct?.totalSize = parsedProductModelResponse.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }



  Future <ApiResponseModel> getSellerMoreProductList(String sellerId, int offset, String productId) async {
    sellerMoreProduct = null;

    ApiResponseModel apiResponse = await sellerProductServiceInterface!.getSellerProductList( sellerId, offset.toString(), productId );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1){
        sellerMoreProduct = ProductModel.fromJson(apiResponse.response!.data);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  ProductModel? productModel;

  Future<void> getSellerWiseBestSellingProductList(String sellerId, int offset) async {
    ApiResponseModel apiResponse = await sellerProductServiceInterface!.getSellerWiseBestSellingProductList(sellerId, offset.toString());
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
      if(offset == 1){
        productModel = null;
        productModel = parsedProductModelResponse;
      }else {
        productModel!.products!.addAll(parsedProductModelResponse.products!);
        productModel!.offset = parsedProductModelResponse.offset;
        productModel!.totalSize = parsedProductModelResponse.totalSize;
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }

    notifyListeners();
  }

  ProductModel? sellerWiseFeaturedProduct;

  Future<void> getSellerWiseFeaturedProductList(String sellerId, int offset) async {
    ApiResponseModel apiResponse = await sellerProductServiceInterface!.getSellerWiseFeaturedProductList(sellerId, offset.toString());
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
      if(offset == 1){
        sellerWiseFeaturedProduct = null;
        sellerWiseFeaturedProduct = parsedProductModelResponse;

      }else {
        sellerWiseFeaturedProduct!.products!.addAll(parsedProductModelResponse.products!);
        sellerWiseFeaturedProduct!.offset = parsedProductModelResponse.offset;
        sellerWiseFeaturedProduct!.totalSize = parsedProductModelResponse.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  ProductModel? sellerWiseRecommendedProduct;
  Future<void> getSellerWiseRecommendedProductList(String sellerId, int offset) async {
    ApiResponseModel apiResponse = await sellerProductServiceInterface!.getSellerWiseRecomendedProductList(sellerId, offset.toString());
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final ProductModel parsedProductModelResponse = ProductModel.fromJson(apiResponse.response!.data);
      if(offset == 1){
        sellerWiseRecommendedProduct = null;
        sellerWiseRecommendedProduct = parsedProductModelResponse;
      }else {
        sellerWiseRecommendedProduct!.products!.addAll(parsedProductModelResponse.products!);
        sellerWiseRecommendedProduct!.offset = parsedProductModelResponse.offset;
        sellerWiseRecommendedProduct!.totalSize = parsedProductModelResponse.totalSize;
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }

  List<ShopAgainFromRecentStoreModel> shopAgainFromRecentStoreList = [];

  Future<void> getShopAgainFromRecentStore() async {
    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => sellerProductServiceInterface!.getShopAgainFromRecentStore(source: DataSourceEnum.local),
      fetchFromClient: () => sellerProductServiceInterface!.getShopAgainFromRecentStore(source: DataSourceEnum.client),
      onResponse: (data, source) {
        shopAgainFromRecentStoreList = [];
        data.forEach((store) => shopAgainFromRecentStoreList.add(ShopAgainFromRecentStoreModel.fromJson(store)));
        notifyListeners();
      },
    );
  }

  void clearSellerProducts() {
    sellerWiseFeaturedProduct = null;
    sellerWiseRecommendedProduct = null;
    _isFilterApply = false;
  }

  void setFilterApply(bool value, {bool isUpdate = true}) {
    _isFilterApply = value;
    if(isUpdate) {
      notifyListeners();
    }
  }


}
