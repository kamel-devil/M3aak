import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/auth_ui.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/signup_model.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/user_log_data.dart';
import 'package:kk_thotix_m3aak/features/auth/enums/from_page.dart';
import 'package:kk_thotix_m3aak/features/order_details/controllers/order_details_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart';
import 'package:kk_thotix_m3aak/helper/email_checker_helper.dart';
import 'package:kk_thotix_m3aak/helper/number_checker_helper.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';


class VerificationScreen extends StatefulWidget {
  final String? userInput;
  final FromPage fromPage;
  final bool fromDigitalProduct;
  final int? orderId;
  final String? session;
  final String? toNavigateScreen;
  final VoidCallback? onLoginSuccess;
  const VerificationScreen(this.userInput, this.fromPage,
   {super.key, this.session, this.fromDigitalProduct = false, this.orderId, this.toNavigateScreen, this.onLoginSuccess});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;
  int? _seconds = 0;

  bool? isPhone;

  @override
  void initState() {
    super.initState();
    isPhone = EmailCheckerHelper.isNotValid(widget.userInput.toString());
    _startTimer();
  }

  void _startTimer() {
    _seconds = (isPhone! && Provider.of<SplashController>(context, listen: false).configModel?.customerVerification?.firebase == 1) ? 30 : Provider.of<SplashController>(context, listen: false).configModel?.otpResendTime ?? 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }



  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    int minutes = (_seconds! / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');

    final isPhone = EmailCheckerHelper.isNotValid(widget.userInput.toString());
    final Size size = MediaQuery.of(context).size;
    final ConfigModel config = Provider.of<SplashController>(context, listen: false).configModel!;
    final bool isFirebaseOTP = config.customerVerification!.status ==1 && config.customerVerification?.firebase == 1;

    return Scaffold(
      body: SafeArea(child: Consumer<SplashController>(
          builder: (context, splashProvider, _) {
            return Stack(
              children: [

                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Consumer<AuthController>(
                    builder: (context, authProvider, child) => Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      widget.fromDigitalProduct? CustomAppBar(title: '${getTranslated('verify_otp', context)}'): const SizedBox(),

                      if (!widget.fromDigitalProduct)
                        widget.fromPage == FromPage.forgetPassword
                            ? AuthStepHeader(step: 2, total: 3, onBack: () => Navigator.pop(context))
                            : Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AuthBackButton(onTap: () => Navigator.pop(context))),

                      SizedBox(height: size.height * 0.05),

                      AuthIllustration(
                        icon: isPhone ? Icons.sms_rounded : Icons.mark_email_read_rounded,
                        title: getTranslated('otp_verification', context) ?? '',
                        description: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(children: [

                            TextSpan(
                              text: getTranslated('we\'ve_sent_verification_code', context),
                              style: titilliumRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),

                            TextSpan(
                              text: " \u2066${widget.userInput}\u2069 ",
                              style: textBold.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),

                          ]),
                        ),
                      ),

                      const SizedBox(height: 28),

                      AuthFormCard(child: Column(children: [
                      Padding(padding: const EdgeInsets.only(bottom: 18),
                        child: Directionality(textDirection: TextDirection.ltr, child: PinCodeTextField(
                          length: 6,
                          appContext: context,
                          obscureText: false,
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 54,
                            fieldWidth: 44,
                            borderWidth: 1.5,
                            selectedBorderWidth: 2,
                            borderRadius: BorderRadius.circular(16),
                            selectedColor: Theme.of(context).primaryColor,
                            selectedFillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: .08) : Colors.white,
                            inactiveFillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: .04) : Colors.white.withValues(alpha: .8),
                            inactiveColor: Theme.of(context).primaryColor.withValues(alpha: .18),
                            activeColor: Theme.of(context).primaryColor,
                            activeFillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: .08) : Colors.white,
                          ),
                          textStyle: titilliumBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: authProvider.updateVerificationCode,
                          beforeTextPaste: (text) {
                            return true;
                          },
                        )),
                      ),


                      if(widget.fromDigitalProduct)
                        Padding(padding: EdgeInsets.zero,
                          child:  CustomButton(buttonText: getTranslated('verify', context),
                              onTap: (){
                                Provider.of<OrderDetailsController>(context, listen: false).verifyDigitalProductOtp(orderId: widget.orderId!,
                                    otp: authProvider.verificationCode).then((value) {
                                  if(value.response?.statusCode == 200) {
                                    if(context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }else {
                                    if(context.mounted) {
                                      showCustomSnackBar(getTranslated('input_valid_otp', context), context, isError: true);
                                    }
                                  }});})),

                      if(!widget.fromDigitalProduct)
                        Padding(padding: EdgeInsets.zero,
                          child: (authProvider.isEnableVerificationCode && !authProvider.resendButtonLoading) ?
                          !authProvider.isPhoneNumberVerificationButtonLoading ?
                          CustomButton(
                            buttonText: getTranslated('verify', context),
                            backgroundColor: !authProvider.isEnableVerificationCode ? Theme.of(context).disabledColor : null,
                            onTap: () {
                              if (widget.fromPage == FromPage.login) {
                                if(config.customerVerification!.status == 1){
                                  if(isPhone && isFirebaseOTP){
                                    authProvider.firebaseOtpLogin(
                                      phoneNumber: widget.userInput ?? '',
                                      session: '${widget.session}',
                                      otp: authProvider.verificationCode,
                                    );
                                  } else if(isPhone && config.customerVerification?.phone == 1) {
                                    authProvider.verifyPhone(widget.userInput ?? '', '').then((value) {
                                      if (value.isSuccess && context.mounted) {
                                        authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
                                      }
                                    });
                                  } else if(!isPhone && config.customerVerification?.email == 1) {
                                    authProvider.verifyEmail(widget.userInput ?? '').then((value) {
                                      if (value.isSuccess && context.mounted) {
                                        authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
                                      }
                                    });
                                  }
                                }
                              } else if(widget.fromPage == FromPage.otpLogin) {
                                if (config.customerVerification?.firebase == 1) {
                                  authProvider.firebaseOtpLogin(
                                    phoneNumber: widget.userInput ?? '',
                                    session: authProvider.verificationID ?? '',
                                    otp: authProvider.verificationCode,
                                    toNavigateScreen: widget.toNavigateScreen,
                                    onLoginSuccess: widget.onLoginSuccess
                                  );
                                } else {
                                  authProvider.verifyPhoneForOtp(widget.userInput ?? '').then((value) {

                                    final (responseModel, tempToken) = value;
                                    if((responseModel != null && responseModel.isSuccess) && tempToken == null) {
                                      if (authProvider.isActiveRememberMe) {
                                        String userCountryCode = NumberCheckerHelper.getCountryCode(widget.userInput)!;

                                        authProvider.saveUserEmailAndPassword(UserLogData(
                                          countryCode:  userCountryCode,
                                          phoneNumber: widget.userInput?.substring(userCountryCode.length),
                                          email: null,
                                          password: null,
                                        ));
                                      } else {
                                        authProvider.clearUserEmailAndPassword();
                                      }
                                      if(context.mounted) {
                                        authProvider.navigateToHome(widget.toNavigateScreen, widget.onLoginSuccess);
                                      }

                                    }else if((responseModel != null && responseModel.isSuccess) && tempToken != null) {
                                      if(context.mounted) {
                                        RouterHelper.getOtpRegistrationRoute(
                                          tempToken: tempToken,
                                          userInput: widget.userInput?? '',
                                          action: RouteAction.push,
                                          toNavigateScreen: widget.toNavigateScreen,
                                          onLoginSuccess: widget.onLoginSuccess,
                                        );
                                      }
                                    }
                                  });
                                }
                              } else if(widget.fromPage == FromPage.profile) {
                                String type = isPhone ? 'phone': 'email';
                                authProvider.verifyProfileInfo(widget.userInput!,type).then((value) {
                                  if(value.isSuccess && context.mounted) {
                                    RouterHelper.getProfileScreen1Route(action: RouteAction.pushNamedAndRemoveUntil);
                                  }
                                });
                              } else {
                                if (isFirebaseOTP && isPhone) {authProvider.firebaseOtpLogin(
                                  phoneNumber: widget.userInput ?? '',
                                  session: '${widget.session}',
                                  otp: authProvider.verificationCode,
                                  isForgetPassword: true,
                                );
                                } else {
                                  authProvider.verifyToken(widget.userInput ?? '').then((value) {
                                    if (value.isSuccess && context.mounted) {
                                      RouterHelper.getResetPasswordRoute(
                                        mobileNumber: widget.userInput ?? '',
                                        otp: authProvider.verificationCode,
                                        action: RouteAction.push,
                                      );
                                    } else {
                                      if(context.mounted) {
                                        showCustomSnackBar(value.message!, context);
                                      }
                                    }
                                  });
                                }
                              }
                            },
                          ):  Center(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))) : const  SizedBox.shrink(),
                        ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),


                      if(_seconds! <= 0)
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(getTranslated('i_didnt_receive_the_code', context)!),

                          authProvider.resendButtonLoading ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 02,)) : InkWell(
                            onTap: () async {
                              if (widget.fromPage != FromPage.forgetPassword) {
                                await authProvider.sendVerificationCode(
                                  config,
                                  SignUpModel(
                                    phone: widget.userInput,
                                    email: widget.userInput,
                                  ),
                                  type: isPhone ? 'phone' : 'email',
                                  fromPage: FromPage.verification,
                                  isResend: true
                                );
                                _startTimer();
                              } else {
                                _startTimer();
                                await authProvider.forgetPassword(
                                  config: config,
                                  phoneOrEmail: widget.userInput ?? '',
                                  type: isPhone ? 'phone' : 'email',
                                  isResend: true
                                ).then((value) {
                                  if (value!.isSuccess && context.mounted) {
                                    showCustomSnackBar(getTranslated('resend_code_successful', context), context, isError: false);
                                  } else {
                                    if(context.mounted){
                                      showCustomSnackBar(value.message!,  context);
                                    }
                                  }
                                });
                              }
                            },
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: Text(getTranslated('resend_code', context)??"",
                              style: textBold.copyWith(color: Theme.of(context).primaryColor))
                            )
                          )
                        ],
                        ),
                      ),

                      if(_seconds! > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${getTranslated('resend_code', context)} ${getTranslated('after', context)} ',
                                style: textRegular.copyWith(color: Theme.of(context).hintColor)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text('$minutesStr:${(_seconds! % 60).toString().padLeft(2, '0')}',
                                    style: textBold.copyWith(color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          ]),
                        ),
                      ])),





                    ],
                    ),
                  ),
                )

              ],
            );
          }
      )),
    );
  }
}
