import 'package:kk_thotix_m3aak/common/enums/data_source_enum.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';

abstract class BannerServiceInterface{
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});

}