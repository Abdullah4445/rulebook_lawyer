import 'package:lawyer/controller/ai_chat_controller.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiChatScreen extends StatelessWidget {
  static const String role = 'lawyer';

  /// When supplied (e.g. from the active-case "Analyze with AI" button),
  /// the chat is auto-seeded with a structured case summary so the
  /// lawyer arrives with an initial AI analysis already in flight. Safe
  /// to pass repeatedly — the controller deduplicates by case id.
  final OrderModel? initialCase;

  const AiChatScreen({super.key, this.initialCase});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AiChatController>(tag: role)
        ? Get.find<AiChatController>(tag: role)
        : Get.put(AiChatController(role: role), tag: role);

    if (initialCase != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.seedFromCase(initialCase!);
      });
    }
    final scrollController = ScrollController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0B0F18) : const Color(0xFFF7F4EC);
    final aiBubbleBg = isDark ? const Color(0xFF1B2230) : Colors.white;
    final aiBubbleBorder = isDark ? const Color(0xFF2A3243) : const Color(0xFFEFE6CC);
    final inputSurface = isDark ? const Color(0xFF111723) : Colors.white;
    final inputFill = isDark ? const Color(0xFF1B2230) : const Color(0xFFF1ECDD);
    final onSurface = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = onSurface.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0F18), Color(0xFF1B2230)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.brandGold, width: 1.5),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.gavel, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Legal System',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                if (controller.messages.isEmpty) {
                  return _buildWelcomePlaceholder(onSurface, muted);
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (ctx, i) => _buildBubble(
                    controller.messages[i],
                    aiBubbleBg: aiBubbleBg,
                    aiBubbleBorder: aiBubbleBorder,
                    onSurface: onSurface,
                    isDark: isDark,
                  ),
                );
              }),
            ),

            Obx(() => controller.isLoading.value
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.brandGold,
                    backgroundColor: AppColors.brandGoldLight,
                  )
                : const SizedBox.shrink()),

            Obx(() {
              if (controller.selectedFileName.value.isEmpty) return const SizedBox.shrink();
              return Container(
                color: AppColors.brandGoldLight,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: AppColors.brandGold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        controller.selectedFileName.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B5310),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearFile,
                      child: const Icon(Icons.close, size: 16, color: AppColors.brandGold),
                    ),
                  ],
                ),
              );
            }),

            Container(
              decoration: BoxDecoration(
                color: inputSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _showAttachmentOptions(context, controller),
                    icon: Icon(Icons.attach_file, color: muted),
                    tooltip: 'Attach File',
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask a legal research question...',
                        hintStyle: TextStyle(color: muted, fontSize: 14),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => GestureDetector(
                        onTap: controller.isLoading.value
                            ? null
                            : controller.sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: controller.isLoading.value
                                ? null
                                : AppColors.goldGradient,
                            color: controller.isLoading.value
                                ? AppColors.gray400
                                : null,
                            shape: BoxShape.circle,
                            boxShadow: controller.isLoading.value
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.brandGold
                                          .withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttachmentOptions(
    BuildContext context,
    AiChatController controller,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final optionTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = optionTextColor.withValues(alpha: 0.65);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF111723) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Attach File',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: optionTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: Icon(Icons.close, color: secondaryColor),
                    ),
                  ],
                ),
                _buildAttachmentTile(
                  context: sheetContext,
                  icon: Icons.camera_alt_outlined,
                  iconBackground: AppColors.brandGoldLight,
                  iconColor: AppColors.brandGold,
                  title: 'Camera'.tr,
                  subtitle: 'Capture an image for legal review',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await controller.pickImageFromCamera();
                  },
                ),
                _buildAttachmentTile(
                  context: sheetContext,
                  icon: Icons.photo_library_outlined,
                  iconBackground: AppColors.infoLight,
                  iconColor: AppColors.info,
                  title: 'Gallery'.tr,
                  subtitle: 'Choose a photo from your gallery',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await controller.pickImageFromGallery();
                  },
                ),
                _buildAttachmentTile(
                  context: sheetContext,
                  icon: Icons.description_outlined,
                  iconBackground: AppColors.successLight,
                  iconColor: AppColors.success,
                  title: 'Files',
                  subtitle: 'Upload PDF, DOC, DOCX, TXT or image files',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await controller.pickDocument();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
  }) {
    final theme = Theme.of(context);
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.72) ?? AppColors.subTitleColor;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: iconBackground,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: subtitleColor),
      ),
      onTap: () {
        onTap();
      },
    );
  }

  Widget _buildWelcomePlaceholder(Color onSurface, Color muted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGold.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.gavel, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'AI Legal System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: onSurface,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get professional legal research, document review, case-law support, drafting guidance, and admin-managed knowledge base answers in one place.\n\nAttach documents or images for deeper analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: muted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(
    ChatMessage message, {
    required Color aiBubbleBg,
    required Color aiBubbleBorder,
    required Color onSurface,
    required bool isDark,
  }) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGold.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.gavel, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF1B2230), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : aiBubbleBg,
                    border: isUser
                        ? null
                        : Border.all(color: aiBubbleBorder, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? Colors.black.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : onSurface,
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  ),
                ),
                if (message.sources.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: message.sources
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandGoldLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.brandGold.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B5310),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 17,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
