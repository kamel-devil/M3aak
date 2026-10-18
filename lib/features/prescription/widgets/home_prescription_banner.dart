import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/helper/route_healper.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Home shortcut that lets a customer send a prescription at any time.
class HomePrescriptionBanner extends StatelessWidget {
  const HomePrescriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: PressableScale(
        onTap: () => RouterHelper.getUploadPrescriptionRoute(action: RouteAction.push),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .30), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .20), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.medical_information_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(getTranslated('upload_prescription', context) ?? '',
                    style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: 4),
                Text(getTranslated('home_prescription_hint', context) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(color: Colors.white.withValues(alpha: .9), fontSize: 12, height: 1.5)),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded, color: AppPalette.primary, size: 20),
            ),
          ]),
        ),
      ),
    );
  }
}
