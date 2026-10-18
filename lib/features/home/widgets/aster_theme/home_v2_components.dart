import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/cart/controllers/cart_controller.dart';
import 'package:kk_thotix_m3aak/features/notification/controllers/notification_controller.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/utill/images.dart';
import 'package:provider/provider.dart';

import '../../../../localization/language_constrants.dart';

/// Greeting header: pharmacy mark, greeting + name + tagline, then cart and
/// notification shortcuts.
class HomeV2Header extends StatelessWidget {
  const HomeV2Header({
    super.key,
    required this.greeting,
    required this.name,
    required this.onNotificationTap,
    required this.onCartTap,
  });

  final String greeting;
  final String name;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final Color ink = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color hint = Theme.of(context).hintColor;

    return Row(children: [
      // Brand mark: the pharmacy illustration on a white glass tile.
      Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppPalette.isDark(context) ? AppPalette.darkTint : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFCFF1EA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppPalette.primary.withValues(alpha: .22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(Images.pharmacyIcon, width: 40, height: 40),
      ),
      const SizedBox(width: 12),

      // Greeting
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: hint),
            ),
            Row(children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textBold.copyWith(fontSize: Dimensions.fontSizeOverLarge - 2, color: ink, height: 1.25),
                ),
              ),
              const SizedBox(width: 6),
              const _WavingHand(),
            ]),
            Text(
              getTranslated('always_here_for_your_health', context) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall + 1, color: hint),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),

      // Cart
      Consumer<CartController>(builder: (context, cart, _) {
        return _HeaderButton(
          onTap: onCartTap,
          tinted: true,
          icon: Icons.shopping_cart_outlined,
          badge: cart.cartList.isEmpty
              ? null
              : _CountBadge(count: cart.cartList.length),
        );
      }),
      const SizedBox(width: 10),

      // Notifications
      Consumer<NotificationController>(builder: (context, notification, _) {
        final bool hasAny = notification.notificationModel?.notification?.isNotEmpty ?? false;
        return _HeaderButton(
          onTap: onNotificationTap,
          icon: Icons.notifications_none_rounded,
          badge: hasAny
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppPalette.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.6),
                  ),
                )
              : null,
        );
      }),
    ]);
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.onTap, required this.icon, this.badge, this.tinted = false});

  final VoidCallback onTap;
  final IconData icon;
  final Widget? badge;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final Color ink = Theme.of(context).textTheme.bodyLarge!.color!;
    return PressableScale(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        GlassContainer(
          width: 50,
          height: 50,
          radius: 17,
          sigma: 12,
          color: tinted
              ? AppPalette.tint(context).withValues(alpha: .9)
              : null,
          child: Icon(icon, color: tinted ? Theme.of(context).primaryColor : ink, size: 24),
        ),
        if (badge != null)
          PositionedDirectional(top: -5, start: -5, child: badge!),
      ]),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: .4, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppPalette.brandGradient,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text('$count', style: textBold.copyWith(color: Colors.white, fontSize: 10)),
      ),
    );
  }
}

/// 👋 that waves a couple of times when the header appears.
class _WavingHand extends StatefulWidget {
  const _WavingHand();

  @override
  State<_WavingHand> createState() => _WavingHandState();
}

class _WavingHandState extends State<_WavingHand> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Two decaying swings.
        final double t = _controller.value;
        final double angle = math.sin(t * math.pi * 4) * .35 * (1 - t);
        return Transform.rotate(angle: angle, alignment: Alignment.bottomRight, child: child);
      },
      child: const Text('👋', style: TextStyle(fontSize: 20)),
    );
  }
}

