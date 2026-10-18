import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/auth_ui.dart';
import 'package:kk_thotix_m3aak/features/auth/widgets/sign_up_widget.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget{
  final bool fromLogout;
  final String? fromPage;
  final VoidCallback? onLoginSuccess;
  const AuthScreen({super.key, this.fromLogout = false, this.fromPage, this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
  }
  bool scrolled = false;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {

        if(didPop) return;

        Navigator.pop(context);
      },
      child: Scaffold(
        body: Consumer<AuthController>(
          builder: (context, authProvider,_) {
            return SafeArea(child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: FadeSlideIn(
                  offset: const Offset(0, -12),
                  child: Row(children: [
                    AuthBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(getTranslated('sign_up', context)!, style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge + 4,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),
                        Text(getTranslated('register_subtitle', context) ?? '', style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall + 1,
                          color: Theme.of(context).hintColor,
                        )),
                      ]),
                    ),
                    const AuthLogoTile(size: 56),
                  ]),
                ),
              ),

              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                //child: authProvider.selectedIndex == 0 ? const SignInWidget() : const SignUpWidget(),
                child: SignUpWidget(fromLogout: widget.fromLogout, fromPage: widget.fromPage, onLoginSuccess: widget.onLoginSuccess),
              )),
            ]));
          }
        ),
      ),
    );
  }
}

