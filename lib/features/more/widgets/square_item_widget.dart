import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/helper/price_converter.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Quick-access tile: tinted icon, title and an optional value or badge.
class SquareButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final int count;
  final bool hasCount;
  final bool isWallet;
  final double? balance;
  final bool isLoyalty;
  final String? subTitle;
  final Function? onTap;
  final Color color;

  const SquareButtonWidget({super.key, required this.image,
    required this.title, this.navigateTo, required this.count,
    required this.hasCount, this.isWallet = false, this.balance, this.subTitle,
    this.isLoyalty = false, this.onTap, this.color = AppPalette.primary});

  @override
  Widget build(BuildContext context) {
    final String? value = isWallet
        ? (isLoyalty
            ? (balance ?? 0).toStringAsFixed(0)
            : PriceConverter.convertPrice(context, balance ?? 0))
        : null;

    return PressableScale(
      onTap: onTap != null ? () => onTap!() : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GlassContainer(
          blur: false,
          width: 104,
          radius: 22,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: .22), color.withValues(alpha: .08)],
                  ),
                ),
                child: Image.asset(image, color: color),
              ),
              if (hasCount && count > 0)
                PositionedDirectional(
                  top: -6,
                  end: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppPalette.offerGradient,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: textBold.copyWith(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ]),
            const SizedBox(height: 8),
            Text(title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            if (value != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    maxLines: 1,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: color)),
              ),
          ]),
        ),
      ),
    );
  }
}
