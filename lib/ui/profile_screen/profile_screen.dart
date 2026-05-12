import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/profile_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/utils/fire_store_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetX<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: controller.isLoading.value
              ? Constant.loader(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 500),
                      child: _profileHeader(context, controller, isDark),
                    ),
                    const SizedBox(height: 18),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 100),
                      child: _sectionLabel('Account Information'),
                    ),
                    _formCard(
                      context: context,
                      isDark: isDark,
                      children: [
                        _labelledField(
                          context: context,
                          label: 'Full name'.tr,
                          hint: 'Full name'.tr,
                          delayMs: 150,
                          child: TextFieldThem.buildTextFiled(
                            context,
                            hintText: 'Full name'.tr,
                            controller: controller.fullNameController.value,
                          ),
                        ),
                        _labelledField(
                          context: context,
                          label: 'Phone number'.tr,
                          hint: 'Phone number'.tr,
                          delayMs: 210,
                          child: TextFormField(
                            controller: controller.phoneNumberController.value,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: CountryCodePicker(
                                enabled: false,
                                textStyle: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w600,
                                ),
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
                              hintText: 'Phone number'.tr,
                            ),
                          ),
                        ),
                        _labelledField(
                          context: context,
                          label: 'Email'.tr,
                          hint: 'Email'.tr,
                          delayMs: 270,
                          isLast: true,
                          child: TextFieldThem.buildTextFiled(
                            context,
                            hintText: 'Email'.tr,
                            controller: controller.emailController.value,
                            enable: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 340),
                      child: ButtonThem.buildButton(
                        context,
                        title: 'Update Profile'.tr,
                        onPress: () async {
                          if (controller
                              .fullNameController.value.text.isEmpty) {
                            ShowToastDialog.showToast('Please enter full name');
                            return;
                          }
                          ShowToastDialog.showLoader('Please wait'.tr);
                          if (controller.profileImage.value.isNotEmpty &&
                              Constant().hasValidUrl(
                                      controller.profileImage.value) ==
                                  false) {
                            controller.profileImage.value =
                                await Constant.uploadUserImageToFireStorage(
                              File(controller.profileImage.value),
                              "profileImage/${FireStoreUtils.getCurrentUid()}",
                              File(controller.profileImage.value)
                                  .path
                                  .split('/')
                                  .last,
                            );
                          }
                          DriverUserModel driverUserModel =
                              controller.driverModel.value;
                          driverUserModel.fullName =
                              controller.fullNameController.value.text;
                          driverUserModel.profilePic =
                              controller.profileImage.value;
                          await FireStoreUtils.updateDriverUser(driverUserModel)
                              .then((_) {
                            ShowToastDialog.closeLoader();
                            controller.getData();
                            ShowToastDialog.showToast(
                                'Profile update successfully'.tr);
                          });
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  Widget _profileHeader(
      BuildContext context, ProfileController controller, bool isDark) {
    final theme = Theme.of(context);
    final hasLocalImage = controller.profileImage.isNotEmpty &&
        Constant().hasValidUrl(controller.profileImage.value) == false;
    final hasRemoteImage = controller.profileImage.isNotEmpty &&
        Constant().hasValidUrl(controller.profileImage.value) == true;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGold.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                child: ClipOval(
                  child: hasLocalImage
                      ? Image.file(
                          File(controller.profileImage.value),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: hasRemoteImage
                              ? controller.profileImage.value
                              : Constant.userPlaceHolder,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Constant.loader(c),
                          errorWidget: (c, u, e) =>
                              Image.network(Constant.userPlaceHolder),
                        ),
                ),
              ),
              PressScale(
                onTap: () => buildBottomSheet(context, controller),
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(7),
                  child: SvgPicture.asset(
                    'assets/icons/ic_edit_profile.svg',
                    colorFilter: const ColorFilter.mode(
                        AppColors.brandNavy, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            controller.fullNameController.value.text.isEmpty
                ? 'Your name'.tr
                : controller.fullNameController.value.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.emailController.value.text.isEmpty
                ? 'tap edit to set up your account'.tr
                : controller.emailController.value.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.brandGold,
        ),
      ),
    );
  }

  Widget _formCard({
    required BuildContext context,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkContainerBorder
              : AppColors.containerBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _labelledField({
    required BuildContext context,
    required String label,
    required String hint,
    required Widget child,
    bool isLast = false,
    int delayMs = 0,
  }) {
    final theme = Theme.of(context);
    return EntranceFadeSlide(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: delayMs),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 6 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }

  buildBottomSheet(BuildContext context, ProfileController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColors.darkContainerBackground
          : AppColors.containerBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Please Select'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _sourceTile(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera'.tr,
                        onTap: () {
                          controller.pickFile(source: ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _sourceTile(
                        context: context,
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery'.tr,
                        onTap: () {
                          controller.pickFile(source: ImageSource.gallery);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sourceTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.brandGold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.30)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.brandGold),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.brandNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
