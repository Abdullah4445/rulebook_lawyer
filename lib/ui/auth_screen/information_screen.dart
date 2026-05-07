import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/information_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/ui/dashboard_screen.dart';
import 'package:lawyer/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../themes/responsive.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<InformationController>(
        init: InformationController(),
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
                        height: 200,
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
                          width: Responsive.width(55, context),
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
                              "Sign up".tr,
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
                              "Create your account to start using GoRide".tr,
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
                          child: TextFieldThem.buildTextFiled(
                            context,
                            hintText: 'Full name'.tr,
                            controller: controller.fullNameController.value,
                          ),
                        ),
                        const SizedBox(height: 10),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 400),
                          child: TextFormField(
                            validator: (value) =>
                                value != null && value.isNotEmpty ? null : 'Required',
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            controller: controller.phoneNumberController.value,
                            textAlign: TextAlign.start,
                            enabled: controller.loginType.value == Constant.phoneLoginType
                                ? false
                                : true,
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
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                ),
                              ),
                              hintText: "Phone number".tr,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 500),
                          child: TextFieldThem.buildTextFiled(
                            context,
                            hintText: 'Email'.tr,
                            controller: controller.emailController.value,
                            enable: controller.loginType.value == Constant.googleLoginType
                                ? false
                                : true,
                          ),
                        ),
                        const SizedBox(height: 50),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 600),
                          child: ButtonThem.buildButton(context, title: "Create account".tr, onPress: () async {
                          if (controller.fullNameController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter full name".tr);
                          } else if (controller.emailController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter email".tr);
                          } else if (controller.phoneNumberController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter phone number".tr);
                          } else if (Constant.validateEmail(controller.emailController.value.text) == false) {
                            ShowToastDialog.showToast("Please enter valid email".tr);
                          } else {
                            ShowToastDialog.showLoader("Please wait".tr);
                            DriverUserModel userModel = controller.userModel.value;
                            userModel.fullName = controller.fullNameController.value.text;
                            userModel.email = controller.emailController.value.text;
                            userModel.countryCode = controller.countryCode.value;
                            userModel.phoneNumber = controller.phoneNumberController.value.text;
                            userModel.documentVerification = false;
                            userModel.isOnline = false;
                            userModel.createdAt = Timestamp.now();
                            String token = await NotificationService.getToken();
                            userModel.fcmToken = token;

                            await FireStoreUtils.updateDriverUser(userModel).then((value) {
                              ShowToastDialog.closeLoader();
                              if (value == true) {
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
                            });
                          }
                        }),
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
