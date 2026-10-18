import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Trust row: easy returns, safe payment, authentic products — three equal tiles.
class PromiseWidget extends StatelessWidget {
  const PromiseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.autorenew_rounded, 'seven_days_return', AppPalette.secondary),
      (Icons.verified_user_outlined, 'safe_payment', AppPalette.primary),
      (Icons.workspace_premium_outlined, 'authentic_product', AppPalette.warning),
    ];

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GlassContainer(
              blur: false,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: items[i].$3.withValues(alpha: .14),
                  ),
                  child: Icon(items[i].$1, color: items[i].$3, size: 19),
                ),
                const SizedBox(height: 6),
                Text(getTranslated(items[i].$2, context) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall + 1,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}
