import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/auth_ui.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_button_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String mobileNumber;
  final String otp;
  const ResetPasswordScreen({super.key,required this.mobileNumber,required this.otp});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  final FocusNode _newPasswordNode = FocusNode();
  final FocusNode _confirmPasswordNode = FocusNode();
  GlobalKey<FormState>? _formKeyReset;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    super.initState();
  }


  void resetPassword() async {
      String password = _passwordController!.text.trim();
      String confirmPassword = _confirmPasswordController!.text.trim();

      if (password.isEmpty) {
        showCustomSnackBar(getTranslated('password_must_be_required', context), context);
      } else if (confirmPassword.isEmpty) {
        showCustomSnackBar(getTranslated('confirm_password_must_be_required', context), context);
      }else if (password != confirmPassword) {
        showCustomSnackBar(getTranslated('password_did_not_match', context), context);
      } else {
        Provider.of<AuthController>(context, listen: false).resetPassword(widget.mobileNumber,widget.otp, password, confirmPassword);
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(key: _formKeyReset,
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 14, 20, 24), children: [
              AuthStepHeader(step: 3, total: 3, onBack: () => Navigator.pop(context)),
              const SizedBox(height: 36),

              AuthIllustration(
                icon: Icons.verified_user_rounded,
                title: getTranslated('password_reset', context) ?? '',
                description: Text(getTranslated('choose_strong_password', context) ?? ''),
              ),
              const SizedBox(height: 28),

              AuthFormCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AuthFieldLabel(getTranslated('new_password', context) ?? ''),
                CustomTextFieldWidget(
                  hintText: getTranslated('new_password', context),
                  focusNode: _newPasswordNode,
                  nextFocus: _confirmPasswordNode,
                  isPassword: true,
                  controller: _passwordController,
                  showLabelText: false,
                ),
                _PasswordRules(controller: _passwordController!),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                AuthFieldLabel(getTranslated('confirm_password', context) ?? ''),
                CustomTextFieldWidget(
                  isPassword: true,
                  hintText: getTranslated('confirm_password', context),
                  inputAction: TextInputAction.done,
                  focusNode: _confirmPasswordNode,
                  controller: _confirmPasswordController,
                  showLabelText: false,
                ),
                _PasswordMatch(password: _passwordController!, confirm: _confirmPasswordController!),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Provider.of<AuthController>(context).isLoading
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                    : CustomButton(onTap: resetPassword, buttonText: getTranslated('reset_password', context)),
              ])),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live checklist of password rules.
class _PasswordRules extends StatelessWidget {
  const _PasswordRules({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final String v = value.text;
        final rules = [
          (v.length >= 8, 'rule_min_8_chars'),
          (RegExp(r'[A-Z]').hasMatch(v) && RegExp(r'[0-9]').hasMatch(v), 'rule_upper_and_number'),
          (RegExp(r'[^A-Za-z0-9]').hasMatch(v), 'rule_special_char'),
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final (ok, key) in rules)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        key: ValueKey(ok), size: 18, color: ok ? AppPalette.success : Theme.of(context).hintColor),
                  ),
                  const SizedBox(width: 8),
                  Text(getTranslated(key, context) ?? '',
                      style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall + 1,
                          color: ok ? AppPalette.success : Theme.of(context).hintColor)),
                ]),
              ),
          ]),
        );
      },
    );
  }
}

/// Shows whether the confirmation matches once something is typed.
class _PasswordMatch extends StatelessWidget {
  const _PasswordMatch({required this.password, required this.confirm});
  final TextEditingController password;
  final TextEditingController confirm;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([password, confirm]),
      builder: (context, _) {
        if (confirm.text.isEmpty) return const SizedBox(height: 4);
        final bool match = confirm.text == password.text;
        final Color color = match ? AppPalette.success : AppPalette.error;
        return Padding(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Row(children: [
            Icon(match ? Icons.check_circle_rounded : Icons.error_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Text(getTranslated(match ? 'passwords_match' : 'password_did_not_match', context) ?? '',
                style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: color)),
          ]),
        );
      },
    );
  }
}
