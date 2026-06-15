import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/reply_templates_controller.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 2.6 — manage canned chat replies the lawyer can quick-insert.
class ReplyTemplatesScreen extends StatelessWidget {
  const ReplyTemplatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ReplyTemplatesController>(
      init: ReplyTemplatesController(),
      builder: (controller) {
        if (controller.isLoading.value) return Constant.loader(context);
        final theme = Theme.of(context);
        // Follow ThemeMode.system, not just the user's in-app toggle.
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(context, Icons.reply_all_rounded,
                    'Reply Templates'.tr, isDark),
                const SizedBox(height: 6),
                Text(
                  'Save canned messages for fast replies in chat.'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.seedDefaults,
                        icon: const Icon(Icons.auto_awesome_rounded,
                            size: 14),
                        label: Text('Add starter set'.tr,
                            style: GoogleFonts.poppins(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandGoldDeep,
                          side: BorderSide(
                              color: AppColors.brandGold
                                  .withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: controller.addBlank,
                        icon: const Icon(Icons.add_rounded, size: 14),
                        label: Text('New blank'.tr,
                            style: GoogleFonts.poppins(fontSize: 12)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandGold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (controller.templates.isEmpty)
                  _empty(context, isDark)
                else
                  ...List.generate(controller.templates.length,
                      (i) => _tile(context, controller, i, isDark)),
                const SizedBox(height: 30),
                ButtonThem.buildButton(
                  context,
                  title:
                      controller.isSaving.value ? 'Saving...'.tr : 'Save'.tr,
                  onPress: controller.isSaving.value
                      ? () {}
                      : () async {
                          final ok = await controller.save();
                          ShowToastDialog.showToast(ok
                              ? 'Templates saved.'.tr
                              : 'Could not save.'.tr);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? AppColors.darkContainerBorder
                : AppColors.containerBorder,
            width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.message_outlined,
              size: 30,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text('No templates yet'.tr,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text('Add the starter set or create your own.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, ReplyTemplatesController c, int i,
      bool isDark) {
    final theme = Theme.of(context);
    final t = c.templates[i];
    final labelCtrl = TextEditingController(text: t.label ?? '');
    final bodyCtrl = TextEditingController(text: t.body ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.brandGold.withValues(alpha: 0.30), width: 1),
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
                child: Text('#${i + 1}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                onPressed: () => c.remove(i),
              ),
            ],
          ),
          TextField(
            controller: labelCtrl,
            style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
            decoration: _decor(context, isDark,
                hint: 'Label (e.g. Request documents)'.tr),
            onChanged: (v) => c.editAt(i, label: v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: bodyCtrl,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.poppins(
                fontSize: 13, color: theme.colorScheme.onSurface),
            decoration: _decor(context, isDark, hint: 'Message body...'.tr),
            onChanged: (v) => c.editAt(i, body: v),
          ),
        ],
      ),
    );
  }

  InputDecoration _decor(BuildContext context, bool isDark,
      {required String hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
          fontSize: 12.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
      filled: true,
      fillColor: isDark
          ? AppColors.darkContainerBackground
          : AppColors.containerBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.brandGold, width: 1.3)),
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
        Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

/// Bottom-sheet picker — used from the chat screen to insert a template.
/// Returns the selected template body, or null if cancelled.
Future<String?> showReplyTemplatePicker(
    BuildContext context, List<ReplyTemplate> templates) async {
  final theme = Theme.of(context);
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: theme.scaffoldBackgroundColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.reply_all_rounded,
                        color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text('Reply Templates'.tr,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                templates.isEmpty
                    ? 'You have no templates yet. Add them from drawer → Reply Templates.'
                        .tr
                    : 'Tap to insert into the message.'.tr,
                style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: theme.dividerColor, height: 1),
                  itemBuilder: (_, i) {
                    final t = templates[i];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.brandGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.bolt_rounded,
                            color: AppColors.brandGoldDeep, size: 16),
                      ),
                      title: Text(t.label ?? '—',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(t.body ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65))),
                      onTap: () => Navigator.pop(ctx, t.body),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
