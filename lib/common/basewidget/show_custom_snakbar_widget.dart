import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/main.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';

OverlayEntry? _activeToast;

/// Shows a frosted toast that slides in under the status bar. Only one toast
/// is visible at a time; a new one replaces the previous.
void showCustomSnackBar(String? message, BuildContext context, {bool isError = true, bool isToaster = false}) {
  if (message == null || message.trim().isEmpty) return;
  _showGlassToast(
    context: context,
    message: message,
    isError: isError,
  );
}

/// Connection status: a persistent "offline" toast with a retry action, or a
/// short "back online" confirmation that replaces it.
void showConnectionToast({required bool connected, VoidCallback? onRetry}) {
  final BuildContext? context = navigatorKey.currentContext;
  if (context == null) return;
  _showGlassToast(
    context: context,
    message: connected
        ? (getTranslated('connection_restored', context) ?? 'Connection restored')
        : (getTranslated('no_connection', context) ?? 'No connection'),
    subtitle: connected
        ? getTranslated('you_are_online_now', context)
        : getTranslated('check_network_auto_retry', context),
    isError: !connected,
    icon: connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
    persistent: !connected,
    actionLabel: connected ? null : getTranslated('RETRY', context),
    onAction: onRetry,
  );
}

void _showGlassToast({
  required BuildContext context,
  required String message,
  required bool isError,
  String? subtitle,
  IconData? icon,
  bool persistent = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final OverlayState? overlay = navigatorKey.currentState?.overlay ??
      (context.mounted ? Overlay.maybeOf(context, rootOverlay: true) : null);
  if (overlay == null) return;

  _activeToast?.remove();
  _activeToast = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _GlassToast(
      message: message,
      subtitle: subtitle,
      icon: icon,
      persistent: persistent,
      actionLabel: actionLabel,
      onAction: onAction,
      isError: isError,
      onDismissed: () {
        if (_activeToast == entry) _activeToast = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _activeToast = entry;
  overlay.insert(entry);

  if (isError) {
    HapticFeedback.mediumImpact();
  } else {
    HapticFeedback.lightImpact();
  }
}

class _GlassToast extends StatefulWidget {
  const _GlassToast({
    required this.message,
    required this.isError,
    required this.onDismissed,
    this.subtitle,
    this.icon,
    this.persistent = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismissed;
  final String? subtitle;
  final IconData? icon;
  final bool persistent;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_GlassToast> createState() => _GlassToastState();
}

class _GlassToastState extends State<_GlassToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 260),
  );
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    if (!widget.persistent) {
      _timer = Timer(const Duration(milliseconds: 2600), _close);
    }
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.isError ? AppPalette.error : AppPalette.success;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double top = MediaQuery.of(context).padding.top + 10;

    final Animation<double> curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: curve,
        builder: (context, child) => Opacity(
          opacity: _controller.value,
          child: Transform.translate(
            offset: Offset(0, -40 * (1 - curve.value)),
            child: Transform.scale(scale: .92 + .08 * curve.value, child: child),
          ),
        ),
        child: Dismissible(
          key: const ValueKey('toast'),
          direction: DismissDirection.up,
          onDismissed: (_) => widget.onDismissed(),
          child: GestureDetector(
            onTap: _close,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: .25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xE6122A30) : Colors.white.withValues(alpha: .88),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: accent.withValues(alpha: .30), width: 1.2),
                      ),
                      child: Row(children: [
                        // Animated status badge.
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(.3, 1, curve: Curves.elasticOut),
                          ),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isError
                                    ? [const Color(0xFFFF7A8A), AppPalette.error]
                                    : [const Color(0xFF3DD598), AppPalette.success],
                              ),
                            ),
                            child: Icon(
                              widget.icon ?? (widget.isError ? Icons.priority_high_rounded : Icons.check_rounded),
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: (widget.subtitle != null ? textBold : textMedium).copyWith(
                                  fontSize: 14,
                                  height: 1.3,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textRegular.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.actionLabel != null && widget.onAction != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: widget.onAction,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(44, 44),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              backgroundColor: accent.withValues(alpha: .12),
                              foregroundColor: accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(widget.actionLabel!,
                                style: textBold.copyWith(fontSize: 13, color: accent)),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
