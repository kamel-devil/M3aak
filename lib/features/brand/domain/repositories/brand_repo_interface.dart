import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';
import 'package:kk_thotix_m3aak/interface/repo_interface.dart';

abstract class BrandRepoInterface implements RepositoryInterface {
  Future<dynamic> getBrandList<T>({int offset, required DataSourceEnum source});

  Future<dynamic> getSellerWiseBrandList(int sellerId);
}
