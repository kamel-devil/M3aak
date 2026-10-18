import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_loader_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/auth/domain/models/signup_model.dart';
import 'package:kk_thotix_m3aak/features/auth/enums/from_page.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/profile/domain/models/profile_model.dart';
import 'package:kk_thotix_m3aak/features/profile/widgets/delete_account_bottom_sheet_widget.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/features/splash/domain/models/config_model.dart';
import 'package:kk_thotix_m3aak/helper/image_size_checker.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen1 extends StatefulWidget {
  final bool formVerification;
  const ProfileScreen1({super.key, this.formVerification = false});

  @override
  State<ProfileScreen1> createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isMailChanged = false;
  bool isPhoneChanged = false;

  File? file;
  final picker = ImagePicker();

  void _choose() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

      if (pickedFile != null) {
        double value =  await ImageSize.getImageSizeFromXFile(pickedFile);
        ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

        if(value > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
          showCustomSnackBar('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!);
          return;
        } else {
          setState(() {
            file = File(pickedFile.path);
          });
        }

      }
  }

  final phoneToolTipKey = GlobalKey<State<Tooltip>>();
  final emailToolTipKey = GlobalKey<State<Tooltip>>();

  Future<void> _updateUserAccount() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if( 1 != 1
    // Provider.of<ProfileController>(context, listen: false).userInfoModel!.fName == _firstNameController.text
    //     && Provider.of<ProfileController>(context, listen: false).userInfoModel!.lName == _lastNameController.text
    //     && Provider.of<ProfileController>(context, listen: false).userInfoModel!.phone == _phoneController.text
    //     && Provider.of<ProfileController>(context, listen: false).userInfoModel!.email == _emailController.text
    //     && file == null && _passwordController.text.isEmpty && _confirmPasswordController.text.isEmpty
    ) {

      showCustomSnackBar(getTranslated('change_something_to_update', context), context);

    }

    else if (firstName.isEmpty) {
      showCustomSnackBar(getTranslated('first_name_is_required', context), context);
    }

    else if(lastName.isEmpty) {
      showCustomSnackBar(getTranslated('last_name_is_required', context), context);
    }

    else if (email.isEmpty) {
      showCustomSnackBar(getTranslated('email_is_required', context), context);

    }

    else if (phoneNumber.isEmpty) {
      showCustomSnackBar(getTranslated('phone_must_be_required', context), context);
    }

    else if((password.isNotEmpty && password.length < 8) || (confirmPassword.isNotEmpty && confirmPassword.length < 8)) {
      showCustomSnackBar(getTranslated('minimum_password_is_8_character', context), context);
    }

    else if(password != confirmPassword) {
      showCustomSnackBar(getTranslated('confirm_password_not_matched', context), context);
    }

    else {
      ProfileModel updateUserInfoModel = Provider.of<ProfileController>(context, listen: false).userInfoModel!;
      updateUserInfoModel.method = 'put';
      updateUserInfoModel.fName = _firstNameController.text;
      updateUserInfoModel.lName = _lastNameController.text;
      updateUserInfoModel.phone = _phoneController.text;
      updateUserInfoModel.email = _emailController.text;
      String pass = _passwordController.text;

      await Provider.of<ProfileController>(context, listen: false).updateUserInfo(
        updateUserInfoModel, pass, file, Provider.of<AuthController>(context, listen: false).getUserToken(),
      ).then((response) {
        if(response.isSuccess) {
          Provider.of<ProfileController>(Get.context!, listen: false).getUserInfo(Get.context!);
          showCustomSnackBar(getTranslated('profile_info_updated_successfully', Get.context!), Get.context!, isError: false);

          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() {});
        } else {
          showCustomSnackBar(response.message??'', Get.context!, isError: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    final config = splashProvider.configModel;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(widget.formVerification) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: getTranslated('profile', context),
          onBackPressed: () {
            if(Navigator.of(context).canPop()){
              Navigator.of(context).pop();
            }else{
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
            }
          },
        ),
        body: Consumer<AuthController>(
          builder: (context,authController,_) {
            return Consumer<ProfileController>(
              builder: (context,profile,_) {
                _firstNameController.text = profile.userInfoModel?.fName ?? '';
                _lastNameController.text = profile.userInfoModel?.lName ?? '';
                _emailController.text = profile.userInfoModel?.email ?? '';
                _phoneController.text = profile.userInfoModel?.phone ?? '';
                return profile.userInfoModel != null ?  Column(children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: FadeSlideIn(child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppPalette.brandGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: AppPalette.primaryDeep.withValues(alpha: .28), blurRadius: 28, offset: const Offset(0, 12))],
                      ),
                      child: Row(children: [
                        Stack(clipBehavior: Clip.none, children: [
                          Container(
                            width: 80, height: 80,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .35),
                              border: Border.all(color: Colors.white.withValues(alpha: .7), width: 1.5),
                            ),
                            child: ClipOval(
                              child: file == null
                                  ? CustomImageWidget(image: "${profile.userInfoModel?.imageFullUrl?.path}", fit: BoxFit.cover)
                                  : Image.file(file!, fit: BoxFit.cover),
                            ),
                          ),
                          PositionedDirectional(
                            bottom: -2, end: -2,
                            child: Material(
                              color: AppPalette.primaryDeep,
                              shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _choose,
                                child: const SizedBox(width: 34, height: 34,
                                    child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 17)),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${profile.userInfoModel?.fName ?? ''} ${profile.userInfoModel?.lName ?? ''}'.trim(),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge + 2)),
                          if ((profile.userInfoModel?.email ?? '').isNotEmpty)
                            Text(profile.userInfoModel!.email!,
                                maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
                                style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: Dimensions.fontSizeSmall + 1)),
                        ])),
                      ]),
                    )),
                  ),

                  Expanded(
                      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), physics: const BouncingScrollPhysics(), children: [
                        _ProfileSection(index: 1, title: getTranslated('personal_information', context) ?? '', children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: CustomTextFieldWidget(
                            labelText: getTranslated('first_name', context),
                            inputType: TextInputType.name,
                            focusNode: _fNameFocus,
                            nextFocus: _lNameFocus,
                            hintText: profile.userInfoModel?.fName ?? '',
                            controller: _firstNameController)),
                        const SizedBox(width: 10),
                        Expanded(child: CustomTextFieldWidget(
                            labelText: getTranslated('last_name', context),
                            inputType: TextInputType.name,
                            focusNode: _lNameFocus,
                            nextFocus: _emailFocus,
                            hintText: profile.userInfoModel?.lName,
                            controller: _lastNameController)),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        CustomTextFieldWidget(
                          //isEnabled: profile.userInfoModel?.emailVerifiedAt == null,
                          labelText: getTranslated('email', context),
                          inputType: TextInputType.emailAddress,
                          focusNode: _emailFocus,
                          //readOnly : false,
                          nextFocus: _phoneFocus,
                          hintText: profile.userInfoModel?.email ?? '',
                          controller: _emailController,
                          isToolTipSuffix: (isMailChanged || (config?.customerVerification?.email == 0)) ? false : true,
                          suffixIcon: (isMailChanged || (config?.customerVerification?.email == 0)) ? null : (config?.customerVerification?.email == 1 && profile.userInfoModel?.emailVerifiedAt == null) ? Images.notVerifiedSvg : Images.verifiedSvg,
                          toolTipMessage: (config?.customerVerification?.email == 1 && profile.userInfoModel?.emailVerifiedAt == null) ? getTranslated('email_not_verified', context)! : '',
                          toolTipKey: emailToolTipKey,
                          suffixOnTap: () {
                            if(profile.userInfoModel?.emailVerifiedAt == null) {
                              SignUpModel signUpModel = SignUpModel(
                                email: _emailController.text.trim(),
                              );
                              authController.sendVerificationCode(config!, signUpModel, type: 'email', fromPage: FromPage.profile);
                            }
                          },
                          onChanged: (value) {
                            if(profile.userInfoModel?.email != value) {
                              setState(() => isMailChanged = true);
                            } else if(isMailChanged && profile.userInfoModel?.email == value){
                              setState(() => isMailChanged = false);
                            }
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),


                        CustomTextFieldWidget(
                          isEnabled: profile.userInfoModel?.isPhoneVerified == 0,
                          labelText: getTranslated('phone', context),
                          inputType: TextInputType.phone,
                          focusNode: _phoneFocus,
                          hintText: profile.userInfoModel?.phone ?? "",
                          nextFocus: _addressFocus,
                          controller: _phoneController,
                          toolTipKey: phoneToolTipKey,
                          isToolTipSuffix: (isPhoneChanged  || (config?.customerVerification?.phone == 0)) ? false : true,
                          toolTipMessage: (profile.userInfoModel?.isPhoneVerified == 0 && config?.customerVerification?.phone == 1) ? getTranslated('phone_number_not_verified', context)! : '',
                          suffixIcon:  (isPhoneChanged   || (config?.customerVerification?.phone == 0)) ? null : config?.customerVerification?.phone == 1 && profile.userInfoModel?.isPhoneVerified == 0 ? Images.notVerifiedSvg : Images.verifiedSvg,
                          suffixOnTap: () {
                            if(profile.userInfoModel?.isPhoneVerified == 0) {
                              final configModel = Provider.of<SplashController>(context, listen : false).configModel;
                              SignUpModel signUpModel = SignUpModel(
                                phone : _phoneController.text.trim(),
                              );
                              authController.sendVerificationCode(configModel!, signUpModel, type: 'phone', fromPage: FromPage.profile);
                            }
                          },
                          isAmount: true,
                          onChanged: (value) {
                            if(profile.userInfoModel?.phone != value) {
                              setState(() => isPhoneChanged = true);
                            } else if(isPhoneChanged && profile.userInfoModel?.phone == value){
                              setState(() => isPhoneChanged = false);
                            }
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        ]),
                        const SizedBox(height: 14),
                        _ProfileSection(index: 2, title: getTranslated('change_password', context) ?? '', children: [
                        CustomTextFieldWidget(
                            isPassword: true,
                            labelText: getTranslated('password', context),
                            hintText: getTranslated('enter_7_plus_character', context),
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            nextFocus: _confirmPasswordFocus,
                            inputAction: TextInputAction.next),
                        const SizedBox(height: Dimensions.paddingSizeLarge),


                        CustomTextFieldWidget(
                            labelText: getTranslated('confirm_password', context),
                            hintText: getTranslated('enter_7_plus_character', context),
                            isPassword: true,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            inputAction : TextInputAction.done),
                        ]),
                        const SizedBox(height: 6),
                        Center(child: TextButton(
                          onPressed: () => showModalBottomSheet(backgroundColor: Colors.transparent,
                              context: context, builder: (_) => DeleteAccountBottomSheet(customerId: profile.userID)),
                          style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                          child: Text(getTranslated('delete_account', context) ?? '',
                              style: textBold.copyWith(color: AppPalette.error, fontSize: Dimensions.fontSizeSmall + 1)),
                        )),
                      ],
                      ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.marginSizeLarge, vertical: Dimensions.marginSizeSmall),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                        Theme.of(context).canvasColor.withValues(alpha: 0),
                        Theme.of(context).canvasColor.withValues(alpha: .95),
                      ]),
                    ),
                    child: !profile.isLoading ?
                    CustomButton(onTap: _updateUserAccount, buttonText: getTranslated('update_profile', context)) :
                    Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    )),
                  ),
                ]) : CustomLoaderWidget(height: MediaQuery.sizeOf(context).height);
              }
            );
          }
        ),
      ),
    );
  }
}

/// Frosted card grouping related profile fields under a heading.
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children, this.index = 0});
  final String title;
  final List<Widget> children;
  final int index;

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = [];
    for (final child in children) {
      if (spaced.isNotEmpty) spaced.add(const SizedBox(height: Dimensions.paddingSizeDefault));
      spaced.add(child);
    }
    return FadeSlideIn(
      index: index,
      child: GlassContainer(
        blur: false,
        radius: 26,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(title, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
          ...spaced,
        ]),
      ),
    );
  }
}
