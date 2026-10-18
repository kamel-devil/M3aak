import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/loyaltyPoint/widget/loyalty_point_converter_dialogue_widget.dart';
import 'package:kk_thotix_m3aak/features/profile/controllers/profile_contrroller.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:provider/provider.dart';

/// Warm gradient card with the points balance and the convert action.
class LoyaltyPointInfoWidget extends StatelessWidget {
  const LoyaltyPointInfoWidget({super.key});

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5A524), Color(0xFFF08A3C), Color(0xFFE5634F)],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(builder: (context, profile, _) {
      final int points = (profile.userInfoModel?.loyaltyPoint ?? 0).toInt();

      return FadeSlideIn(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: const Color(0xFFE5634F).withValues(alpha: .28), blurRadius: 30, offset: const Offset(0, 14)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(children: [
              PositionedDirectional(
                end: -40,
                bottom: -70,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: .12), width: 24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: .45)),
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${getTranslated('your_points', context)}',
                            style: textRegular.copyWith(color: Colors.white.withValues(alpha: .95), fontSize: Dimensions.fontSizeDefault)),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: points.toDouble()),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Text('${v.round()}',
                              style: textBold.copyWith(color: Colors.white, fontSize: 34, height: 1.15)),
                        ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  PressableScale(
                    onTap: profile.userInfoModel == null
                        ? null
                        : () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                child: LoyaltyPointConverterDialogueWidget(myPoint: profile.userInfoModel!.loyaltyPoint ?? 0),
                              ),
                            ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Text('${getTranslated('convert_to_currency', context)}',
                          style: textBold.copyWith(color: const Color(0xFFB4432F), fontSize: Dimensions.fontSizeLarge)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
