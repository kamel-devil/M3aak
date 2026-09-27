import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';

abstract class BrandServiceInterface {
  Future<dynamic> getSellerWiseBrandList(int sellerId);
  Future<dynamic> getBrandList<T>({int offset, required DataSourceEnum source});
  Future<dynamic> getList();
}
