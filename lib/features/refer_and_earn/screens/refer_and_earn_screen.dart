import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/features/splash/controllers/splash_controller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/app_constants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final String referCode = profileController.userInfoModel?.referCode ?? '';
    final Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final List<String> hintList = [
      getTranslated("invite_your_friends", context) ?? "",
      '${getTranslated('they_register', context)} ${AppConstants.appName} ${getTranslated('with_special_offer', context)}',
      '${getTranslated('you_made_your_earning', context)}',
    ];

    void share() {
      final refSignup = Provider.of<SplashController>(context, listen: false).configModel?.refSignup ?? '';
      final appName = AppConstants.appName;
      final shareText =
          'Greetings, $appName is the best e-commerce platform in the country. '
          'If you are new to this website don’t forget to use "$referCode" '
          'as the referral code while signing up into $appName. '
          '$refSignup$referCode';
      SharePlus.instance.share(ShareParams(text: shareText));
    }

    return Scaffold(
      appBar: CustomAppBar(title: '${getTranslated('refer_and_earn', context)}'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FadeSlideIn(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5A524), Color(0xFFF08A3C), Color(0xFFE5634F)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFFE5634F).withValues(alpha: .28), blurRadius: 30, offset: const Offset(0, 14))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(children: [
                  PositionedDirectional(
                    end: -40,
                    bottom: -60,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: .12), width: 22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('${getTranslated('invite_friend_and_businesses', context)}',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, height: 1.35, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('${getTranslated('copy_your_code', context)}',
                          style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.6, color: Colors.white.withValues(alpha: .95))),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 14),

          FadeSlideIn(
            index: 1,
            child: GlassContainer(
              blur: false,
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('${getTranslated('your_personal_code', context)}',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).hintColor)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .4)),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(referCode, textDirection: TextDirection.ltr,
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, letterSpacing: 3, color: textColor))),
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: referCode));
                        if (context.mounted) showCustomSnackBar(getTranslated('copied', context), context, isError: false);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(64, 44),
                        backgroundColor: textColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(getTranslated('copy', context) ?? '',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).cardColor)),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                PressableScale(
                  onTap: share,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppPalette.brandGradient,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.ios_share_rounded, color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Text(getTranslated('share_code', context) ?? '',
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          FadeSlideIn(
            index: 2,
            child: GlassContainer(
              blur: false,
              radius: 24,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(getTranslated('how_it_works', context) ?? '',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor)),
                for (int i = 0; i < hintList.length; i++) ...[
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}', style: textBold.copyWith(color: AppPalette.primaryDeep)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(hintList[i], style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.5, color: textColor)),
                    )),
                  ]),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
