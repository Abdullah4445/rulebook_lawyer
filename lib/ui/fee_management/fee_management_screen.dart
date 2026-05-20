import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/fee_management_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FeeManagementScreen extends StatelessWidget {
  const FeeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<FeeManagementController>(
      init: FeeManagementController(),
      builder: (controller) {
        if (controller.isLoading.value) {
          return Constant.loader(context);
        }
        final isDark = themeChange.getThem();
        final theme = Theme.of(context);
        final symbol = Constant.currencyModel?.symbol ?? 'PKR';

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, Icons.payments_rounded, 'Base Rates'.tr, isDark),
                const SizedBox(height: 12),
                _labeledField(
                  context: context,
                  label: 'Consultation fee ($symbol)'.tr,
                  hint: 'e.g. 2000',
                  controller: controller.consultationFeeController.value,
                  helper: 'Flat fee charged for the first consultation.'.tr,
                ),
                const SizedBox(height: 12),
                _labeledField(
                  context: context,
                  label: 'Hourly rate ($symbol / hr)'.tr,
                  hint: 'e.g. 5000',
                  controller: controller.hourlyRateController.value,
                  helper: 'Used when work runs beyond the consultation.'.tr,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _sectionHeader(context, Icons.inventory_2_rounded,
                          'Service Packages'.tr, isDark),
                    ),
                    InkWell(
                      onTap: controller.addPackage,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Add'.tr,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Fixed-price offers — e.g. "Divorce Khula — $symbol 50,000".'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(controller.packages.length, (i) {
                  return _packageCard(context, controller, i, isDark, symbol);
                }),
                if (controller.packages.isEmpty)
                  _emptyPackages(context, isDark),

                const SizedBox(height: 30),
                ButtonThem.buildButton(
                  context,
                  title: controller.isSaving.value
                      ? 'Saving...'.tr
                      : 'Save fees'.tr,
                  onPress: controller.isSaving.value
                      ? () {}
                      : () async {
                          final ok = await controller.save();
                          ShowToastDialog.showToast(ok
                              ? 'Fees updated.'.tr
                              : 'Could not save fees.'.tr);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyPackages(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? AppColors.darkContainerBorder : AppColors.containerBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 32,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            'No packages yet'.tr,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add fixed-price service offerings to attract clients.'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageCard(BuildContext context, FeeManagementController controller,
      int index, bool isDark, String symbol) {
    final theme = Theme.of(context);
    final pkg = controller.packages[index];
    final nameCtrl = TextEditingController(text: pkg.name ?? '');
    final descCtrl = TextEditingController(text: pkg.description ?? '');
    final feeCtrl =
        TextEditingController(text: pkg.fee != null ? pkg.fee.toString() : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${index + 1}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent.withValues(alpha: 0.85), size: 20),
                onPressed: () => controller.removePackage(index),
              ),
            ],
          ),
          TextField(
            controller: nameCtrl,
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
            decoration: _decoration(
              context,
              isDark,
              hint: 'Package name (e.g. Divorce Khula)'.tr,
            ),
            onChanged: (v) => controller.updatePackage(index, name: v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descCtrl,
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
            maxLines: 2,
            decoration: _decoration(
              context,
              isDark,
              hint: 'Short description (optional)'.tr,
            ),
            onChanged: (v) => controller.updatePackage(index, description: v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: feeCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface),
            decoration: _decoration(
              context,
              isDark,
              hint: 'Fee in $symbol',
              prefix: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  symbol,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandGoldDeep,
                  ),
                ),
              ),
            ),
            onChanged: (v) => controller.updatePackage(
                index,
                fee: double.tryParse(v.trim())),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, bool isDark,
      {required String hint, Widget? prefix}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      ),
      prefixIcon: prefix,
      prefixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: isDark
          ? AppColors.darkContainerBackground
          : AppColors.containerBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brandGold, width: 1.4),
      ),
    );
  }

  Widget _labeledField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    String? helper,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        TextFieldThem.buildTextFiled(
          context,
          hintText: hint,
          controller: controller,
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              helper,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(
      BuildContext context, IconData icon, String title, bool isDark) {
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
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
