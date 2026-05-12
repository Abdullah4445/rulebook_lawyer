import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/bank_details_controller.dart';
import 'package:lawyer/model/bank_details_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/utils/fire_store_utils.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GetX<BankDetailsController>(
      init: BankDetailsController(),
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
                      child: _heroCard(context, isDark),
                    ),
                    const SizedBox(height: 14),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 50),
                      child: _sectionLabel('Payout Account'),
                    ),
                    _formCard(
                      context: context,
                      isDark: isDark,
                      children: [
                        _labelledField(
                          context: context,
                          label: 'Bank Name'.tr,
                          hint: 'Bank Name'.tr,
                          controller: controller.bankNameController.value,
                          delayMs: 100,
                        ),
                        _labelledField(
                          context: context,
                          label: 'Branch Name'.tr,
                          hint: 'Branch Name'.tr,
                          controller: controller.branchNameController.value,
                          delayMs: 160,
                        ),
                        _labelledField(
                          context: context,
                          label: 'Account Holder Name'.tr,
                          hint: 'Holder Name'.tr,
                          controller: controller.holderNameController.value,
                          delayMs: 220,
                        ),
                        _labelledField(
                          context: context,
                          label: 'Account Number'.tr,
                          hint: 'Account Number'.tr,
                          controller: controller.accountNumberController.value,
                          keyboardType: TextInputType.number,
                          delayMs: 280,
                        ),
                        _labelledField(
                          context: context,
                          label: 'Other Information'.tr,
                          hint: 'Other Information'.tr,
                          controller:
                              controller.otherInformationController.value,
                          delayMs: 340,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    EntranceFadeSlide(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400),
                      child: ButtonThem.buildButton(
                        context,
                        title: 'Save'.tr,
                        onPress: () async {
                          if (controller.bankNameController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                                'Please enter bank name'.tr);
                          } else if (controller
                              .branchNameController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                                'Please enter branch name'.tr);
                          } else if (controller
                              .holderNameController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                                'Please enter holder name'.tr);
                          } else if (controller
                              .accountNumberController.value.text.isEmpty) {
                            ShowToastDialog.showToast(
                                'Please enter account number'.tr);
                          } else {
                            ShowToastDialog.showLoader('Please wait'.tr);
                            final BankDetailsModel bankDetailsModel =
                                controller.bankDetailsModel.value;
                            bankDetailsModel.userId =
                                FireStoreUtils.getCurrentUid();
                            bankDetailsModel.bankName =
                                controller.bankNameController.value.text;
                            bankDetailsModel.branchName =
                                controller.branchNameController.value.text;
                            bankDetailsModel.holderName =
                                controller.holderNameController.value.text;
                            bankDetailsModel.accountNumber =
                                controller.accountNumberController.value.text;
                            bankDetailsModel.otherInformation = controller
                                .otherInformationController.value.text;
                            await FireStoreUtils.updateBankDetails(
                                    bankDetailsModel)
                                .then((_) {
                              ShowToastDialog.closeLoader();
                              ShowToastDialog.showToast(
                                  'Bank details update successfully'.tr);
                            });
                          }
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
  // Helpers — matches the Settings screen design language.
  // ─────────────────────────────────────────────────────────

  Widget _heroCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGold.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Details'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Where your payouts and withdrawals are deposited.'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
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
    required TextEditingController controller,
    TextInputType? keyboardType,
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
            TextFieldThem.buildTextFiled(
              context,
              hintText: hint,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}
