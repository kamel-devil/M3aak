import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlyingToCartAnimation extends StatefulWidget {
  const FlyingToCartAnimation({
    super.key,
    required this.image,
    required this.start,
    required this.end,
    this.duration = const Duration(milliseconds: 700),
    this.onCompleted,
  });

  final ImageProvider image;
  final Offset start;
  final Offset end;
  final Duration duration;
  final VoidCallback? onCompleted;

  static Future<void> play({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required ImageProvider image,
    Duration duration = const Duration(milliseconds: 700),
    VoidCallback? onCompleted,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final sourceContext = sourceKey.currentContext;
    final targetContext = targetKey.currentContext;

    if (sourceContext == null || targetContext == null) {
      onCompleted?.call();
      return;
    }

    final sourceBox = sourceContext.findRenderObject() as RenderBox;
    final targetBox = targetContext.findRenderObject() as RenderBox;

    final start = sourceBox.localToGlobal(sourceBox.size.center(Offset.zero));
    final end = targetBox.localToGlobal(targetBox.size.center(Offset.zero));

    final completer = Completer<void>();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => FlyingToCartAnimation(
        image: image,
        start: start,
        end: end,
        duration: duration,
        onCompleted: () {
          entry.remove();
          onCompleted?.call();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
    );

    overlay.insert(entry);
    return completer.future;
  }

  @override
  State<FlyingToCartAnimation> createState() => _FlyingToCartAnimationState();
}

class _FlyingToCartAnimationState extends State<FlyingToCartAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.lightImpact();
          widget.onCompleted?.call();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _positionFor(double t) {
    final control = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      math.min(widget.start.dy, widget.end.dy) - 120,
    );

    final x = math.pow(1 - t, 2) * widget.start.dx +
        2 * (1 - t) * t * control.dx +
        math.pow(t, 2) * widget.end.dx;
    final y = math.pow(1 - t, 2) * widget.start.dy +
        2 * (1 - t) * t * control.dy +
        math.pow(t, 2) * widget.end.dy;

    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = Curves.easeInOutCubic.transform(_controller.value);
            final pos = _positionFor(t);
            final scale = Tween<double>(begin: 1, end: .8).transform(t);
            final showParticles = _controller.value > .72;

            return Stack(
              children: [
                Positioned(
                  left: pos.dx - 22,
                  top: pos.dy - 22,
                  child: Transform.scale(
                    scale: scale,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: widget.image,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (showParticles)
                  Positioned(
                    left: widget.end.dx - 18,
                    top: widget.end.dy - 18,
                    child: CustomPaint(
                      size: const Size(36, 36),
                      painter: _BurstPainter(progress: (_controller.value - .72) / .28),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimatedCartBadge extends StatefulWidget {
  const AnimatedCartBadge({
    super.key,
    required this.count,
    this.backgroundColor = const Color(0xFF5B4CF0),
    this.textColor = Colors.white,
  });

  final int count;
  final Color backgroundColor;
  final Color textColor;

  @override
  State<AnimatedCartBadge> createState() => _AnimatedCartBadgeState();
}

class _AnimatedCartBadgeState extends State<AnimatedCartBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: .9, end: 1.18), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(covariant AnimatedCartBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '${widget.count}',
            key: ValueKey(widget.count),
            style: TextStyle(
              color: widget.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteButtonAnimation extends StatefulWidget {
  const FavoriteButtonAnimation({
    super.key,
    required this.isFavorite,
    required this.onChanged,
    this.size = 22,
  });

  final bool isFavorite;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  State<FavoriteButtonAnimation> createState() => _FavoriteButtonAnimationState();
}

class _FavoriteButtonAnimationState extends State<FavoriteButtonAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didUpdateWidget(covariant FavoriteButtonAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorite && widget.isFavorite) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final next = !widget.isFavorite;
        widget.onChanged(next);
        if (next) {
          HapticFeedback.selectionClick();
          _controller.forward(from: 0);
        }
      },
      child: SizedBox(
        width: widget.size * 1.9,
        height: widget.size * 1.9,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isFavorite && _controller.value < .85)
                  ...List.generate(4, (index) {
                    final angle = (math.pi / 2) * index - math.pi / 4;
                    final distance = 14 * Curves.easeOut.transform(_controller.value);
                    return Transform.translate(
                      offset: Offset(math.cos(angle) * distance, math.sin(angle) * distance),
                      child: Opacity(
                        opacity: (1 - _controller.value).clamp(0, 1),
                        child: const Icon(Icons.favorite, size: 8, color: Color(0xFFFF6B8A)),
                      ),
                    );
                  }),
                Transform.scale(
                  scale: widget.isFavorite ? _scale.value : 1,
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                    color: widget.isFavorite ? const Color(0xFFFF4F7D) : Theme.of(context).hintColor,
                    size: widget.size,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProductCardRevealAnimation extends StatelessWidget {
  const ProductCardRevealAnimation({
    super.key,
    required this.index,
    required this.child,
    this.stagger = const Duration(milliseconds: 80),
  });

  final int index;
  final Widget child;
  final Duration stagger;

  @override
  Widget build(BuildContext context) {
    final delayMs = stagger.inMilliseconds * index;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 420 + delayMs),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class HeroProductTransition extends StatelessWidget {
  const HeroProductTransition({
    super.key,
    required this.imageTag,
    required this.titleTag,
    required this.priceTag,
    required this.image,
    required this.title,
    required this.price,
  });

  final String imageTag;
  final String titleTag;
  final String priceTag;
  final Widget image;
  final Widget title;
  final Widget price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(tag: imageTag, child: image),
        const SizedBox(height: 8),
        Hero(
          tag: titleTag,
          flightShuttleBuilder: (_, animation, __, ___, to) {
            return FadeTransition(opacity: animation, child: to.widget);
          },
          child: title,
        ),
        const SizedBox(height: 4),
        Hero(
          tag: priceTag,
          flightShuttleBuilder: (_, animation, __, ___, to) {
            return SlideTransition(
              position: Tween(begin: const Offset(0, .2), end: Offset.zero).animate(animation),
              child: to.widget,
            );
          },
          child: price,
        ),
      ],
    );
  }
}

class PremiumBottomNavItem {
  const PremiumBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget? badge;
}

class PremiumBottomNavigation extends StatelessWidget {
  const PremiumBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<PremiumBottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E8F1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final active = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFECE9FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            key: ValueKey(active),
                            color: active ? const Color(0xFF5B4CF0) : const Color(0xFF6D7385),
                            size: 22,
                          ),
                        ),
                        if (item.badge != null)
                          Positioned(
                            right: -10,
                            top: -8,
                            child: item.badge!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? const Color(0xFF5B4CF0) : const Color(0xFF6D7385),
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SuccessToastAnimation extends StatefulWidget {
  const SuccessToastAnimation({
    super.key,
    required this.message,
    this.icon = Icons.check_circle_rounded,
    this.duration = const Duration(milliseconds: 1500),
    this.onDismissed,
  });

  final String message;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onDismissed;

  static Future<void> show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);

    final completer = Completer<void>();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SuccessToastAnimation(
            message: message,
            icon: icon,
            duration: duration,
            onDismissed: () {
              entry.remove();
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
    return completer.future;
  }

  @override
  State<SuccessToastAnimation> createState() => _SuccessToastAnimationState();
}

class _SuccessToastAnimationState extends State<SuccessToastAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    Future<void>.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2432),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: const Color(0xFF5DE38A), size: 20),
              const SizedBox(width: 8),
              Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5B4CF0).withValues(alpha: (1 - p) * .8);

    for (int i = 0; i < 10; i++) {
      final angle = (math.pi * 2 / 10) * i;
      final radius = 4 + (12 * p);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(point, math.max(0.6, 2.4 - (1.8 * p)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

