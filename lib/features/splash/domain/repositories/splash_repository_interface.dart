import 'package:kk_thotix_m3aak/interface/repo_interface.dart';

abstract class SplashRepositoryInterface implements RepositoryInterface{

  Future<dynamic> getConfig();
  Future<dynamic> getBusinessPages(String type);
  void initSharedData();
  String getCurrency();
  void setCurrency(String currencyCode);
  void disableIntro();
  bool? showIntro();
}