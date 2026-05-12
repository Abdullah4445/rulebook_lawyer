import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/inbox_model.dart';
import 'package:lawyer/model/user_model.dart';
import 'package:lawyer/themes/animations.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/ui/chat_screen/chat_screen.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:lawyer/widget/firebase_pagination/src/models/view_type.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: FirestorePagination(
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, documentSnapshots, index) {
            final data =
                documentSnapshots[index].data() as Map<String, dynamic>?;
            if (data == null) return const SizedBox.shrink();
            final InboxModel inboxModel = InboxModel.fromJson(data);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PressScale(
                onTap: () async {
                  final UserModel? customer = await FireStoreUtils.getCustomer(
                      inboxModel.customerId.toString());
                  final DriverUserModel? driver =
                      await FireStoreUtils.getDriverProfile(
                          inboxModel.driverId.toString());
                  if (customer == null || driver == null) return;
                  Get.to(ChatScreens(
                    driverId: driver.id,
                    customerId: customer.id,
                    customerName: customer.fullName,
                    customerProfileImage: customer.profilePic,
                    driverName: driver.fullName,
                    driverProfileImage: driver.profilePic,
                    orderId: inboxModel.orderId,
                    token: customer.fcmToken,
                  ));
                },
                child: _conversationCard(
                  context: context,
                  isDark: isDark,
                  inboxModel: inboxModel,
                ),
              ),
            );
          },
          shrinkWrap: true,
          onEmpty: _emptyState(context, isDark),
          query: FirebaseFirestore.instance
              .collection(CollectionName.chat)
              .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
              .orderBy('createdAt', descending: true),
          viewType: ViewType.list,
          initialLoader: const Center(child: CircularProgressIndicator()),
          isLive: true,
        ),
      ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  Widget _conversationCard({
    required BuildContext context,
    required bool isDark,
    required InboxModel inboxModel,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkContainerBackground
            : AppColors.containerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkContainerBorder
              : AppColors.containerBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gold ring
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: ClipOval(
              child: SizedBox(
                width: 46,
                height: 46,
                child: CachedNetworkImage(
                  imageUrl: inboxModel.customerProfileImage?.toString() ?? '',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.brandGold.withValues(alpha: 0.15),
                    child: const Icon(Icons.person,
                        color: AppColors.brandGold, size: 26),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.brandGold.withValues(alpha: 0.15),
                    child: const Icon(Icons.person,
                        color: AppColors.brandGold, size: 26),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        (inboxModel.customerName ?? '').isEmpty
                            ? 'Client'
                            : inboxModel.customerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Constant.dateFormatTimestamp(inboxModel.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandGold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'CASE',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandGold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '#${inboxModel.orderId ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.70),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGold.withValues(alpha: 0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.mark_chat_unread_outlined,
                  size: 38, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              'No conversations yet'.tr,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Client messages will appear here once a case is accepted.'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
