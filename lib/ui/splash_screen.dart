import 'package:lawyer/controller/splash_controller.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // Professional logo container
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.balance,
                              size: 70,
                              color: AppColors.darkModePrimary,
                            ),
                            const SizedBox(height: 12),
                            Image.asset(
                              "assets/appicon/lawyer_splash1.png",
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/appicon/app_logo2.png",
                                  width: 120,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Branding text
                      Text(
                        'Rulebook Lawyer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Professional legal services, case management and client support in one secure place.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      // Loading indicator
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkModePrimary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Preparing your dashboard...',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
