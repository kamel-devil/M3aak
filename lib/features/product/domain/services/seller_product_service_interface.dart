import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';

abstract class SellerProductServiceInterface {
  Future<dynamic> getSellerProductList(
      String sellerId, String offset, String productId,
      {String search = '',
      String? categoryIds,
      String? brandIds,
      String? authorIds,
      String? publishingIds,
      String? productType});

  Future<dynamic> getSellerWiseBestSellingProductList(
      String sellerId, String offset);

  Future<dynamic> getSellerWiseFeaturedProductList(
      String sellerId, String offset);

  Future<dynamic> getSellerWiseRecomendedProductList(
      String sellerId, String offset);

  Future<ApiResponseModel<T>> getShopAgainFromRecentStore<T>(
      {required DataSourceEnum source});
}
