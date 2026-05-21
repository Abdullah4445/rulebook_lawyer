import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Lets the lawyer propose 1-3 consultation slots for a case.
/// The customer will pick one from the proposed list.
Future<bool> showProposeConsultationDialog(
    BuildContext context, String orderId) async {
  final List<_SlotDraft> drafts = [];
  final fmt = DateFormat('EEE, MMM d · h:mm a');

  Future<void> addSlot(StateSetter setState) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: const TimeOfDay(hour: 11, minute: 0),
    );
    if (pickedTime == null) return;
    final dt = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);
    setState(() {
      drafts.add(_SlotDraft(dateTime: dt, durationMinutes: 30));
    });
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;
      return StatefulBuilder(builder: (ctx, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
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
                          child: const Icon(Icons.event_available_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Propose Consultation'.tr,
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
                      'Pick up to 3 time slots — client will choose one.'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(drafts.length, (i) {
                      final d = drafts[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                        decoration: BoxDecoration(
                          color: AppColors.brandGold.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                AppColors.brandGold.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 16,
                                color: AppColors.brandGoldDeep),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fmt.format(d.dateTime),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  DropdownButton<int>(
                                    value: d.durationMinutes,
                                    isDense: true,
                                    underline: const SizedBox.shrink(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        color: theme.colorScheme.onSurface),
                                    items: const [15, 30, 45, 60, 90]
                                        .map((m) => DropdownMenuItem(
                                              value: m,
                                              child: Text('$m min'),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          drafts[i] = _SlotDraft(
                                              dateTime: d.dateTime,
                                              durationMinutes: v);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: Colors.redAccent),
                              onPressed: () => setState(() {
                                drafts.removeAt(i);
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (drafts.length < 3)
                      OutlinedButton.icon(
                        onPressed: () => addSlot(setState),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text('Add slot'.tr,
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
                                      .withValues(alpha: 0.7))),
                        ),
                        const SizedBox(width: 6),
                        FilledButton.icon(
                          onPressed: () async {
                            if (drafts.isEmpty) {
                              ShowToastDialog.showToast(
                                  'Add at least one slot.'.tr);
                              return;
                            }
                            ShowToastDialog.showLoader('Sending...'.tr);
                            final c = Consultation(
                              status: 'proposed',
                              proposedSlots: drafts
                                  .map((d) => ConsultationSlot(
                                      start:
                                          Timestamp.fromDate(d.dateTime),
                                      durationMinutes: d.durationMinutes))
                                  .toList(),
                              proposedAt: Timestamp.now(),
                            );
                            try {
                              await FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .doc(orderId)
                                  .set({'consultation': c.toJson()},
                                      SetOptions(merge: true));
                              ShowToastDialog.closeLoader();
                              ShowToastDialog.showToast(
                                  'Slots sent to client.'.tr);
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
                          label: Text('Send to client'.tr,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    },
  );
  return result ?? false;
}

class _SlotDraft {
  final DateTime dateTime;
  final int durationMinutes;
  _SlotDraft({required this.dateTime, required this.durationMinutes});
}
