import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🏆 Case Completion Celebration Animation for Lawyer App
class CaseCompletedAnimation extends StatefulWidget {
  final String caseId;
  final String amount;
  final VoidCallback? onDone;

  const CaseCompletedAnimation({
    super.key,
    required this.caseId,
    required this.amount,
    this.onDone,
  });

  static Future<void> show(BuildContext context,
      {required String caseId,
      required String amount,
      VoidCallback? onDone}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => CaseCompletedAnimation(
        caseId: caseId,
        amount: amount,
        onDone: onDone,
      ),
    );
  }

  @override
  State<CaseCompletedAnimation> createState() => _CaseCompletedAnimationState();
}

class _CaseCompletedAnimationState extends State<CaseCompletedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _textController;
  late AnimationController _checkController;
  late AnimationController _shimmerController;

  late Animation<double> _scale;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _checkDraw;
  late Animation<double> _shimmer;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Generate confetti
    for (int i = 0; i < 20; i++) {
      _particles.add(_ConfettiParticle(i));
    }

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutCubic),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _confettiController.forward();
        _textController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    _checkController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkContainerBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Confetti particles
              ...List.generate(_particles.length, (i) {
                return AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    final p = _particles[i];
                    final progress = _confettiController.value;
                    final x = p.startX + (p.velocityX * progress * 200);
                    final y = p.startY - (progress * p.velocityY * 150) +
                        (progress * progress * 200);
                    final opacity = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;
                    return Positioned(
                      left: 120 + x,
                      top: y,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: progress * p.rotationSpeed * 6.28,
                          child: Container(
                            width: p.size,
                            height: p.size,
                            decoration: BoxDecoration(
                              color: p.color,
                              borderRadius: BorderRadius.circular(p.size / 4),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Animated check circle
                  AnimatedBuilder(
                    animation: _checkController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.success.withOpacity(_checkDraw.value),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: _checkDraw.value),
                            duration: const Duration(milliseconds: 400),
                            builder: (ctx, v, _) => Opacity(
                              opacity: v,
                              child: Transform.scale(
                                scale: 0.5 + (v * 0.5),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: AppColors.success,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Case completed text
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(opacity: _textFade.value, child: child),
                    ),
                    child: Column(
                      children: [
                        // Shimmer title
                        AnimatedBuilder(
                          animation: _shimmer,
                          builder: (context, child) => ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: const [
                                AppColors.success,
                                Color(0xFF4ADE80),
                                AppColors.success,
                              ],
                              stops: [
                                (_shimmer.value - 0.3).clamp(0.0, 1.0),
                                _shimmer.value.clamp(0.0, 1.0),
                                (_shimmer.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ).createShader(bounds),
                            child: child!,
                          ),
                          child: Text(
                            'Case Completed!',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'Congratulations! The case has been\nsuccessfully closed.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.subTitleColor,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Case ID + Amount summary
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.gavel,
                                          size: 16, color: AppColors.brandGold),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Case ID",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.subTitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "#${widget.caseId.substring(0, 8).toUpperCase()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet,
                                          size: 16, color: AppColors.success),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Amount Earned",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.subTitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    widget.amount,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Legal seal icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified, size: 16,
                                color: AppColors.brandGold.withOpacity(0.7)),
                            const SizedBox(width: 6),
                            Text(
                              "Closing automatically...",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.subTitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  late double startX;
  late double startY;
  late double velocityX;
  late double velocityY;
  late double size;
  late double rotationSpeed;
  late Color color;

  static final List<Color> _colors = [
    AppColors.brandGold,
    const Color(0xFF4ADE80),
    const Color(0xFF60A5FA),
    const Color(0xFFF472B6),
    const Color(0xFFFBBF24),
    Colors.white,
  ];

  _ConfettiParticle(int seed) {
    final random = seed * 137.5;
    startX = (random % 200) - 100;
    startY = -(random % 50);
    velocityX = ((random % 100) - 50) / 50;
    velocityY = 0.3 + (random % 100) / 100;
    size = 6.0 + (random % 8);
    rotationSpeed = 0.5 + (random % 100) / 100;
    color = _colors[seed % _colors.length];
  }
}

