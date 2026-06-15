import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/review_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Phase 2.7 — Lawyer sees all client reviews on their profile and can
/// post a single public reply per review. Replies are saved on the
/// review document so the customer app shows them under each review.
class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({Key? key}) : super(key: key);

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uid = FireStoreUtils.getCurrentUid();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(CollectionName.reviewCustomer)
              .where('driverId', isEqualTo: uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Constant.loader(context);
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load reviews.'.tr,
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return _emptyState(theme);

            // Sort newest first by date.
            final reviews = docs
                .map((d) => ReviewModel.fromJson(d.data()))
                .toList()
              ..sort((a, b) {
                final da = a.date?.toDate();
                final db = b.date?.toDate();
                if (da == null || db == null) return 0;
                return db.compareTo(da);
              });

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: reviews.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return _summary(theme, reviews);
                final r = reviews[i - 1];
                return _reviewCard(theme, isDark, r);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _summary(ThemeData theme, List<ReviewModel> reviews) {
    final count = reviews.length;
    double sum = 0;
    int repliedCount = 0;
    for (final r in reviews) {
      sum += double.tryParse(r.rating ?? '0') ?? 0;
      if ((r.lawyerReply ?? '').isNotEmpty) repliedCount++;
    }
    final avg = count == 0 ? 0.0 : sum / count;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < avg.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.white,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count ${"reviews".tr}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$repliedCount ${"replied".tr}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(ThemeData theme, bool isDark, ReviewModel r) {
    final rating = double.tryParse(r.rating ?? '0') ?? 0;
    final date = r.date?.toDate();
    final hasReply = (r.lawyerReply ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.brandGold,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurface),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (r.comment ?? '').isNotEmpty ? r.comment! : 'No comment'.tr,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (hasReply) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandGold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                      color: AppColors.brandGold.withValues(alpha: 0.7),
                      width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply_rounded,
                          size: 14, color: AppColors.brandGoldDeep),
                      const SizedBox(width: 4),
                      Text(
                        'Your reply'.tr,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppColors.brandGoldDeep),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.lawyerReply!,
                    style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        height: 1.5,
                        color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _editReply(r),
              icon: Icon(
                hasReply
                    ? Icons.edit_rounded
                    : Icons.reply_all_rounded,
                size: 14,
              ),
              label: Text(
                hasReply ? 'Edit reply'.tr : 'Reply publicly'.tr,
                style: GoogleFonts.poppins(
                    fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandGoldDeep,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(0, 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGold.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.star_border_rounded,
                  size: 40, color: AppColors.brandGoldDeep),
            ),
            const SizedBox(height: 14),
            Text(
              'No reviews yet'.tr,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Once clients leave feedback, you can reply to it here.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editReply(ReviewModel r) async {
    final ctrl = TextEditingController(text: r.lawyerReply ?? '');
    final reply = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: Text(
              (r.lawyerReply ?? '').isEmpty
                  ? 'Reply to review'.tr
                  : 'Edit reply'.tr,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visible to everyone who views your profile.'.tr,
                  style: GoogleFonts.poppins(
                      fontSize: 11.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        'Thank you for your feedback. We always strive to...'
                            .tr,
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if ((r.lawyerReply ?? '').isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pop(ctx, ''),
                child: Text('Delete reply'.tr,
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.brandGold),
              child: Text('Save'.tr),
            ),
          ],
        );
      },
    );

    if (reply == null) return;
    ShowToastDialog.showLoader('Saving...'.tr);
    try {
      final ref = FirebaseFirestore.instance
          .collection(CollectionName.reviewCustomer)
          .doc(r.id);
      if (reply.isEmpty) {
        await ref.set({
          'lawyerReply': FieldValue.delete(),
          'lawyerReplyAt': FieldValue.delete(),
        }, SetOptions(merge: true));
      } else {
        await ref.set({
          'lawyerReply': reply,
          'lawyerReplyAt': Timestamp.now(),
        }, SetOptions(merge: true));
      }
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(reply.isEmpty
          ? 'Reply removed.'.tr
          : 'Reply published.'.tr);
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Could not save reply.'.tr);
    }
  }
}
