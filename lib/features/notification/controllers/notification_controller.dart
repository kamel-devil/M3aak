import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/data/model/api_response.dart';
import 'package:kk_thotix_m3aak/features/notification/domain/models/notification_model.dart';
import 'package:kk_thotix_m3aak/features/notification/domain/services/notification_service_interface.dart';
import 'package:kk_thotix_m3aak/helper/api_checker.dart';

class NotificationController extends ChangeNotifier {
  final NotificationServiceInterface notificationServiceInterface;

  NotificationController({required this.notificationServiceInterface});

  NotificationItemModel? notificationModel;


  Future<void> getNotificationList(int offset) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.getList(offset : offset);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      final NotificationItemModel parsedNotificationItemModelResponse = NotificationItemModel.fromJson(apiResponse.response?.data);
      if(offset == 1){
        notificationModel = parsedNotificationItemModelResponse;
      }else{
        notificationModel?.notification?.addAll(parsedNotificationItemModelResponse.notification!);
        notificationModel?.offset = parsedNotificationItemModelResponse.offset!;
        notificationModel?.totalSize = parsedNotificationItemModelResponse.totalSize!;
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }



  Future<void> seenNotification(int id) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.seenNotification(id);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      getNotificationList(1);
    }
    notifyListeners();
  }
}
