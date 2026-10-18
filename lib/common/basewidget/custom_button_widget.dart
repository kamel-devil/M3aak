import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String? buttonText;
  final bool isBuy;
  final bool isBorder;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  final double? radius;
  final double? fontSize;
  final String? leftIcon;
  final double? borderWidth;
  final bool isLoading;
  final double buttonHeight;


  const CustomButton({
    super.key, this.onTap, required this.buttonText, this.isBuy= false,
    this.isBorder = false, this.backgroundColor, this.radius, this.textColor,
    this.fontSize, this.leftIcon, this.borderColor, this.loadingColor = Colors.white, this.borderWidth,
    this.isLoading = false, this.buttonHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    final double r = radius ?? 16;

    // Default filled buttons get the brand (or offer) gradient; explicit
    // colours and outlined buttons are honoured as before.
    final Gradient? gradient = (disabled || isBorder || backgroundColor != null)
        ? null
        : (isBuy ? AppPalette.offerGradient : AppPalette.brandGradient);
    final Color? fill = disabled
        ? Theme.of(context).disabledColor
        : gradient != null ? null : backgroundColor;
    final Color shadowColor = isBuy ? AppPalette.accent : AppPalette.primary;

    return PressableScale(
      onTap: (isLoading || disabled) ? null : () => onTap!(),
      scale: .97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: isBorder ? Border.all(color: borderColor ?? Theme.of(context).primaryColor, width: borderWidth ?? 1.2) : null,
          color: fill,
          gradient: gradient,
          borderRadius: BorderRadius.circular(r),
          boxShadow: gradient != null && !isLoading ? [
            BoxShadow(color: shadowColor.withValues(alpha: .30), blurRadius: 18, offset: const Offset(0, 8)),
          ] : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading ? Row(
            key: const ValueKey('loading'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 16, width: 16,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor!),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(getTranslated('loading', context)!, style: textBold.copyWith(color: loadingColor)),
            ],
          ) : Row(key: const ValueKey('label'), mainAxisAlignment: MainAxisAlignment.center, children: [
              if(leftIcon != null)
              Padding(padding: const EdgeInsets.only(right: 5),
                child: SizedBox(width: 30, child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Image.asset(leftIcon!),
                )),
              ),
              Flexible(
                child: Text(buttonText??"", style: textBold.copyWith(fontSize: fontSize?? 16,
                      color: textColor ?? (isBorder ? (borderColor ?? Theme.of(context).primaryColor) : Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
