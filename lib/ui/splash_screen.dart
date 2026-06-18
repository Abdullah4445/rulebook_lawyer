import 'package:lawyer/controller/splash_controller.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _gavelController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _gavelRotate;
  late Animation<double> _shimmerAnim;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Gavel swing animation
    _gavelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _gavelRotate = Tween<double>(begin: -0.4, end: 0.0).animate(
      CurvedAnimation(parent: _gavelController, curve: Curves.bounceOut),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Chain animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _gavelController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _gavelController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.brandSurfaceDark,
          body: Stack(
            children: [
              // Lush deep ink-to-navy gradient
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandSurfaceDark,
                      AppColors.brandNavy,
                      AppColors.darkSurfaceElevated,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Decorative circles (legal document feel)
              Positioned(
                top: -80,
                right: -60,
                child: AnimatedBuilder(
                  animation: _particleAnim,
                  builder: (context, child) => Opacity(
                    opacity: 0.05 + (_particleAnim.value * 0.05),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brandGold,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -70,
                child: AnimatedBuilder(
                  animation: _particleAnim,
                  builder: (context, child) => Opacity(
                    opacity: 0.04 + (_particleAnim.value * 0.04),
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brandGold,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // ⚖️ Animated Logo Container
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) => Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoFade.value,
                            child: child,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: AppColors.brandGold.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGold.withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated gavel / scales icon
                              AnimatedBuilder(
                                animation: _gavelRotate,
                                builder: (context, child) => Transform.rotate(
                                  angle: _gavelRotate.value,
                                  child: child,
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [Color(0xFFFBBF24), Color(0xFFC9A227)],
                                  ).createShader(bounds),
                                  child: const Icon(
                                    Icons.gavel,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Shimmer on logo
                              AnimatedBuilder(
                                animation: _shimmerAnim,
                                builder: (context, child) => ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: const [
                                      Colors.white,
                                      Color(0xFFFBBF24),
                                      Colors.white,
                                    ],
                                    stops: [
                                      (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                                      _shimmerAnim.value.clamp(0.0, 1.0),
                                      (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
                                    ],
                                  ).createShader(bounds),
                                  child: child!,
                                ),
                                child: Image.asset(
                                  "assets/appicon/lawyer_splash1.png",
                                  width: 110,
                                  height: 110,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.balance,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Animated branding text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Opacity(
                            opacity: _textFade.value,
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Gold divider line
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.brandGold.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(
                                    Icons.balance,
                                    color: AppColors.brandGold,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.brandGold.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'ROOLBOOK',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.brandGold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Lawyer Workspace',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Professional Legal Workspace\nCase management · Client trust',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Loading dots
                      AnimatedBuilder(
                        animation: _particleAnim,
                        builder: (context, child) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final delay = i * 0.33;
                            final anim = ((_particleAnim.value + delay) % 1.0);
                            final size = 6.0 + (anim * 4.0);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: AppColors.brandGold.withOpacity(0.4 + anim * 0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Preparing your workspace…',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
