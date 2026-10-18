import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';

/// Shared building blocks for the sign-in, sign-up and password screens.

/// Frosted square back button; the arrow follows the text direction.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: PressableScale(
        onTap: onTap,
        child: GlassContainer(
          width: 44,
          height: 44,
          radius: 15,
          blur: false,
          showShadow: false,
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 17, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}

/// Brand logo on a white glass tile.
class AuthLogoTile extends StatelessWidget {
  const AuthLogoTile({super.key, this.size = 104});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * .31),
        border: Border.all(color: const Color(0xFFCFF1EA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: .22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Image.asset(Images.logoWithNameImage, fit: BoxFit.contain),
      ),
    );
  }
}

/// Centered logo, title and subtitle.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Column(children: [
        const AuthLogoTile(),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: textBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              textAlign: TextAlign.center,
              style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
        ],
      ]),
    );
  }
}

/// Frosted card that holds a form.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child, this.index = 1});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: GlassContainer(
        blur: false,
        radius: 28,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// "—— or ——" separator.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color line = AppPalette.primaryDeep.withValues(alpha: .18);
    return Row(children: [
      Expanded(child: Container(height: 1, color: line)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(text,
            style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).hintColor)),
      ),
      Expanded(child: Container(height: 1, color: line)),
    ]);
  }
}

/// Back button plus an "n / total" progress bar for multi-step flows.
class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({super.key, required this.step, required this.total, required this.onBack});
  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AuthBackButton(onTap: onBack),
      const SizedBox(width: 12),
      Expanded(
        child: Semantics(
          label: '$step / $total',
          child: Row(children: [
            for (int i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: i < step ? 1 : 0),
                  duration: Duration(milliseconds: 450 + 150 * i),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppPalette.isDark(context) ? AppPalette.darkTint : const Color(0xFFD7E8E6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppPalette.brandGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
      const SizedBox(width: 10),
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text('$step / $total',
            style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall + 1, color: Theme.of(context).hintColor)),
      ),
    ]);
  }
}

/// Large gradient icon inside a soft halo, with title and description.
class AuthIllustration extends StatelessWidget {
  const AuthIllustration({super.key, required this.icon, required this.title, this.description});
  final IconData icon;
  final String title;
  final Widget? description;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Column(children: [
        Container(
          width: 120,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppPalette.tint(context),
              AppPalette.tint(context).withValues(alpha: .25),
            ]),
          ),
          child: PulseGlow(
            radius: 26,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: AppPalette.brandGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: textBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        if (description != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault, height: 1.6, color: Theme.of(context).hintColor),
            child: description!,
          ),
        ],
      ]),
    );
  }
}

/// Small text label shown above a field.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Text(text,
          style: textBold.copyWith(
              fontSize: Dimensions.fontSizeSmall + 1,
              color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}
