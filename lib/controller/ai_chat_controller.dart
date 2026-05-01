import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';

class ChatMessage {
  final String role; // 'user' or 'model'
  final String text;
  final List<String> sources;

  ChatMessage({required this.role, required this.text, this.sources = const []});
}

class AiChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final textController = TextEditingController();
  final isLoading = false.obs;
  final selectedFile = Rxn<File>();
  final selectedFileName = ''.obs;

  /// Role: 'lawyer' for the driver/lawyer app
  final String role;

  AiChatController({required this.role});

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> pickFile() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      selectedFile.value = File(xFile.path);
      selectedFileName.value = xFile.name;
    }
  }

  void clearFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(role: 'user', text: text));
    textController.clear();
    isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ShowToastDialog.showToast('Please log in again.');
        return;
      }
      final idToken = await user.getIdToken();

      final history = messages
          .take(messages.length - 1)
          .map((m) => {'role': m.role, 'text': m.text})
          .toList();

      final uri = Uri.parse('${Constant.globalUrl}api/ai-chat');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $idToken';
      request.fields['role']    = role;
      request.fields['message'] = text;
      request.fields['history'] = jsonEncode(history);

      final file = selectedFile.value;
      if (file != null) {
        final mimeType = _guessMime(file.path);
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ));
        clearFile();
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final responseBody     = await http.Response.fromStream(streamedResponse);

      if (responseBody.statusCode == 200) {
        final data    = jsonDecode(responseBody.body) as Map<String, dynamic>;
        final reply   = (data['reply'] as String?) ?? 'No response.';
        final sources = (data['sources'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [];
        messages.add(ChatMessage(role: 'model', text: reply, sources: sources));
      } else {
        final err = jsonDecode(responseBody.body);
        final msg = (err['error'] as String?) ?? 'Something went wrong.';
        ShowToastDialog.showToast(msg);
        messages.add(ChatMessage(role: 'model', text: 'Error: $msg'));
      }
    } catch (e) {
      ShowToastDialog.showToast('Network error. Please try again.');
      messages.add(ChatMessage(role: 'model', text: 'Could not reach the server. Please check your connection.'));
    } finally {
      isLoading.value = false;
    }
  }

  String _guessMime(String path) {
    final ext = path.split('.').last.toLowerCase();
    const map = {
      'pdf':  'application/pdf',
      'jpg':  'image/jpeg',
      'jpeg': 'image/jpeg',
      'png':  'image/png',
      'gif':  'image/gif',
      'doc':  'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt':  'text/plain',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}
