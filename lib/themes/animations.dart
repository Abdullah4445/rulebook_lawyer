import 'package:flutter/material.dart';
import 'package:lawyer/themes/app_colors.dart';

/// Premium animation toolkit for the Lawyer app.
class AppAnimations {
  // ─── Durations ────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 550);
  static const Duration verySlow = Duration(milliseconds: 800);

  // ─── Curves ───────────────────────────────────────
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve elasticOut = Curves.elasticOut;

  /// Drop-in fade in.
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (_, v, c) => Opacity(opacity: v, child: c),
      child: child,
    );
  }

  /// Drop-in scale + fade.
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = overshoot,
    double from = 0.85,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (_, v, c) => Opacity(
        opacity: ((v - from) / (1 - from)).clamp(0.0, 1.0),
        child: Transform.scale(scale: v, child: c),
      ),
      child: child,
    );
  }

  /// Slide + fade entrance from a direction.
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normal,
    Curve curve = smooth,
    double offset = 40.0,
  }) =>
      EntranceFadeSlide(
          duration: duration,
          curve: curve,
          offset: Offset(0, offset),
          child: child);

  static Widget slideInFromRight({
    required Widget child,
    Duration duration = normal,
    Curve curve = smooth,
    double offset = 40.0,
  }) =>
      EntranceFadeSlide(
          duration: duration,
          curve: curve,
          offset: Offset(offset, 0),
          child: child);

  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = normal,
    Curve curve = smooth,
    double offset = 40.0,
  }) =>
      EntranceFadeSlide(
          duration: duration,
          curve: curve,
          offset: Offset(-offset, 0),
          child: child);

  /// Staggered list-item animation (call inside ListView.builder).
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 60),
  }) {
    return EntranceFadeSlide(
      duration: normal + delay * index,
      curve: smooth,
      offset: const Offset(0, 18),
      child: child,
    );
  }

  /// Page transition helper (for use with GetX or Navigator).
  static Widget pageTransition({
    required Widget child,
    required Animation<double> animation,
    PageTransitionType type = PageTransitionType.fade,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: smooth)),
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(scale: animation, child: child);
      case PageTransitionType.rotation:
        return RotationTransition(turns: animation, child: child);
    }
  }
}

enum PageTransitionType { fade, slide, scale, rotation }

// ─────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────

/// Combined fade + slide entrance animation.
/// Use anywhere a widget needs to "land" on screen.
class EntranceFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;

  const EntranceFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.offset = const Offset(0, 24),
  });

  @override
  State<EntranceFadeSlide> createState() => _EntranceFadeSlideState();
}

class _EntranceFadeSlideState extends State<EntranceFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t =
      CurvedAnimation(parent: _ctrl, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (_, child) {
        final dx = widget.offset.dx * (1 - _t.value);
        final dy = widget.offset.dy * (1 - _t.value);
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(offset: Offset(dx, dy), child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Scale-down on press for premium tactile feedback.
/// Wrap any tappable: `PressScale(onTap: ..., child: ...)`.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final HitTestBehavior behavior;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Backwards-compat alias used by older code paths.
class AnimatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleValue;
  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleValue = 0.95,
  });

  @override
  Widget build(BuildContext context) =>
      PressScale(scale: scaleValue, onTap: onTap, child: child);
}

/// Card with hover-lift effect (web/desktop) and press scale (mobile).
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const AnimatedCard({super.key, required this.child, this.onTap});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? 0.98 : (_hover ? 1.02 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Looping shimmer effect for skeleton/loading states.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (dark ? AppColors.darkSurfaceElevated : AppColors.gray200);
    final hl = widget.highlightColor ??
        (dark ? AppColors.gray700 : AppColors.gray100);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + _ctrl.value * 2, 0),
              end: Alignment(1 + _ctrl.value * 2, 0),
              colors: [base, hl, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Subtle gold glow halo behind a child — perfect for hero icons & buttons.
class GoldGlow extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  final double spread;
  final double opacity;

  const GoldGlow({
    super.key,
    required this.child,
    this.blurRadius = 22,
    this.spread = 0,
    this.opacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGold.withOpacity(opacity),
            blurRadius: blurRadius,
            spreadRadius: spread,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Slow continuous breathing animation — useful on hero brand elements.
class BreathingScale extends StatefulWidget {
  final Widget child;
  final double from;
  final double to;
  final Duration duration;

  const BreathingScale({
    super.key,
    required this.child,
    this.from = 0.97,
    this.to = 1.03,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<BreathingScale> createState() => _BreathingScaleState();
}

class _BreathingScaleState extends State<BreathingScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final scale = widget.from + (widget.to - widget.from) * t;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
