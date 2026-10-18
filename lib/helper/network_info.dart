import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:provider/provider.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);


  Future<bool> get isConnected async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi)  || result.contains(ConnectivityResult.mobile);
  }


  static void checkConnectivity(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(Provider.of<SplashController>(Get.context!, listen: false).firstTimeConnectionCheck) {
        Provider.of<SplashController>(Get.context!, listen: false).setFirstTimeConnectionCheck(false);
      }else {
        final bool isConnected = result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.mobile);
        showConnectionToast(
          connected: isConnected,
          onRetry: () async {
            final List<ConnectivityResult> now = await Connectivity().checkConnectivity();
            final bool back = now.contains(ConnectivityResult.wifi) ||
                now.contains(ConnectivityResult.mobile);
            if (back) showConnectionToast(connected: true);
          },
        );
      }
    });
  }
}
