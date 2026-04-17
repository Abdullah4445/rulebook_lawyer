import 'package:flutter/material.dart';

/// 🎨 Professional Animation System for Lawyer App
/// Smooth, elegant animations for a premium legal platform
class AppAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 700);

  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;

  /// Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double? delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? normal,
      curve: curve ?? easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale In Animation
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration ?? normal,
      curve: curve ?? elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide In From Bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: duration ?? normal,
      curve: curve ?? smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide In From Right
  static Widget slideInFromRight({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: offset, end: 0.0),
      duration: duration ?? normal,
      curve: curve ?? smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: 1 - (value / offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide In From Left
  static Widget slideInFromLeft({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -offset, end: 0.0),
      duration: duration ?? normal,
      curve: curve ?? smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: 1 - (value.abs() / offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animated List Item
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration? delay,
  }) {
    final itemDelay = (delay ?? const Duration(milliseconds: 50)) * index;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: normal + itemDelay,
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Shimmer Loading Effect
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.linear,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor ?? Colors.grey.shade300,
                highlightColor ?? Colors.grey.shade100,
                baseColor ?? Colors.grey.shade300,
              ],
              stops: [
                value - 0.3,
                value,
                value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Pulse Animation (for notifications)
  static Widget pulse({
    required Widget child,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: duration ?? const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {},
      child: child,
    );
  }

  /// Bounce Animation
  static Widget bounce({
    required Widget child,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? slow,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Page Transition Builder
  static Widget pageTransition({
    required Widget child,
    required Animation<double> animation,
    PageTransitionType type = PageTransitionType.fade,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: smooth,
          )),
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      case PageTransitionType.rotation:
        return RotationTransition(
          turns: animation,
          child: child,
        );
    }
  }

  /// Card Elevation Animation
  static Widget elevationAnimation({
    required Widget child,
    required bool isElevated,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isElevated ? 8.0 : 0.0),
      duration: fast,
      curve: smooth,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 * (value / 8)),
                blurRadius: value,
                offset: Offset(0, value / 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
}

/// Animated Button Widget
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration? duration;
  final double scaleValue;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration,
    this.scaleValue = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleValue : 1.0,
        duration: widget.duration ?? AppAnimations.fast,
        curve: AppAnimations.smooth,
        child: widget.child,
      ),
    );
  }
}

/// Animated Card Widget
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.smooth,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}

