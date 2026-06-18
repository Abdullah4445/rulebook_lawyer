import 'dart:developer';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/login_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/ui/auth_screen/information_screen.dart';
import 'package:lawyer/ui/dashboard_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:lawyer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/utils/notification_service.dart';
import 'package:lawyer/widget/social_auth_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LoginController>(
        init: LoginController(),
        builder: (controller) {
          final isDark = themeChange.getThem();
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LawyerAuthHero(isDark: isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 100),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "Login".tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                                letterSpacing: -0.3,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 4),
                            child: Text(
                              "Welcome back, Counsel. Your clients are waiting.".tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.5,
                                color: theme.colorScheme.onSurface.withOpacity(0.65),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 300),
                          child: TextFormField(
                            validator: (value) =>
                                value != null && value.isNotEmpty ? null : 'Required',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            controller: controller.phoneNumberController.value,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                color: theme.colorScheme.onSurface),
                            decoration: InputDecoration(
                              prefixIcon: CountryCodePicker(
                                textStyle: GoogleFonts.poppins(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600),
                                searchStyle: GoogleFonts.poppins(
                                    color: theme.colorScheme.onSurface),
                                onChanged: (value) {
                                  controller.countryCode.value =
                                      value.dialCode.toString();
                                },
                                dialogBackgroundColor: isDark
                                    ? AppColors.darkContainerBackground
                                    : AppColors.containerBackground,
                                initialSelection: controller.countryCode.value,
                                comparator: (a, b) =>
                                    b.name!.compareTo(a.name.toString()),
                                flagDecoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                ),
                              ),
                              hintText: "Phone number".tr,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ButtonThem.buildButton(
                          context,
                          title: "Next".tr,
                          onPress: () {
                            controller.sendCode();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                          child: Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                    height: 1,
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "OR".tr,
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Expanded(
                                  child: Divider(
                                    height: 1,
                                  )),
                            ],
                          ),
                        ),
                        Platform.isIOS ? const SizedBox.shrink() : SocialAuthButton.google(
                          onTap: () async {
                            ShowToastDialog.showLoader("Please wait".tr);
                            await controller.signInWithGoogle().then((value) {
                              ShowToastDialog.closeLoader();
                              if (value != null) {
                                if (value.additionalUserInfo!.isNewUser) {
                                  log("----->new user");
                                  DriverUserModel userModel = DriverUserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.email = value.user!.email;
                                  userModel.fullName = value.user!.displayName;
                                  userModel.profilePic = value.user!.photoURL;
                                  userModel.loginType = Constant.googleLoginType;

                                  ShowToastDialog.closeLoader();
                                  Get.to(const InformationScreen(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  log("----->old user");
                                  FireStoreUtils.userExitOrNot(value.user!.uid).then((userExit) async {
                                    if (userExit == true) {
                                      try {
                                        // Fetch existing profile first
                                        await FireStoreUtils.getDriverProfile(FirebaseAuth.instance.currentUser!.uid).then(
                                              (existingProfile) async {
                                            if (existingProfile != null) {
                                              // Update FCM token on existing profile
                                              String token = await NotificationService.getToken();
                                              existingProfile.fcmToken = token;
                                              await FireStoreUtils.updateDriverUser(existingProfile);

                                              // Navigate to dashboard
                                              Get.offAll(const DashBoardScreen());
                                            } else {
                                              ShowToastDialog.closeLoader();
                                              ShowToastDialog.showToast("Profile not found. Please complete registration.".tr);
                                            }
                                          },
                                        );
                                      } catch (e) {
                                        log("Error updating user: $e");
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast("Login failed. Please try again.".tr);
                                      }
                                    } else {
                                      DriverUserModel userModel = DriverUserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.email = value.user!.email;
                                      userModel.fullName = value.user!.displayName;
                                      userModel.profilePic = value.user!.photoURL;
                                      userModel.loginType = Constant.googleLoginType;

                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    }
                                  }).catchError((error) {
                                    log("Error checking user: $error");
                                    ShowToastDialog.closeLoader();
                                    ShowToastDialog.showToast("Login failed. Please try again.".tr);
                                  });
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SocialAuthButton.facebook(
                          onTap: () async {
                            ShowToastDialog.showLoader("Please wait".tr);
                            await controller.signInWithFacebook().then((value) {
                              ShowToastDialog.closeLoader();
                              if (value != null) {
                                if (value.additionalUserInfo!.isNewUser) {
                                  log("----->new Facebook user");
                                  DriverUserModel userModel = DriverUserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.email = value.user!.email;
                                  userModel.fullName = value.user!.displayName;
                                  userModel.profilePic = value.user!.photoURL;
                                  userModel.loginType = Constant.facebookLoginType;

                                  ShowToastDialog.closeLoader();
                                  Get.to(const InformationScreen(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  log("----->old Facebook user");
                                  FireStoreUtils.userExitOrNot(value.user!.uid).then((userExit) async {
                                    if (userExit == true) {
                                      try {
                                        // Fetch existing profile first
                                        await FireStoreUtils.getDriverProfile(FirebaseAuth.instance.currentUser!.uid).then(
                                              (existingProfile) async {
                                            if (existingProfile != null) {
                                              // Update FCM token on existing profile
                                              String token = await NotificationService.getToken();
                                              existingProfile.fcmToken = token;
                                              await FireStoreUtils.updateDriverUser(existingProfile);

                                              // Navigate to dashboard
                                              Get.offAll(const DashBoardScreen());
                                            } else {
                                              ShowToastDialog.closeLoader();
                                              ShowToastDialog.showToast("Profile not found. Please complete registration.".tr);
                                            }
                                          },
                                        );
                                      } catch (e) {
                                        log("Error updating user: $e");
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast("Login failed. Please try again.".tr);
                                      }
                                    } else {
                                      DriverUserModel userModel = DriverUserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.email = value.user!.email;
                                      userModel.fullName = value.user!.displayName;
                                      userModel.profilePic = value.user!.photoURL;
                                      userModel.loginType = Constant.facebookLoginType;

                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    }
                                  }).catchError((error) {
                                    log("Error checking user: $error");
                                    ShowToastDialog.closeLoader();
                                    ShowToastDialog.showToast("Login failed. Please try again.".tr);
                                  });
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Visibility(
                            visible: Platform.isIOS,
                            child: SocialAuthButton.apple(
                              onTap: () async {
                                ShowToastDialog.showLoader("Please wait".tr);
                                await controller.signInWithApple().then((value) {
                                  ShowToastDialog.closeLoader();
                                  if (value != null) {
                                    Map<String, dynamic> map = value;
                                    AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
                                    UserCredential userCredential = map['userCredential'];

                                    if (userCredential.additionalUserInfo!.isNewUser) {
                                      log("----->new user");
                                      DriverUserModel userModel = DriverUserModel();
                                      userModel.id = userCredential.user!.uid;
                                      userModel.profilePic = userCredential.user!.photoURL;
                                      userModel.loginType = Constant.appleLoginType;
                                      userModel.email = userCredential.additionalUserInfo!.profile!['email'];
                                      userModel.fullName = "${appleCredential.givenName} ${appleCredential.familyName}";

                                      ShowToastDialog.closeLoader();
                                      Get.to(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    } else {
                                      log("----->old user");
                                      FireStoreUtils.userExitOrNot(userCredential.user!.uid).then((userExit) async {
                                        if (userExit == true) {
                                          await FireStoreUtils.getDriverProfile(FirebaseAuth.instance.currentUser!.uid).then(
                                                (value) {
                                              if (value != null) {
                                                DriverUserModel userModel = value;
                                                bool isPlanExpire = false;
                                                if (userModel.subscriptionPlan?.id != null) {
                                                  if (userModel.subscriptionExpiryDate == null) {
                                                    if (userModel.subscriptionPlan?.expiryDay == '-1') {
                                                      isPlanExpire = false;
                                                    } else {
                                                      isPlanExpire = true;
                                                    }
                                                  } else {
                                                    DateTime expiryDate = userModel.subscriptionExpiryDate!.toDate();
                                                    isPlanExpire = expiryDate.isBefore(DateTime.now());
                                                  }
                                                } else {
                                                  isPlanExpire = true;
                                                }
                                                if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
                                                  if (Constant.adminCommission?.isEnabled == false && Constant.isSubscriptionModelApplied == false) {
                                                    ShowToastDialog.closeLoader();
                                                    Get.offAll(const DashBoardScreen());
                                                  } else {
                                                    ShowToastDialog.closeLoader();
                                                    Get.offAll(const SubscriptionListScreen(), arguments: {"isShow": true});
                                                  }
                                                } else {
                                                  Get.offAll(const DashBoardScreen());
                                                }
                                              }
                                            },
                                          );
                                        } else {
                                          DriverUserModel userModel = DriverUserModel();
                                          userModel.id = userCredential.user!.uid;
                                          userModel.profilePic = userCredential.user!.photoURL;
                                          userModel.loginType = Constant.appleLoginType;
                                          userModel.email = userCredential.additionalUserInfo!.profile!['email'];
                                          userModel.fullName = "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}";

                                          Get.to(const InformationScreen(), arguments: {
                                            "userModel": userModel,
                                          });
                                        }
                                      });
                                    }
                                  }
                                });
                              },
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'By tapping "Next" you agree to '.tr,
                    style: GoogleFonts.poppins(),
                    children: <TextSpan>[
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(const TermsAndConditionScreen(
                                type: "terms",
                              ));
                            },
                          text: 'Terms and conditions'.tr,
                          style: GoogleFonts.poppins(decoration: TextDecoration.underline)),
                      TextSpan(text: ' and ', style: GoogleFonts.poppins()),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(const TermsAndConditionScreen(
                                type: "privacy",
                              ));
                            },
                          text: 'privacy policy'.tr,
                          style: GoogleFonts.poppins(decoration: TextDecoration.underline)),
                      // can add more TextSpans here...
                    ],
                  ),
                )),
          );
        });
  }

}

class _LawyerAuthHero extends StatelessWidget {
  final bool isDark;
  const _LawyerAuthHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.95,
          colors: [
            AppColors.brandGold.withOpacity(isDark ? 0.22 : 0.14),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 36,
            child: EntranceFadeSlide(
              duration: const Duration(milliseconds: 600),
              offset: const Offset(0, -14),
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGold.withOpacity(0.40),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.gavel_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: EntranceFadeSlide(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RoolBook',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : AppColors.brandNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandGold.withOpacity(0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'PROFESSIONAL LAWYER WORKSPACE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
