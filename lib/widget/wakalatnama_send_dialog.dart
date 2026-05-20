import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a modal dialog that lets the lawyer compose and send a
/// Wakalatnama to the client. Pre-fills lawyer fields from the
/// signed-in profile and writes to the order doc.
Future<bool> showSendWakalatnamaDialog(
    BuildContext context, String orderId) async {
  final profile = await FireStoreUtils.getDriverProfile(
      FireStoreUtils.getCurrentUid());
  final lawyerNameCtrl =
      TextEditingController(text: profile?.fullName ?? '');
  final barIdCtrl =
      TextEditingController(text: profile?.barCouncilId ?? '');
  final clientCtrl = TextEditingController();
  final courtCtrl = TextEditingController();
  final bodyCtrl = TextEditingController(
    text: _defaultBody(
      lawyerName: profile?.fullName ?? '',
      barCouncilId: profile?.barCouncilId ?? '',
    ),
  );

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.gavel_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Send Wakalatnama'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Client will receive a banner to review and sign.'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(ctx, isDark, 'Lawyer name'.tr, lawyerNameCtrl),
                  const SizedBox(height: 10),
                  _field(ctx, isDark, 'Bar Council ID'.tr, barIdCtrl),
                  const SizedBox(height: 10),
                  _field(ctx, isDark, 'Client name'.tr, clientCtrl),
                  const SizedBox(height: 10),
                  _field(
                    ctx,
                    isDark,
                    'Court'.tr,
                    courtCtrl,
                    hint: 'e.g. Senior Civil Judge, Vehari'.tr,
                  ),
                  const SizedBox(height: 10),
                  _field(
                    ctx,
                    isDark,
                    'Wakalatnama body'.tr,
                    bodyCtrl,
                    maxLines: 7,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel'.tr,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            )),
                      ),
                      const SizedBox(width: 6),
                      FilledButton.icon(
                        onPressed: () async {
                          if (clientCtrl.text.trim().isEmpty ||
                              courtCtrl.text.trim().isEmpty ||
                              bodyCtrl.text.trim().isEmpty) {
                            ShowToastDialog.showToast(
                                'Please fill all fields.'.tr);
                            return;
                          }
                          ShowToastDialog.showLoader('Sending...'.tr);
                          final w = Wakalatnama(
                            status: 'sent',
                            lawyerNameOnDoc: lawyerNameCtrl.text.trim(),
                            barCouncilId: barIdCtrl.text.trim(),
                            clientNameOnDoc: clientCtrl.text.trim(),
                            courtName: courtCtrl.text.trim(),
                            body: bodyCtrl.text.trim(),
                            sentAt: Timestamp.now(),
                          );
                          try {
                            await FirebaseFirestore.instance
                                .collection(CollectionName.orders)
                                .doc(orderId)
                                .set({'wakalatnama': w.toJson()},
                                    SetOptions(merge: true));
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast(
                                'Wakalatnama sent to client.'.tr);
                            Navigator.pop(ctx, true);
                          } catch (_) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast(
                                'Could not send. Try again.'.tr);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandGold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text('Send'.tr,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

Widget _field(BuildContext ctx, bool isDark, String label,
    TextEditingController controller,
    {String? hint, int maxLines = 1}) {
  final theme = Theme.of(ctx);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 5),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ),
      TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        style: GoogleFonts.poppins(
            fontSize: 13, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.40),
          ),
          filled: true,
          fillColor: isDark
              ? AppColors.darkContainerBackground
              : AppColors.containerBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.brandGold, width: 1.4),
          ),
        ),
      ),
    ],
  );
}

String _defaultBody({required String lawyerName, required String barCouncilId}) {
  return 'I, the undersigned client, hereby appoint and authorise '
      'Advocate $lawyerName (Bar Council ID: $barCouncilId) as my lawyer '
      'and Attorney-in-Fact to represent me, plead, conduct and defend '
      'the case mentioned herein and to perform all acts that are lawful '
      'and necessary for the prosecution / defence of the said case.';
}
