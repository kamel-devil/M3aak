import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';

class GoogleSignInController with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? googleAccount;
  GoogleSignInClientAuthorization? auth;
  String errorMessage = '';
  bool _isInitialized = false;

  GoogleSignInController() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: AppConstants.googleServerClientId,
      );

      // Listen to authentication events like official example.
      _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent);
      _isInitialized = true;
    } catch (e) {
      errorMessage = _errorMessageFromSignInException(e);
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event) async {
    googleAccount = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (googleAccount != null) {
      const List<String> scopes = <String>['email'];
      auth = await googleAccount?.authorizationClient
          .authorizationForScopes(scopes);
    } else {
      auth = null;
    }

    notifyListeners();
  }

  Future<void> login() async {
    StreamSubscription<GoogleSignInAuthenticationEvent>? sub;
    try {
      errorMessage = '';

      if (AppConstants.googleServerClientId.trim().isEmpty ||
          AppConstants.googleServerClientId == 'client_id here') {
        errorMessage =
            'Google Sign-In is not configured. Add the real server client ID in AppConstants.googleServerClientId.';
        notifyListeners();
        return;
      }

      if (!_isInitialized) {
        await _initialize();
      }

      if (!_isInitialized) {
        if (errorMessage.isEmpty) {
          errorMessage = 'Google Sign-In initialization failed.';
        }
        notifyListeners();
        return;
      }

      final completer = Completer<void>();

      // Temporary subscription to wait for event
      sub = _googleSignIn.authenticationEvents.listen((event) async {
        await _handleAuthenticationEvent(event);
        if (!completer.isCompleted) completer.complete();
      });

      await _googleSignIn.authenticate();
      await completer.future; // Wait for the event
    } catch (e) {
      errorMessage = _errorMessageFromSignInException(e);
      notifyListeners();
    } finally {
      await sub?.cancel();
    }
  }

  String _errorMessageFromSignInException(dynamic e) {
    if (e is GoogleSignInException) {
      final String description = e.description ?? '';
      if (description.contains('28444')) {
        return 'Google Sign-In is not configured for this build. Verify SHA-1/SHA-256 for the active keystore in Firebase and keep AppConstants.googleServerClientId set to the Web OAuth client ID.';
      }

      return switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign in canceled',
        _ => 'GoogleSignInException ${e.code}: ${e.description}',
      };
    }
    return 'Unknown error: $e';
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
  }
}
