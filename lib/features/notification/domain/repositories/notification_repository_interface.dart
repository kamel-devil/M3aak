import 'package:kk_thotix_m3aak/interface/repo_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<dynamic>  seenNotification(int id);

}