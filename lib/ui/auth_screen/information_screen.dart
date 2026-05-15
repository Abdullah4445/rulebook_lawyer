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

                        // ── Basic Info ──────────────────────────────────────
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
                        const SizedBox(height: 24),

                        // ── Lawyer Professional Info Section ────────────────
                        _sectionHeader(context, Icons.gavel, "Lawyer Information".tr, isDark),
                        const SizedBox(height: 14),

                        // License Type
                        _dropdownField(
                          context: context,
                          isDark: isDark,
                          label: "License Type".tr,
                          hint: "Select your license level".tr,
                          value: controller.licenseType.value.isEmpty ? null : controller.licenseType.value,
                          items: InformationController.licenseOptions
                              .map((o) => DropdownMenuItem<String>(
                                    value: o['value'],
                                    child: Text(
                                      o['label']!,
                                      style: GoogleFonts.poppins(fontSize: 13.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.licenseType.value = val;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Bar Council Enrollment Number
                        TextFieldThem.buildTextFiled(
                          context,
                          hintText: 'Bar Council Enrollment No. (e.g. PBC-12345)'.tr,
                          controller: controller.barCouncilIdController.value,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            "Unique ID on your Bar Council Enrollment Card".tr,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurface.withOpacity(0.50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Bar Association
                        _dropdownField(
                          context: context,
                          isDark: isDark,
                          label: "Bar Association".tr,
                          hint: "Select your Bar Association".tr,
                          value: controller.barAssociation.value.isEmpty ? null : controller.barAssociation.value,
                          items: InformationController.barAssociations
                              .map((b) => DropdownMenuItem<String>(
                                    value: b,
                                    child: Text(b, style: GoogleFonts.poppins(fontSize: 13.5)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.barAssociation.value = val;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Province
                        _dropdownField(
                          context: context,
                          isDark: isDark,
                          label: "Province / Territory".tr,
                          hint: "Select province".tr,
                          value: controller.province.value.isEmpty ? null : controller.province.value,
                          items: InformationController.provinces
                              .map((p) => DropdownMenuItem<String>(
                                    value: p,
                                    child: Text(p, style: GoogleFonts.poppins(fontSize: 13.5)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.province.value = val;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Practice City
                        TextFieldThem.buildTextFiled(
                          context,
                          hintText: 'Practice City (e.g. Lahore)'.tr,
                          controller: controller.practiceCityController.value,
                        ),
                        const SizedBox(height: 10),

                        // Qualification
                        TextFieldThem.buildTextFiled(
                          context,
                          hintText: 'Qualification (e.g. LLB, LLM)'.tr,
                          controller: controller.qualificationController.value,
                        ),
                        const SizedBox(height: 10),

                        // Office Address
                        TextFieldThem.buildTextFiled(
                          context,
                          hintText: 'Office / Chamber Address'.tr,
                          controller: controller.officeAddressController.value,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            "Your Bar Association membership card confirms your base city. Documents will be verified by admin.".tr,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurface.withOpacity(0.50),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
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
                          } else if (controller.licenseType.value.isEmpty) {
                            ShowToastDialog.showToast("Please select your license type".tr);
                          } else if (controller.barCouncilIdController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter Bar Council Enrollment No.".tr);
                          } else if (controller.province.value.isEmpty) {
                            ShowToastDialog.showToast("Please select your province".tr);
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
                            // Lawyer fields
                            userModel.licenseType    = controller.licenseType.value;
                            userModel.barCouncilId   = controller.barCouncilIdController.value.text.trim();
                            userModel.barAssociation = controller.barAssociation.value.isEmpty ? null : controller.barAssociation.value;
                            userModel.province       = controller.province.value;
                            userModel.qualification  = controller.qualificationController.value.text.trim().isEmpty ? null : controller.qualificationController.value.text.trim();
                            userModel.officeAddress  = controller.officeAddressController.value.text.trim().isEmpty ? null : controller.officeAddressController.value.text.trim();
                            // cityIds: province-level for HC/SC, city only for Advocate
                            final city = controller.practiceCityController.value.text.trim();
                            if (city.isNotEmpty) {
                              userModel.cityIds = [city];
                            }
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
                                } else {
                                  Get.offAll(const DashBoardScreen());
                                }
                              }
                            });
                          }
                        }),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandGold.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.65)),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.45)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: isDark ? AppColors.darkContainerBackground : AppColors.containerBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandGold, width: 1.5),
        ),
      ),
      dropdownColor: isDark ? AppColors.darkContainerBackground : Colors.white,
      style: GoogleFonts.poppins(fontSize: 13.5, color: theme.colorScheme.onSurface),
      items: items,
      onChanged: onChanged,
    );
  }
}
