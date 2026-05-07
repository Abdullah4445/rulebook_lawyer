import 'dart:developer';

import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/otp_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/ui/auth_screen/information_screen.dart';
import 'package:lawyer/ui/dashboard_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../themes/responsive.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          final isDark = themeChange.getThem();
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero header with gold halo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 0.9,
                            colors: [
                              AppColors.brandGold.withOpacity(isDark ? 0.18 : 0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      EntranceFadeSlide(
                        duration: const Duration(milliseconds: 600),
                        offset: const Offset(0, -16),
                        child: Image.asset(
                          "assets/images/login_image.png",
                          width: Responsive.width(60, context),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
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
                              "Verify Phone Number".tr,
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
                            padding: const EdgeInsets.only(top: 6),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                                ),
                                children: [
                                  TextSpan(text: '${"We just send a verification code to".tr}\n'),
                                  TextSpan(
                                    text: controller.countryCode.value + controller.phoneNumber.value,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brandGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 350),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 36),
                            child: PinCodeTextField(
                              textStyle: GoogleFonts.poppins(
                                color: theme.colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              length: 6,
                              appContext: context,
                              keyboardType: TextInputType.phone,
                              pinTheme: PinTheme(
                                fieldHeight: 56,
                                fieldWidth: 48,
                                activeColor: AppColors.brandGold,
                                selectedColor: AppColors.brandGold,
                                inactiveColor: isDark
                                    ? AppColors.darkTextFieldBorder
                                    : AppColors.textFieldBorder,
                                activeFillColor: isDark
                                    ? AppColors.darkTextField
                                    : AppColors.textField,
                                inactiveFillColor: isDark
                                    ? AppColors.darkTextField
                                    : AppColors.textField,
                                selectedFillColor: AppColors.brandGold.withOpacity(0.1),
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(14),
                                borderWidth: 1.4,
                              ),
                              enableActiveFill: true,
                              cursorColor: AppColors.brandGold,
                              animationType: AnimationType.fade,
                              animationDuration: const Duration(milliseconds: 250),
                              controller: controller.otpController.value,
                              onCompleted: (v) async {},
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ButtonThem.buildButton(
                          context,
                          title: "Verify".tr,
                          onPress: () async {
                            if (controller.otpController.value.text.length == 6) {
                              ShowToastDialog.showLoader("Verify OTP".tr);

                              PhoneAuthCredential credential =
                                  PhoneAuthProvider.credential(verificationId: controller.verificationId.value, smsCode: controller.otpController.value.text);
                              await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                if (value.additionalUserInfo!.isNewUser) {
                                  log("----->new user");
                                  DriverUserModel userModel = DriverUserModel();
                                  userModel.id = value.user!.uid;
                                  userModel.countryCode = controller.countryCode.value;
                                  userModel.phoneNumber = controller.phoneNumber.value;
                                  userModel.loginType = Constant.phoneLoginType;

                                  ShowToastDialog.closeLoader();
                                  Get.off(const InformationScreen(), arguments: {
                                    "userModel": userModel,
                                  });
                                } else {
                                  log("----->old user");
                                  FireStoreUtils.userExitOrNot(value.user!.uid).then((userExit) async {
                                    ShowToastDialog.closeLoader();
                                    if (userExit == true) {
                                      await FireStoreUtils.getDriverProfile(value.user!.uid).then(
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
                                                Get.offAll(const DashBoardScreen());
                                              } else {
                                                Get.offAll(const SubscriptionListScreen(), arguments: {"isShow": true});
                                              }
                                            }else{
                                              Get.offAll(const DashBoardScreen());
                                            }
                                          }
                                        },
                                      );
                                    } else {
                                      DriverUserModel userModel = DriverUserModel();
                                      userModel.id = value.user!.uid;
                                      userModel.countryCode = controller.countryCode.value;
                                      userModel.phoneNumber = controller.phoneNumber.value;
                                      userModel.loginType = Constant.phoneLoginType;

                                      Get.off(const InformationScreen(), arguments: {
                                        "userModel": userModel,
                                      });
                                    }
                                  });
                                }
                              }).catchError((error) {
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Code is Invalid".tr);
                              });
                            } else {
                              ShowToastDialog.showToast("Please Enter Valid OTP".tr);
                            }

                            // print(controller.countryCode.value);
                            // print(controller.phoneNumberController.value.text);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
