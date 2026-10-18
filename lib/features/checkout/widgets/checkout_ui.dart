import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';

/// Frosted section card used by every block of the checkout screen.
class CheckoutCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CheckoutCard({
    super.key,
    this.icon,
    this.iconColor,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppPalette.primary;
    return GlassContainer(
      blur: false,
      radius: 24,
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (title != null) ...[
          Row(children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(title!, style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ))),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 12),
        ],
        child,
      ]),
    );
  }
}

/// Small tinted "change" pill shown in a card header.
class CheckoutChangeButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? label;
  const CheckoutChangeButton({super.key, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .12),
        foregroundColor: AppPalette.primaryDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label ?? getTranslated('checkout_change', context) ?? '',
          style: textBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1, color: AppPalette.primaryDeep)),
    );
  }
}

/// Cart → payment → confirmation progress, with the payment step active.
class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final Color line = AppPalette.glassBorder(context);

    Widget dot({required Widget child, required BoxDecoration decoration}) =>
        Container(width: 28, height: 28, alignment: Alignment.center, decoration: decoration, child: child);

    Widget step(Widget circle, String label, {bool active = false, bool done = false}) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        Text(label, style: (active ? textBold : textMedium).copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: active
              ? Theme.of(context).textTheme.bodyLarge?.color
              : done ? AppPalette.primaryDeep : Theme.of(context).hintColor,
        )),
      ],
    );

    Widget bar(bool filled) => Expanded(child: Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
      decoration: BoxDecoration(
        color: filled ? AppPalette.primary : line,
        borderRadius: BorderRadius.circular(2),
      ),
    ));

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 14),
      child: Row(children: [
        step(
          dot(
            decoration: const BoxDecoration(color: AppPalette.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
          getTranslated('cart', context) ?? '',
          done: true,
        ),
        bar(true),
        step(
          dot(
            decoration: BoxDecoration(
              gradient: AppPalette.brandGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .25), spreadRadius: 5)],
            ),
            child: Text('2', style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
          ),
          getTranslated('checkout_step_payment', context) ?? '',
          active: true,
        ),
        bar(false),
        step(
          dot(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: line, width: 1.5),
            ),
            child: Text('3', style: textBold.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
          ),
          getTranslated('checkout_step_confirm', context) ?? '',
        ),
      ]),
    );
  }
}

/// One label/value line of the order summary.
class CheckoutSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const CheckoutSummaryRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Text(label, style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor,
        ))),
        const SizedBox(width: 12),
        Text(value, style: textBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        )),
      ]),
    );
  }
}
