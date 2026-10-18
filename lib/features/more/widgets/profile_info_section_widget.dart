import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_image_widget.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/auth/controllers/auth_controller.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

/// Gradient profile card at the top of the "More" tab.
class ProfileInfoSectionWidget extends StatelessWidget {
  const ProfileInfoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(builder: (context, profile, _) {
      final bool isGuest = !Provider.of<AuthController>(context, listen: false).isLoggedIn();
      final String name = isGuest
          ? (getTranslated('guest', context) ?? 'Guest')
          : '${profile.userInfoModel?.fName ?? ''} ${profile.userInfoModel?.lName ?? ''}'.trim();
      final String? phone = profile.userInfoModel?.phone;
      final String? email = profile.userInfoModel?.email;
      final String subtitle = isGuest
          ? (getTranslated('sign_in_to_unlock', context) ?? '')
          : ((phone?.isNotEmpty ?? false) ? phone! : (email ?? ''));

      void openProfile() {
        if (isGuest) {
          RouterHelper.getLoginRoute(
              action: RouteAction.push, fromPage: '${RouterHelper.dashboardScreen}?page=more');
        } else if (profile.userInfoModel != null) {
          RouterHelper.getProfileScreen1Route(action: RouteAction.push);
        }
      }

      return FadeSlideIn(
        child: PressableScale(
          scale: .98,
          onTap: openProfile,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppPalette.brandGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.primaryDeep.withValues(alpha: .30),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(children: [
                // Decorative rings.
                PositionedDirectional(
                  end: -50,
                  top: -60,
                  child: _ring(170, 26, .10),
                ),
                PositionedDirectional(
                  start: -30,
                  bottom: -70,
                  child: _ring(140, 18, .07),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    // Avatar with glass ring.
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .30),
                        border: Border.all(color: Colors.white.withValues(alpha: .6), width: 1.5),
                      ),
                      child: ClipOval(
                        child: ColoredBox(
                          color: Colors.white,
                          child: isGuest
                              ? Image.asset(Images.guestProfile, fit: BoxFit.cover)
                              : CustomImageWidget(
                                  image: '${profile.userInfoModel?.imageFullUrl?.path}',
                                  fit: BoxFit.cover,
                                  placeholder: Images.guestProfile),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          name.isEmpty ? (getTranslated('guest', context) ?? '') : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraLarge + 2),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Directionality(
                            textDirection: !isGuest && (phone?.isNotEmpty ?? false)
                                ? TextDirection.ltr
                                : Directionality.of(context),
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textRegular.copyWith(
                                  color: Colors.white.withValues(alpha: .88),
                                  fontSize: Dimensions.fontSizeSmall,
                                  height: 1.3),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(isGuest ? Icons.login_rounded : Icons.edit_rounded,
                                size: 14, color: AppPalette.primaryDeep),
                            const SizedBox(width: 6),
                            Text(
                              isGuest
                                  ? (getTranslated('sign_in', context) ?? '')
                                  : (getTranslated('edit_profile_short', context) ?? ''),
                              style: textBold.copyWith(
                                  color: AppPalette.primaryDeep, fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }

  Widget _ring(double size, double width, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: alpha), width: width),
        ),
      );
}
