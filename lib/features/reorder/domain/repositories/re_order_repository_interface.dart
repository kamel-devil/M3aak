import 'package:kk_thotix_m3aak/interface/repo_interface.dart';

abstract class ReOrderRepositoryInterface<T> extends RepositoryInterface{

  Future<dynamic> reorder(String orderId);


}