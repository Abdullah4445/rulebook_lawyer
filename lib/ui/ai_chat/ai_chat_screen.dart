import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lawyer/controller/ai_chat_controller.dart';
import 'package:lawyer/themes/app_colors.dart';

class AiChatScreen extends StatelessWidget {
  /// Always 'lawyer' in the driver/lawyer app
  static const String role = 'lawyer';

  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiChatController(role: role));
    final scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.balance, color: AppColors.brandGold, size: 22),
            SizedBox(width: 8),
            Text('AI Legal Research', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ----------------------------------------------------------------
          // Message list
          // ----------------------------------------------------------------
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
                return _buildWelcomePlaceholder();
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (ctx, i) => _buildBubble(controller.messages[i]),
              );
            }),
          ),

          // ----------------------------------------------------------------
          // Loading indicator
          // ----------------------------------------------------------------
          Obx(() => controller.isLoading.value
              ? const LinearProgressIndicator(
                  color: AppColors.brandGold,
                  backgroundColor: AppColors.brandGoldLight,
                )
              : const SizedBox.shrink()),

          // ----------------------------------------------------------------
          // File attachment badge
          // ----------------------------------------------------------------
          Obx(() {
            if (controller.selectedFileName.value.isEmpty) return const SizedBox.shrink();
            return Container(
              color: AppColors.infoLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.selectedFileName.value,
                      style: const TextStyle(fontSize: 13, color: AppColors.info),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.clearFile,
                    child: const Icon(Icons.close, size: 16, color: AppColors.info),
                  ),
                ],
              ),
            );
          }),

          // ----------------------------------------------------------------
          // Input row
          // ----------------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: controller.pickFile,
                  icon: const Icon(Icons.attach_file, color: AppColors.subTitleColor),
                  tooltip: 'Attach PDF or Image',
                ),
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Research a statute, case law, contract clause...',
                      hintStyle: TextStyle(color: AppColors.subTitleColor.withOpacity(0.7)),
                      filled: true,
                      fillColor: AppColors.lightGray,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  onTap: controller.isLoading.value ? null : controller.sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: controller.isLoading.value ? AppColors.subTitleColor : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Welcome placeholder
  // --------------------------------------------------------------------------
  Widget _buildWelcomePlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandGoldLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.balance, size: 48, color: AppColors.brandGold),
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Legal Research',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Get technical legal analysis with citations.\n\nResearch statutes, case law, contract clauses, or procedural questions.\nAttach a document or image for context.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.subTitleColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Chat bubble
  // --------------------------------------------------------------------------
  Widget _buildBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.brandGold,
              child: const Icon(Icons.balance, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.primary,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ),
                // Citation sources
                if (message.sources.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: message.sources
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandGoldLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.brandGold.withOpacity(0.3)),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 10, color: AppColors.primary),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.lightGray,
              child: Icon(Icons.person, size: 16, color: AppColors.subTitleColor),
            ),
          ],
        ],
      ),
    );
  }
}
