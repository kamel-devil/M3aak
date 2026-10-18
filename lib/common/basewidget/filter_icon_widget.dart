import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

class FilterIconWidget extends StatelessWidget {
  final int filterCount;
  final double? height;
  final double? width;
  final GestureTapCallback? onTap;

  const FilterIconWidget({super.key, this.filterCount = 3, required this.onTap, this.height = 30, this.width = 30});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: getTranslated('filter', context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: 1.2),
            ),
            child: Icon(Icons.tune_rounded, size: 20, color: Theme.of(context).primaryColor),
          ),
          if (filterCount > 0)
            PositionedDirectional(
              top: -6,
              end: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$filterCount',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white)),
              ),
            ),
        ]),
      ),
    );
  }
}
