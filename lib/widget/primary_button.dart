import 'package:lawyer/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// Theme-aware primary CTA used throughout the lawyer app.
///
/// Reads colours from `Theme.of(context).colorScheme` (no raw hex) so the
/// button flips automatically with the active theme. Two brand variants:
///   * default (navy primary, used for confirm actions)
///   * `useSecondary: true` (gold, used for premium / earnings actions)
enum PrimaryButtonVariant { filled, tonal, outline }

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final PrimaryButtonVariant variant;
  final bool useSecondary;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = true,
    this.variant = PrimaryButtonVariant.filled,
    this.useSecondary = false,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool v) {
    if (!_enabled) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final brandColor = widget.useSecondary ? cs.secondary : cs.primary;
    final onBrand =
        widget.useSecondary ? cs.onSecondary : cs.onPrimary;

    final radius = BorderRadius.circular(AppTheme.radiusMd);
    final disabled = !_enabled;

    BoxDecoration decoration;
    Color foreground;
    switch (widget.variant) {
      case PrimaryButtonVariant.tonal:
        decoration = BoxDecoration(
          color: disabled
              ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
              : brandColor.withValues(alpha: 0.12),
          borderRadius: radius,
        );
        foreground = disabled ? cs.onSurfaceVariant : brandColor;
        break;
      case PrimaryButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
          border: Border.all(
            color: disabled ? cs.outline : brandColor,
            width: 1.4,
          ),
        );
        foreground = disabled ? cs.onSurfaceVariant : brandColor;
        break;
      case PrimaryButtonVariant.filled:
        decoration = BoxDecoration(
          gradient: disabled
              ? null
              : (widget.useSecondary
                  ? AppTheme.secondaryGradient
                  : AppTheme.primaryGradient),
          color: disabled ? cs.surfaceContainerHighest : null,
          borderRadius: radius,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        );
        foreground = disabled ? cs.onSurfaceVariant : onBrand;
        break;
    }

    Widget child = AnimatedSwitcher(
      duration: AppTheme.motionFast,
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
      child: widget.loading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            )
          : Row(
              key: const ValueKey('content'),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: (tt.labelLarge ?? const TextStyle()).copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.trailingIcon, size: 18, color: foreground),
                ],
              ],
            ),
    );

    final button = AnimatedScale(
      duration: AppTheme.motionFast,
      curve: Curves.easeOut,
      scale: _pressed ? 0.97 : 1.0,
      child: AnimatedContainer(
        duration: AppTheme.motionMed,
        curve: Curves.easeOut,
        height: 52,
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: decoration,
        child: child,
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: button,
      ),
    );
  }
}
