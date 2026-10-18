import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/google_login_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/signup_model.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/social_login_model.dart';
import 'package:kk_thotix_m3aak/features/auth/enums/from_page.dart';
import 'package:kk_thotix_m3aak/features/auth/enums/social_login_options.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/existing_account_bottom_sheet.dart';
import 'package:kk_thotix_m3aak/features/profile/domain/models/profile_model.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart';
import 'package:kk_thotix_m3aak/helper/responsive_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLoginWidget extends StatefulWidget {
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  const SocialLoginWidget({super.key, this.fromPage, this.onLoginSuccess});

  @override
  SocialLoginWidgetState createState() => SocialLoginWidgetState();
}

class SocialLoginWidgetState extends State<SocialLoginWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;
    final socialLoginConfig =
        configModel?.customerLogin?.socialMediaLoginOptions;
    List<String> socialLoginList = [];

    // Facebook login disabled

    if (socialLoginConfig?.google == 1) {
      socialLoginList.add("google");
    }

    if (socialLoginConfig?.apple == 1) {
      socialLoginList.add("apple");
    }

    return Consumer<AuthController>(builder: (context, authProvider, _) {
      if (socialLoginList.length == 1) {
        return Row(children: [
          if (socialLoginConfig?.google == 1)
            Expanded(
                child: InkWell(
              onTap: () =>
                  googleLogin(context, widget.fromPage, widget.onLoginSuccess),
              child: SocialLoginButtonWidget(
                text: getTranslated('continue_with_google', context)!,
                image: Images.google,
              ),
            )),
          if (socialLoginConfig?.facebook == 1)
            Expanded(
              child: InkWell(
                onTap: () => facebookLogin(
                    context, widget.fromPage, widget.onLoginSuccess),
                child: SocialLoginButtonWidget(
                  text: getTranslated('continue_with_facebook', context)!,
                  image: Images.facebook,
                ),
              ),
            ),
          if (socialLoginConfig?.apple == 1 &&
              defaultTargetPlatform == TargetPlatform.iOS)
            Expanded(
              child: InkWell(
                onTap: () =>
                    appleLogin(context, widget.fromPage, widget.onLoginSuccess),
                child: SocialLoginButtonWidget(
                  text: getTranslated('continue_with_apple', context)!,
                  image: Images.appleLogo,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ]);
      } else if (socialLoginList.length == 2) {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (socialLoginConfig?.google == 1) ...[
            Expanded(
                child: InkWell(
              onTap: () =>
                  googleLogin(context, widget.fromPage, widget.onLoginSuccess),
              child: SocialLoginButtonWidget(
                text: getTranslated('google', context)!,
                image: Images.google,
              ),
            )),
            const SizedBox(width: Dimensions.paddingSizeDefault),
          ],
          if (socialLoginConfig?.facebook == 1) ...[
            Expanded(
                child: InkWell(
              onTap: () => facebookLogin(
                  context, widget.fromPage, widget.onLoginSuccess),
              child: SocialLoginButtonWidget(
                text: getTranslated('facebook', context)!,
                image: Images.facebook,
              ),
            )),
            socialLoginConfig?.apple == 1
                ? const SizedBox(width: Dimensions.paddingSizeDefault)
                : const SizedBox.shrink(),
          ],
          if (socialLoginConfig?.apple == 1 &&
              defaultTargetPlatform == TargetPlatform.iOS) ...[
            Expanded(
              child: InkWell(
                onTap: () =>
                    appleLogin(context, widget.fromPage, widget.onLoginSuccess),
                child: SocialLoginButtonWidget(
                  text: getTranslated('continue_with_apple', context)!,
                  image: Images.appleLogo,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ]);
      } else if (socialLoginList.length == 3) {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (socialLoginConfig?.google == 1) ...[
            InkWell(
              onTap: () =>
                  googleLogin(context, widget.fromPage, widget.onLoginSuccess),
              child: const SocialLoginButtonWidget(
                image: Images.google,
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
          if (socialLoginConfig?.facebook == 1) ...[
            InkWell(
              onTap: () => facebookLogin(
                  context, widget.fromPage, widget.onLoginSuccess),
              child: const SocialLoginButtonWidget(
                image: Images.facebook,
                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
          if (socialLoginConfig?.apple == 1 &&
              defaultTargetPlatform == TargetPlatform.iOS) ...[
            InkWell(
              onTap: () =>
                  appleLogin(context, widget.fromPage, widget.onLoginSuccess),
              child: SocialLoginButtonWidget(
                image: Images.appleLogo,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            ),
          ],
        ]);
      } else {
        return Container(
          height: 50,
          width: 50,
          color: Colors.red,
        );
      }
    });
  }
}

Future<void> route(
    bool isRoute,
    String? token,
    String? temporaryToken,
    ProfileModel? profileModel,
    String? errorMessage,
    String? loginMedium,
    String? phone,
    String? email,
    String? name,
    String? fromPage,
    VoidCallback? onLoginSuccess) async {
  final AuthController authProvider =
      Provider.of<AuthController>(Get.context!, listen: false);

  if (isRoute) {
    if (phone != null) {
      await authProvider.sendVerificationCode(
          Provider.of<SplashController>(Get.context!, listen: false)
              .configModel!,
          SignUpModel(email: null, phone: phone),
          type: 'phone',
          fromPage: FromPage.login,
          toNavigateScreen: fromPage,
          onLoginSuccess: onLoginSuccess);
    } else if (token != null) {
      authProvider.navigateToHome(fromPage, onLoginSuccess);
    } else if (temporaryToken != null && temporaryToken.isNotEmpty) {
      RouterHelper.getOtpRegistrationRoute(
          tempToken: temporaryToken,
          userInput: email ?? '',
          userName: name ?? '',
          action: RouteAction.pushNamedAndRemoveUntil,
          toNavigateScreen: fromPage,
          onLoginSuccess: onLoginSuccess);
    } else if (profileModel != null) {
      showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor:
              Theme.of(Get.context!).primaryColor.withValues(alpha: 0),
          builder: (con) => ExistingAccountBottomSheet(
                profileModel: profileModel,
                socialLoginMedium: loginMedium!,
                con: con,
              ));
    } else {
      showCustomSnackBar(errorMessage, Get.context!);
    }
  } else {
    showCustomSnackBar(errorMessage, Get.context!);
  }
}

Future<void> googleLogin(BuildContext context, String? fromPage,
    VoidCallback? onLoginSuccess) async {
  SocialLoginModel socialLogin = SocialLoginModel();
  final GoogleSignInController googleController =
      Provider.of<GoogleSignInController>(context, listen: false);

  try {
    await googleController.login();
    String? id, token, email, medium, name;
    if (context.mounted) {}
    if (googleController.googleAccount != null) {
      id = googleController.googleAccount!.id;
      email = googleController.googleAccount!.email;
      token = googleController.auth?.accessToken;
      name = googleController.googleAccount!.displayName;
      medium = 'google';
      log('eemail =>$email token =>$token');

      socialLogin.email = email;
      socialLogin.medium = medium;
      socialLogin.token = token;
      socialLogin.uniqueId = id;
      socialLogin.name = name;

      await Provider.of<AuthController>(Get.context!, listen: false)
          .socialLogin(socialLogin, route, fromPage, onLoginSuccess);
    } else if (googleController.errorMessage.isNotEmpty && context.mounted) {
      showCustomSnackBar(googleController.errorMessage, context);
    }
  } catch (er) {
    debugPrint('access token error is : $er');
    if (context.mounted) {
      showCustomSnackBar(
          googleController.errorMessage.isNotEmpty
              ? googleController.errorMessage
              : er.toString(),
          context);
    }
  }
}

Future<void> facebookLogin(BuildContext context, String? fromPage,
    VoidCallback? onLoginSuccess) async {
  // Facebook login disabled
}

Future<void> appleLogin(BuildContext context, String? fromPage,
    VoidCallback? onLoginSuccess) async {
  SocialLoginModel socialLogin = SocialLoginModel();
  try {
    String? id, token, email, medium;
    final credential = await SignInWithApple.getAppleIDCredential(scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName
    ]);

    id = credential.authorizationCode;
    email = await Provider.of<AuthController>(Get.context!, listen: false)
        .onConfigurationAppleEmail(credential);

    token = credential.authorizationCode;
    medium = 'apple';
    socialLogin.email = email;
    socialLogin.medium = medium;
    socialLogin.token = token;
    socialLogin.uniqueId = id;
    socialLogin.name = credential.givenName ?? '';
    await Provider.of<AuthController>(Get.context!, listen: false)
        .socialLogin(socialLogin, route, fromPage, onLoginSuccess);

    log('id token =>${credential.identityToken}\n===> Identifier${credential.userIdentifier}\n==>Given Name ${credential.familyName}');
  } catch (er) {
    debugPrint('access token error is : $er');
  }
}

class SocialLoginButtonWidget extends StatelessWidget {
  final String? text;
  final String image;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final SocialLoginOption? option;
  const SocialLoginButtonWidget(
      {super.key,
      this.text,
      required this.image,
      this.color,
      this.padding,
      this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: padding ??
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: .06)
            : Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .95), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A6F6B).withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            color: color,
            height: ResponsiveHelper.isTab(context) ? 22 : 18,
            width: ResponsiveHelper.isTab(context) ? 22 : 18,
          ),
          if (text != null) ...[
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              text!,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          ],
        ],
      ),
    );
  }
}
