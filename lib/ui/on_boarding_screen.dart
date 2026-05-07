import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/controller/on_boarding_controller.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/ui/auth_screen/login_screen.dart';
import 'package:lawyer/utils/Preferences.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: controller.isLoading.value
              ? Constant.loader(context)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Soft gold radial vignette behind the content
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.45),
                          radius: 1.1,
                          colors: [
                            AppColors.brandGold.withOpacity(isDark ? 0.10 : 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          // Skip button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity:
                                      controller.selectedPageIndex.value == 2
                                          ? 0
                                          : 1,
                                  child: PressScale(
                                    onTap: () =>
                                        controller.pageController.jumpToPage(2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandGold
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'skip'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brandGold,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Page content
                          Expanded(
                            child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.selectedPageIndex,
                              itemCount: controller.onBoardingList.length,
                              itemBuilder: (context, index) {
                                final item =
                                    controller.onBoardingList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    children: [
                                      const Spacer(flex: 1),

                                      // Image
                                      Expanded(
                                        flex: 6,
                                        child: EntranceFadeSlide(
                                          key: ValueKey('img_$index'),
                                          duration: const Duration(
                                              milliseconds: 600),
                                          offset: const Offset(0, 24),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  item.image.toString(),
                                              fit: BoxFit.contain,
                                              placeholder: (_, __) =>
                                                  ShimmerBox(
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Image.network(
                                                      Constant.userPlaceHolder),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 28),

                                      // Title
                                      EntranceFadeSlide(
                                        key: ValueKey('title_$index'),
                                        duration: const Duration(
                                            milliseconds: 500),
                                        delay: const Duration(
                                            milliseconds: 150),
                                        child: Text(
                                          Constant().localizationTitle(
                                              item.title!, 'Welcome'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      EntranceFadeSlide(
                                        key: ValueKey('desc_$index'),
                                        duration: const Duration(
                                            milliseconds: 500),
                                        delay: const Duration(
                                            milliseconds: 250),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                          child: Text(
                                            Constant.localizationDescription(
                                                item.description),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.6,
                                              color: theme
                                                  .colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const Spacer(flex: 1),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.onBoardingList.length,
                                (index) {
                                  final selected =
                                      controller.selectedPageIndex.value ==
                                          index;
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: selected ? 28 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: selected
                                          ? AppColors.goldGradient
                                          : null,
                                      color: selected
                                          ? null
                                          : (isDark
                                              ? AppColors.gray700
                                              : AppColors.gray300),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // CTA button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: ButtonThem.buildButton(
                              context,
                              title: controller.selectedPageIndex.value == 2
                                  ? 'Get started'.tr
                                  : 'Next'.tr,
                              btnRadius: 16,
                              onPress: () {
                                if (controller.selectedPageIndex.value == 2) {
                                  Preferences.setBoolean(
                                      Preferences.isFinishOnBoardingKey, true);
                                  Get.offAll(const LoginScreen());
                                } else {
                                  controller.pageController.jumpToPage(
                                      controller.selectedPageIndex.value + 1);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
