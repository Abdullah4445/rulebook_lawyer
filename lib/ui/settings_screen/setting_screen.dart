import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/services/localization_service.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/ui/auth_screen/login_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/Preferences.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/setting_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetBuilder<SettingController>(
      init: SettingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: controller.isLoading.value
              ? Constant.loader(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 400),
                      child: _sectionLabel('Preferences', isDark),
                    ),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 50),
                      child: _settingTile(
                        context: context,
                        iconAsset: 'assets/icons/ic_language.svg',
                        title: 'Language'.tr,
                        trailing: SizedBox(
                          width: 140,
                          child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: _flatDropdownDecoration(),
                            value: controller.selectedLanguage.value.id == null
                                ? null
                                : controller.selectedLanguage.value,
                            onChanged: (value) {
                              controller.selectedLanguage.value = value!;
                              LocalizationService()
                                  .changeLocale(value.code.toString());
                              Preferences.setString(
                                  Preferences.languageCodeKey,
                                  jsonEncode(controller.selectedLanguage.value));
                            },
                            hint: Text('select'.tr,
                                style: GoogleFonts.poppins(fontSize: 13)),
                            items: controller.languageList.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.name.toString(),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 100),
                      child: _settingTile(
                        context: context,
                        iconAsset: 'assets/icons/ic_light_drak.svg',
                        title: 'lit_mode'.tr,
                        trailing: SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: _flatDropdownDecoration(),
                            validator: (value) =>
                                value == null ? 'field required' : null,
                            value: controller.selectedMode.isEmpty
                                ? null
                                : controller.selectedMode.value,
                            onChanged: (value) {
                              controller.selectedMode.value = value!;
                              Preferences.setString(
                                  Preferences.themKey, value.toString());
                              if (value == 'Dark mode') {
                                themeChange.darkTheme = 0;
                              } else if (value == 'Light mode') {
                                themeChange.darkTheme = 1;
                              } else {
                                themeChange.darkTheme = 2;
                              }
                            },
                            hint: Text('select'.tr,
                                style: GoogleFonts.poppins(fontSize: 13)),
                            items: controller.modeList.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.toString(),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 150),
                      child: _sectionLabel('Account', isDark),
                    ),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 200),
                      child: _settingTile(
                        context: context,
                        iconAsset: 'assets/icons/ic_support.svg',
                        title: 'Support'.tr,
                        onTap: () async {
                          final Uri url =
                              Uri.parse(Constant.supportURL.toString());
                          if (!await launchUrl(url)) {
                            throw Exception(
                                'Could not launch ${Constant.supportURL.toString()}'
                                    .tr);
                          }
                        },
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    ),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 250),
                      child: _settingTile(
                        context: context,
                        iconAsset: 'assets/icons/ic_delete.svg',
                        title: 'Delete Account'.tr,
                        titleColor: AppColors.error,
                        iconTintColor: AppColors.error,
                        onTap: () => showAlertDialog(context),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.error.withOpacity(0.6)),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkContainerBackground
                              : AppColors.surfaceTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'V ${Constant.appVersion}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
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

  Widget _settingTile({
    required BuildContext context,
    required String iconAsset,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconTintColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PressScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: (iconTintColor ?? AppColors.brandGold).withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(9),
              child: SvgPicture.asset(
                iconAsset,
                colorFilter: ColorFilter.mode(
                  iconTintColor ?? AppColors.brandGold,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  InputDecoration _flatDropdownDecoration() => const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 1),
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        border: InputBorder.none,
        filled: false,
      );

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text('OK'.tr),
      onPressed: () async {
        ShowToastDialog.showLoader('Please wait'.tr);
        await FireStoreUtils.deleteUser().then((value) {
          ShowToastDialog.closeLoader();
          if (value == true) {
            ShowToastDialog.showToast('Account delete'.tr);
            Get.offAll(const LoginScreen());
          } else {
            ShowToastDialog.showToast('Please contact to administrator'.tr);
          }
        });
      },
    );
    Widget cancel = TextButton(
      child: Text('Cancel'.tr),
      onPressed: () {
        Get.back();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Account delete'.tr),
      content: Text('Are you sure want to delete Account.'.tr),
      actions: [okButton, cancel],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
