import 'dart:io';

import 'package:kk_thotix_m3aak/features/profile/domain/models/profile_model.dart';
import 'package:kk_thotix_m3aak/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:kk_thotix_m3aak/features/profile/domain/services/profile_service_interface.dart';

class ProfileService implements ProfileServiceInterface{
  ProfileRepositoryInterface profileRepositoryInterface;

  ProfileService({required this.profileRepositoryInterface});

  @override
  Future delete(int id) async{
    return await profileRepositoryInterface.delete(id);
  }

  @override
  Future getProfileInfo() async{
    return await profileRepositoryInterface.getProfileInfo();
  }

  @override
  Future updateProfile(ProfileModel userInfoModel, String pass, File? file, String token) async{
    return await profileRepositoryInterface.updateProfile(userInfoModel, pass, file, token);
  }

}