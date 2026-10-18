import 'package:flutter/foundation.dart';

class FacebookLoginController with ChangeNotifier {
  Map? userData;
  String? loginStatusMessage;

  Future<void> login() async {
    loginStatusMessage = 'Facebook login is disabled.';
    notifyListeners();
  }
}
