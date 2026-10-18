import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/auth_ui.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/register_model.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/condition_check_box_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/social_login_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/helper/velidate_check.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  const SignUpWidget(
      {super.key,
      required this.fromLogout,
      this.fromPage,
      this.onLoginSuccess});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referController = TextEditingController();

  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referFocus = FocusNode();

  RegisterModel register = RegisterModel();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  Future<void> route(bool isRoute, String? token, String? tempToken,
      String? errorMessage) async {
    var splashController =
        Provider.of<SplashController>(context, listen: false);
    var authController = Provider.of<AuthController>(context, listen: false);
    var profileController =
        Provider.of<ProfileController>(context, listen: false);
    String phone =
        authController.countryDialCode + _phoneController.text.trim();
    if (isRoute) {
      if (splashController.configModel!.emailVerification!) {
        authController
            .sendOtpToEmail(_emailController.text.toString(), tempToken!)
            .then((value) async {
          if (value.response?.statusCode == 200) {
            authController.updateEmail(_emailController.text.toString());
            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) =>
            //     VerificationScreen(tempToken,'',_emailController.text.toString())), (route) => false);
          }
        });
      } else if (splashController.configModel!.phoneVerification!) {
        authController.sendOtpToPhone(phone, tempToken!).then((value) async {
          if (value.isSuccess) {
            authController.updatePhone(phone);
            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) =>
            //     VerificationScreen(tempToken,phone,'')), (route) => false);
          }
        });
      } else {
        await profileController.getUserInfo(context);

        _emailController.clear();
        _passwordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _phoneController.clear();
        _confirmPasswordController.clear();
        _referController.clear();
      }
    } else {
      showCustomSnackBar(errorMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(context, listen: false).setCountryCode(
        CountryCode.fromCountryCode(
                Provider.of<SplashController>(context, listen: false)
                    .configModel!
                    .countryCode!)
            .dialCode!,
        notify: false);
  }

  @override
  Widget build(BuildContext context) {
    final config =
        Provider.of<SplashController>(context, listen: false).configModel;
    final isSocialLoginEnabled =
        config?.customerLogin?.loginOption?.socialMediaLogin == 1;
    final isOtpLoginEnabled = config?.customerLogin?.loginOption?.otpLogin == 1;
    return Column(children: [
      Consumer<AuthController>(builder: (context, authProvider, _) {
        return Consumer<SplashController>(
            builder: (context, splashProvider, _) {
          return Form(
            key: signUpFormKey,
            child: Column(children: [
              AuthFormCard(child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(
                  margin: EdgeInsets.zero,
                  child: CustomTextFieldWidget(
                      hintText: getTranslated('first_name', context),
                      labelText: getTranslated('first_name', context),
                      labelTextStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      inputType: TextInputType.name,
                      required: true,
                      focusNode: _fNameFocus,
                      nextFocus: _lNameFocus,
                      capitalization: TextCapitalization.words,
                      controller: _firstNameController,
                      validator: (value) => ValidateCheck.validateEmptyText(
                          value, "first_name_field_is_required")))),
              const SizedBox(width: 10),
              Expanded(child: 

              Container(
                  margin: EdgeInsets.zero,
                  child: CustomTextFieldWidget(
                      hintText: getTranslated('last_name', context),
                      labelText: getTranslated('last_name', context),
                      labelTextStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      focusNode: _lNameFocus,
                      nextFocus: _emailFocus,
                      required: true,
                      capitalization: TextCapitalization.words,
                      controller: _lastNameController,
                      validator: (value) => ValidateCheck.validateEmptyText(
                          value, "last_name_field_is_required")))),
              ]),

              Container(
                  margin: const EdgeInsets.only(top: Dimensions.marginSizeSmall),
                  child: CustomTextFieldWidget(
                      hintText: getTranslated('enter_your_email', context),
                      labelText: getTranslated('enter_your_email', context),
                      labelTextStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      focusNode: _emailFocus,
                      nextFocus: _phoneFocus,
                      required: true,
                      inputType: TextInputType.emailAddress,
                      controller: _emailController,
                      prefixIcon: Images.email,
                      validator: (value) =>
                          ValidateCheck.validateEmail(value))),

              Container(
                  margin: const EdgeInsets.only(top: Dimensions.marginSizeSmall),
                  child: CustomTextFieldWidget(
                      hintText: getTranslated('enter_mobile_number', context),
                      labelText: getTranslated('enter_mobile_number', context),
                      labelTextStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      nextFocus: _passwordFocus,
                      required: true,
                      showCodePicker: true,
                      countryDialCode: authProvider.countryDialCode,
                      onCountryChanged: (CountryCode countryCode) {
                        _phoneFocus.requestFocus();
                        authProvider.countryDialCode = countryCode.dialCode!;
                        authProvider.setCountryCode(countryCode.dialCode!);
                      },
                      isAmount: true,
                      validator: (value) => ValidateCheck.validatePhoneNoText(
                          value,
                          authProvider.countryDialCode,
                          "phone_must_be_required"),
                      inputAction: TextInputAction.next,
                      inputType: TextInputType.phone)),

              Container(
                  margin: const EdgeInsets.only(top: Dimensions.marginSizeSmall),
                  child: CustomTextFieldWidget(
                      hintText:
                          getTranslated('minimum_password_length', context),
                      labelText: getTranslated('password', context),
                      labelTextStyle: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      isPassword: true,
                      required: true,
                      nextFocus: _confirmPasswordFocus,
                      inputAction: TextInputAction.next,
                      validator: (value) => ValidateCheck.validatePassword(
                          value, "password_must_be_required"),
                      prefixIcon: Images.pass)),
              _PasswordStrength(controller: _passwordController),

              Hero(
                  tag: 'user',
                  child: Container(
                      margin: const EdgeInsets.only(top: Dimensions.marginSizeSmall),
                      child: CustomTextFieldWidget(
                          isPassword: true,
                          required: true,
                          hintText: getTranslated('re_enter_password', context),
                          labelText:
                              getTranslated('re_enter_password', context),
                          labelTextStyle: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          inputAction: TextInputAction.done,
                          validator: (value) =>
                              ValidateCheck.validateConfirmPassword(
                                  value, _passwordController.text.trim()),
                          prefixIcon: Images.pass))),

              //if(splashProvider.configModel!.refEarningStatus != null && splashProvider.configModel!.refEarningStatus == "1")
              // Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault),
              //   child: Row(children: [Text(getTranslated('refer_code', context)??'')])),
              if (splashProvider.configModel?.refEarningStatus != null &&
                  splashProvider.configModel?.refEarningStatus == "1")
                Container(
                    margin: const EdgeInsets.only(top: Dimensions.marginSizeSmall),
                    child: CustomTextFieldWidget(
                        hintText: getTranslated('enter_refer_code', context),
                        labelText: getTranslated('referral_code', context),
                        labelTextStyle: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color:
                                Theme.of(context).textTheme.bodyLarge!.color),
                        controller: _referController,
                        focusNode: _referFocus,
                        prefixIcon: Images.referImage,
                        prefixColor: Theme.of(context).primaryColor,
                        inputAction: TextInputAction.done)),

              const SizedBox(height: Dimensions.paddingSizeSmall),
              const ConditionCheckBox(),

              Container(
                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                  child: Hero(
                    tag: 'onTap',
                    child: CustomButton(
                      isLoading: authProvider.isLoading,
                      onTap: authProvider.isAcceptTerms
                          ? () {
                              String firstName =
                                  _firstNameController.text.trim();
                              String lastName = _lastNameController.text.trim();
                              String email = _emailController.text.trim();
                              String phoneNumber =
                                  authProvider.countryDialCode +
                                      _phoneController.text.trim();
                              String password = _passwordController.text.trim();

                              if (signUpFormKey.currentState?.validate() ??
                                  false) {
                                register.fName = firstName;
                                register.lName = lastName;
                                register.email = email;
                                register.phone = phoneNumber;
                                register.password = password;
                                register.referCode =
                                    _referController.text.trim();
                                authProvider.registration(
                                    register,
                                    route,
                                    config!,
                                    widget.fromPage,
                                    widget.onLoginSuccess);
                              }
                            }
                          : null,
                      buttonText: getTranslated('sign_up', context),
                    ),
                  )),
              ])),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              if (isSocialLoginEnabled && !isOtpLoginEnabled)
                AuthDivider(text: getTranslated('or_sign_in_with', context)!),

              if (isSocialLoginEnabled)
                const SizedBox(height: Dimensions.paddingSizeSmall),

              if (isSocialLoginEnabled)
                Center(
                    child: SocialLoginWidget(
                        fromPage: widget.fromPage,
                        onLoginSuccess: widget.onLoginSuccess)),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              authProvider.isLoading
                  ? const SizedBox()
                  : Center(
                      child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraLarge),
                      child: InkWell(
                        onTap: () {
                          authProvider.getGuestIdUrl();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: '${getTranslated('already_have_account', context)!} ',
                                style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor)),
                            TextSpan(
                                text: getTranslated('sign_in', context)!,
                                style: textBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).primaryColor)),
                          ])),
                        ),
                      ),
                    )),
            ]),
          );
        });
      }),
    ]);
  }
}

/// Four-segment password strength bar that updates as the user types.
class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.controller});
  final TextEditingController controller;

  static int _score(String v) {
    int score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[a-z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox(height: 4);
        final int score = _score(value.text);
        final Color color = score <= 1
            ? AppPalette.error
            : score == 2
                ? AppPalette.warning
                : AppPalette.success;
        final String label = getTranslated(
                score <= 1 ? 'password_weak' : score == 2 ? 'password_medium' : 'password_strong', context) ??
            '';
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < score ? color : AppPalette.tint(context),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(label, style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
          ]),
        );
      },
    );
  }
}
