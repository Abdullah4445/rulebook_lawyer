import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/information_controller.dart';
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
                  // ── Profile photo as hero (replaces static illustration) ──
                  _profilePhotoHero(context, controller, isDark),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Verification status banner (if any) ──
                        if (controller.verificationStatus.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16, top: 4),
                            child: _verificationBanner(context, controller, isDark),
                          ),

                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 100),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              controller.isResubmission
                                  ? "Resubmit your details".tr
                                  : "Sign up".tr,
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
                              controller.isResubmission
                                  ? "Update the rejected information and resubmit.".tr
                                  : "Create your account to start using Rulebook Lawyer".tr,
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
                        const SizedBox(height: 24),

                        // ── Identity Documents Section ──────────────────────
                        _sectionHeader(context, Icons.verified_user_outlined,
                            "Identity Documents".tr, isDark),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                          child: Text(
                            "Upload clear photos. Admin will verify within 24-48 hours.".tr,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurface.withOpacity(0.55),
                              height: 1.5,
                            ),
                          ),
                        ),

                        _documentTile(
                          context: context,
                          controller: controller,
                          isDark: isDark,
                          slot: DocumentSlot.cnicFront,
                          icon: Icons.credit_card,
                          title: "CNIC — Front".tr,
                          subtitle: "Photo of CNIC front side".tr,
                        ),
                        const SizedBox(height: 10),
                        _documentTile(
                          context: context,
                          controller: controller,
                          isDark: isDark,
                          slot: DocumentSlot.cnicBack,
                          icon: Icons.credit_card,
                          title: "CNIC — Back".tr,
                          subtitle: "Photo of CNIC back side".tr,
                        ),
                        const SizedBox(height: 10),
                        _documentTile(
                          context: context,
                          controller: controller,
                          isDark: isDark,
                          slot: DocumentSlot.barCardFront,
                          icon: Icons.badge_outlined,
                          title: "Bar Council Card — Front".tr,
                          subtitle: "Photo of enrollment card front".tr,
                        ),
                        const SizedBox(height: 10),
                        _documentTile(
                          context: context,
                          controller: controller,
                          isDark: isDark,
                          slot: DocumentSlot.barCardBack,
                          icon: Icons.badge_outlined,
                          title: "Bar Council Card — Back".tr,
                          subtitle: "Photo of enrollment card back".tr,
                        ),
                        const SizedBox(height: 10),
                        _documentTile(
                          context: context,
                          controller: controller,
                          isDark: isDark,
                          slot: DocumentSlot.selfieWithCard,
                          icon: Icons.camera_alt_outlined,
                          title: "Selfie with Bar Council Card".tr,
                          subtitle: "Take a live selfie holding your card".tr,
                        ),

                        const SizedBox(height: 30),
                        EntranceFadeSlide(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 600),
                          child: ButtonThem.buildButton(
                            context,
                            title: _primaryButtonLabel(controller),
                            onPress: controller.verificationStatus.value == 'pending' ||
                                    controller.verificationStatus.value == 'approved'
                                ? () {}
                                : () => _onSubmit(context, controller),
                          ),
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

  // ─────────────────── HERO PROFILE PHOTO ───────────────────
  Widget _profilePhotoHero(BuildContext context, InformationController controller, bool isDark) {
    final theme = Theme.of(context);
    final url = controller.uploadedUrls[DocumentSlot.profilePhoto];
    final picked = controller.pickedFiles[DocumentSlot.profilePhoto];
    return Stack(
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
          child: GestureDetector(
            onTap: () => controller.pickDocument(DocumentSlot.profilePhoto),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGold.withOpacity(0.35),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: Container(
                      color: isDark ? AppColors.darkContainerBackground : Colors.white,
                      child: picked != null
                          ? Image.file(picked, fit: BoxFit.cover)
                          : (url != null
                              ? Image.network(url, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarPlaceholder(theme))
                              : _avatarPlaceholder(theme)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandGold,
                    border: Border.all(
                        color: isDark ? AppColors.darkContainerBackground : Colors.white,
                        width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarPlaceholder(ThemeData theme) {
    return Icon(
      Icons.person_outline,
      size: 60,
      color: theme.colorScheme.onSurface.withOpacity(0.35),
    );
  }

  // ─────────────────── VERIFICATION STATUS BANNER ───────────────────
  Widget _verificationBanner(BuildContext context, InformationController controller, bool isDark) {
    final status = controller.verificationStatus.value;
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String title;
    late final String body;
    switch (status) {
      case 'pending':
        bg = const Color(0xFFFFF7E0);
        fg = const Color(0xFFA17A00);
        icon = Icons.hourglass_top_rounded;
        title = "Under review".tr;
        body = "Your documents are being verified by admin. You'll be notified within 24-48 hours.".tr;
        break;
      case 'approved':
        bg = const Color(0xFFE8F7EE);
        fg = const Color(0xFF1D7A3A);
        icon = Icons.verified_rounded;
        title = "Verified".tr;
        body = "Your account is approved. You can start receiving cases.".tr;
        break;
      case 'rejected':
        bg = const Color(0xFFFDECEC);
        fg = const Color(0xFFB02828);
        icon = Icons.error_outline_rounded;
        title = "Rejected — please resubmit".tr;
        body = controller.rejectionReason.value.isNotEmpty
            ? controller.rejectionReason.value
            : "Documents could not be verified. Please review and resubmit.".tr;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? fg.withOpacity(0.12) : bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg.withOpacity(0.15),
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.4,
                    color: fg.withOpacity(0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── DOCUMENT TILE ───────────────────
  Widget _documentTile({
    required BuildContext context,
    required InformationController controller,
    required bool isDark,
    required DocumentSlot slot,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final picked = controller.pickedFiles[slot];
    final url = controller.uploadedUrls[slot];
    final hasFile = picked != null || url != null;
    final locked = !controller.isEditable;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: locked ? null : () => controller.pickDocument(slot),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkContainerBackground : AppColors.containerBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.brandGold.withOpacity(0.55)
                : (isDark ? AppColors.darkContainerBorder : AppColors.containerBorder),
            width: hasFile ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail or icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.onSurface.withOpacity(0.05),
              ),
              clipBehavior: Clip.antiAlias,
              child: picked != null
                  ? Image.file(picked, fit: BoxFit.cover)
                  : (url != null
                      ? Image.network(url, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.brandGold))
                      : Icon(icon, color: AppColors.brandGold, size: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasFile ? "Tap to replace".tr : subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: hasFile ? const Color(0xFF1D7A3A) : AppColors.brandGold,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── BUTTON LABEL ───────────────────
  String _primaryButtonLabel(InformationController controller) {
    switch (controller.verificationStatus.value) {
      case 'pending':
        return "Under review".tr;
      case 'approved':
        return "Continue".tr;
      case 'rejected':
        return "Resubmit".tr;
      default:
        return "Create account".tr;
    }
  }

  // ─────────────────── SUBMIT HANDLER ───────────────────
  Future<void> _onSubmit(BuildContext context, InformationController controller) async {
    if (controller.fullNameController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter full name".tr);
      return;
    }
    if (controller.emailController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter email".tr);
      return;
    }
    if (controller.phoneNumberController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter phone number".tr);
      return;
    }
    if (Constant.validateEmail(controller.emailController.value.text) == false) {
      ShowToastDialog.showToast("Please enter valid email".tr);
      return;
    }
    if (controller.licenseType.value.isEmpty) {
      ShowToastDialog.showToast("Please select your license type".tr);
      return;
    }
    if (controller.barCouncilIdController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter Bar Council Enrollment No.".tr);
      return;
    }
    if (controller.province.value.isEmpty) {
      ShowToastDialog.showToast("Please select your province".tr);
      return;
    }
    if (!controller.hasAllDocuments) {
      ShowToastDialog.showToast(
          "Please upload all required documents (profile photo, CNIC, Bar Card, selfie).".tr);
      return;
    }

    ShowToastDialog.showLoader("Uploading documents...".tr);
    final userModel = controller.userModel.value;
    final userId = userModel.id;
    if (userId == null || userId.isEmpty) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("User session expired. Please log in again.".tr);
      return;
    }

    final uploadOk = await controller.uploadPendingDocuments(userId);
    if (!uploadOk) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Could not upload one or more documents. Please try again.".tr);
      return;
    }

    ShowToastDialog.showLoader("Saving...".tr);
    userModel.fullName = controller.fullNameController.value.text;
    userModel.email = controller.emailController.value.text;
    userModel.countryCode = controller.countryCode.value;
    userModel.phoneNumber = controller.phoneNumberController.value.text;
    userModel.documentVerification = false;
    userModel.isOnline = false;
    userModel.createdAt ??= Timestamp.now();
    // Lawyer fields
    userModel.licenseType = controller.licenseType.value;
    userModel.barCouncilId = controller.barCouncilIdController.value.text.trim();
    userModel.barAssociation =
        controller.barAssociation.value.isEmpty ? null : controller.barAssociation.value;
    userModel.province = controller.province.value;
    userModel.qualification =
        controller.qualificationController.value.text.trim().isEmpty
            ? null
            : controller.qualificationController.value.text.trim();
    userModel.officeAddress =
        controller.officeAddressController.value.text.trim().isEmpty
            ? null
            : controller.officeAddressController.value.text.trim();

    // Identity documents
    userModel.profilePic = controller.uploadedUrls[DocumentSlot.profilePhoto];
    userModel.cnicFrontUrl = controller.uploadedUrls[DocumentSlot.cnicFront];
    userModel.cnicBackUrl = controller.uploadedUrls[DocumentSlot.cnicBack];
    userModel.barCardFrontUrl = controller.uploadedUrls[DocumentSlot.barCardFront];
    userModel.barCardBackUrl = controller.uploadedUrls[DocumentSlot.barCardBack];
    userModel.selfieWithCardUrl = controller.uploadedUrls[DocumentSlot.selfieWithCard];
    userModel.verificationStatus = 'pending';
    userModel.rejectionReason = null;
    userModel.documentsSubmittedAt = Timestamp.now();

    final token = await NotificationService.getToken();
    userModel.fcmToken = token;

    final ok = await FireStoreUtils.updateDriverUser(userModel);
    ShowToastDialog.closeLoader();
    if (ok != true) {
      ShowToastDialog.showToast("Could not save your profile. Please try again.".tr);
      return;
    }

    controller.verificationStatus.value = 'pending';
    ShowToastDialog.showToast(
        "Submitted. Admin will verify your documents within 24-48 hours.".tr);

    bool isPlanExpire = false;
    if (userModel.subscriptionPlan?.id != null) {
      if (userModel.subscriptionExpiryDate == null) {
        isPlanExpire = userModel.subscriptionPlan?.expiryDay != '-1';
      } else {
        isPlanExpire = userModel.subscriptionExpiryDate!.toDate().isBefore(DateTime.now());
      }
    } else {
      isPlanExpire = true;
    }

    if (userModel.subscriptionPlanId == null || isPlanExpire) {
      if (Constant.adminCommission?.isEnabled == false &&
          Constant.isSubscriptionModelApplied == false) {
        Get.offAll(const DashBoardScreen());
      } else {
        Get.offAll(const SubscriptionListScreen(), arguments: {"isShow": true});
      }
    } else {
      Get.offAll(const DashBoardScreen());
    }
  }

  // ─────────────────── SECTION HEADER ───────────────────
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

  // ─────────────────── DROPDOWN FIELD ───────────────────
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
