import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';

/// Soft pharmacy backdrop: a mint-to-sky gradient with glowing orbs and a
/// faint field of medical crosses. Painted behind every route so scaffolds
/// can stay transparent and cards read as frosted glass.
class PharmacyBackground extends StatelessWidget {
  const PharmacyBackground({super.key, this.child, this.animate = false});

  final Widget? child;

  /// Slowly drifts the orbs. Use on hero screens only (splash, auth).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppPalette.isDark(context);
    final Widget background = animate
        ? _AnimatedOrbs(dark: dark)
        : RepaintBoundary(
            child: CustomPaint(
              painter: _PharmacyBackdropPainter(dark: dark, t: 0),
              child: const SizedBox.expand(),
            ),
          );

    return Stack(fit: StackFit.expand, children: [
      background,
      if (child != null) child!,
    ]);
  }
}

class _AnimatedOrbs extends StatefulWidget {
  const _AnimatedOrbs({required this.dark});
  final bool dark;

  @override
  State<_AnimatedOrbs> createState() => _AnimatedOrbsState();
}

class _AnimatedOrbsState extends State<_AnimatedOrbs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _PharmacyBackdropPainter(
              dark: widget.dark, t: _controller.value * 2 * math.pi),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PharmacyBackdropPainter extends CustomPainter {
  _PharmacyBackdropPainter({required this.dark, required this.t});

  final bool dark;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  AppPalette.darkBgTop,
                  AppPalette.darkBgMid,
                  AppPalette.darkBgBottom
                ]
              : const [
                  AppPalette.lightBgTop,
                  AppPalette.lightBgMid,
                  AppPalette.lightBgBottom
                ],
        ).createShader(rect),
    );

    final double w = size.width;
    final double h = size.height;
    _orb(canvas, Offset(w * (.05 + .05 * math.sin(t)), h * (.08 + .03 * math.cos(t))),
        w * .75, AppPalette.primaryLight.withValues(alpha: dark ? .22 : .45));
    _orb(canvas, Offset(w * (.95 - .06 * math.cos(t)), h * (.38 + .04 * math.sin(t))),
        w * .70, AppPalette.secondary.withValues(alpha: dark ? .18 : .22));
    _orb(canvas, Offset(w * (.25 + .05 * math.cos(t)), h * (.92 - .03 * math.sin(t))),
        w * .80, AppPalette.primary.withValues(alpha: dark ? .20 : .22));

    // Faint scattered medical crosses.
    final Paint crossPaint = Paint()
      ..color = (dark ? Colors.white : AppPalette.primaryDeep)
          .withValues(alpha: dark ? .035 : .045);
    const List<Offset> spots = [
      Offset(.82, .07), Offset(.14, .30), Offset(.70, .58),
      Offset(.30, .74), Offset(.90, .86), Offset(.48, .16),
    ];
    for (int i = 0; i < spots.length; i++) {
      final double s = 14.0 + (i % 3) * 8;
      _cross(canvas, Offset(spots[i].dx * w, spots[i].dy * h), s, crossPaint);
    }
  }

  void _orb(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _cross(Canvas canvas, Offset c, double s, Paint paint) {
    final double arm = s / 3;
    final Radius r = Radius.circular(arm / 2.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: arm, height: s), r),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: s, height: arm), r),
        paint);
  }

  @override
  bool shouldRepaint(_PharmacyBackdropPainter old) =>
      old.dark != dark || old.t != t;
}

/// Frosted glass surface. Set [blur] to false inside long scrolling lists:
/// the translucent fill still reads as glass and stays cheap to render.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 24,
    this.blur = true,
    this.sigma = 18,
    this.color,
    this.gradient,
    this.showShadow = true,
    this.borderColor,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool blur;
  final double sigma;
  final Color? color;
  final Gradient? gradient;
  final bool showShadow;
  final Color? borderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    Widget surface = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: gradient == null ? (color ?? AppPalette.glass(context)) : null,
        gradient: gradient,
        border: Border.all(
            color: borderColor ?? AppPalette.glassBorder(context), width: 1.2),
      ),
      child: child,
    );

    if (blur) {
      surface = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: surface,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: AppPalette.softShadow(context))
          : null,
      child: surface,
    );
  }
}

/// Wraps any page transition so each route paints its own pharmacy
/// backdrop; transparent scaffolds then never show the page beneath.
class GlassPageTransitionsBuilder extends PageTransitionsBuilder {
  const GlassPageTransitionsBuilder(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Duration get transitionDuration => inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => inner.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      inner.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions(route, context, animation,
        secondaryAnimation, PharmacyBackground(child: child));
  }
}

/// Fades and slides its child in once when first built. Pass an [index] to
/// stagger siblings.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 24),
    this.duration = const Duration(milliseconds: 520),
    this.stagger = const Duration(milliseconds: 70),
  });

  final Widget child;
  final int index;
  final Offset offset;
  final Duration duration;
  final Duration stagger;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    final int delayMs =
        (widget.stagger.inMilliseconds * widget.index.clamp(0, 8)).toInt();
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: widget.offset * (1 - _curve.value),
          child: child,
        ),
      ),
    );
  }
}

/// Springy press feedback: scales down while held, with a light haptic.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = .96,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 160),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// A gently pulsing glow, used for live badges and the splash logo.
class PulseGlow extends StatefulWidget {
  const PulseGlow({
    super.key,
    required this.child,
    this.color = AppPalette.primary,
    this.radius = 28,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
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
      child: widget.child,
      builder: (context, child) {
        final double v = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: .18 + .22 * v),
                blurRadius: 18 + 22 * v,
                spreadRadius: 2 * v,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