class HomeV2StickySearchBar extends StatelessWidget {
  const HomeV2StickySearchBar({
    super.key,
    required this.onSearchTap,
    required this.onScanTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    final Color hint = Theme.of(context).hintColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: GlassContainer(
        radius: 22,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: PressableScale(
                scale: .98,
                haptic: false,
                onTap: onSearchTap,
                child: SizedBox(
                  height: 50,
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsetsDirectional.only(start: 4),
                      decoration: BoxDecoration(
                        color: AppPalette.tint(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        getTranslated('search_home', context)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textMedium.copyWith(color: hint, fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 6),
            PressableScale(
              onTap: onScanTap,
              child: Container(
                width: 58,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primary.withValues(alpha: .30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 21),
                  const SizedBox(height: 1),
                  Text(getTranslated('scan', context) ?? '',
                      maxLines: 1,
                      style: textMedium.copyWith(color: Colors.white, fontSize: 10)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient hero card that frames the app as a pharmacy.
class HomeV2HealthHero extends StatelessWidget {
  const HomeV2HealthHero({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PressableScale(
        scale: .98,
        onTap: onTap,
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            gradient: AppPalette.brandGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppPalette.primaryDeep.withValues(alpha: .30),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(children: [
              // Decorative glass discs.
              PositionedDirectional(
                end: -30,
                top: -40,
                child: _disc(150, .14),
              ),
              PositionedDirectional(
                end: 60,
                bottom: -50,
                child: _disc(110, .10),
              ),
              PositionedDirectional(
                end: 18,
                top: 0,
                bottom: 0,
                child: Center(child: _FloatingPill()),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 130, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: .35)),
                      ),
                      child: Text(
                        getTranslated('trusted_pharmacy', context) ??
                            'Trusted pharmacy',
                        style: textMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getTranslated('your_health_delivered', context) ??
                          'Your health, delivered',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeExtraLarge,
                          height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getTranslated('order_medicine_now', context) ??
                          'Order your medicine now',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                          color: Colors.white.withValues(alpha: .85),
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _disc(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
          border: Border.all(color: Colors.white.withValues(alpha: alpha + .1)),
        ),
      );
}

/// Glass capsule that bobs gently inside the hero card.
class _FloatingPill extends StatefulWidget {
  @override
  State<_FloatingPill> createState() => _FloatingPillState();
}

class _FloatingPillState extends State<_FloatingPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double v = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -6 + 12 * v),
          child: Transform.rotate(angle: -.5 + .12 * v, child: child),
        );
      },
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .20),
          border: Border.all(color: Colors.white.withValues(alpha: .45)),
        ),
        child: const Icon(Icons.medication_liquid_rounded,
            color: Colors.white, size: 48),
      ),
    );
  }
}

class HomeV2QuickAction {
  const HomeV2QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Row of pharmacy service shortcuts.
class HomeV2QuickActions extends StatelessWidget {
  const HomeV2QuickActions({super.key, required this.actions});

  final List<HomeV2QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: FadeSlideIn(
                index: i,
                offset: const Offset(0, 18),
                child: _QuickActionTile(action: actions[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final HomeV2QuickAction action;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: action.onTap,
      child: GlassContainer(
        blur: false,
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  action.color.withValues(alpha: .22),
                  action.color.withValues(alpha: .10),
                ],
              ),
            ),
            child: Icon(action.icon, color: action.color, size: 23),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ]),
      ),
    );
  }
}

class HomeV2SectionCard extends StatelessWidget {
  const HomeV2SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: GlassContainer(
        blur: false,
        margin: margin,
        padding: padding,
        radius: 26,
        child: child,
      ),
    );
  }
}

class HomeV2SectionGap extends StatelessWidget {
  const HomeV2SectionGap({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Frosted full-width backdrop for floating / pinned home headers so content
/// scrolling underneath is blurred instead of showing through.
class HomeV2FrostedStrip extends StatelessWidget {
  const HomeV2FrostedStrip({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppPalette.isDark(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? [AppPalette.darkBgTop.withValues(alpha: .88), AppPalette.darkBgTop.withValues(alpha: .70)]
                  : [AppPalette.lightBgTop.withValues(alpha: .90), AppPalette.lightBgMid.withValues(alpha: .72)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
