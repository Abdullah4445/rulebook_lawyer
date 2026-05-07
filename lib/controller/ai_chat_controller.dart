import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  static const List<String> _allowedExtensions = <String>[
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'doc',
    'docx',
    'txt',
  ];

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
    await pickDocument();
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      _setSelectedFile(File(xFile.path), xFile.name);
    }
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      _setSelectedFile(File(xFile.path), xFile.name);
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.single;
    if (picked.path == null || picked.path!.isEmpty) {
      ShowToastDialog.showToast('Please select a valid file.');
      return;
    }

    _setSelectedFile(File(picked.path!), picked.name);
  }

  void _setSelectedFile(File file, String name) {
    selectedFile.value = file;
    selectedFileName.value = name;
  }

  void clearFile() {
    selectedFile.value = null;
    selectedFileName.value = '';
  }

  Future<void> sendMessage() async {
    final inputText = textController.text.trim();
    final file = selectedFile.value;

    if (inputText.isEmpty && file == null) {
      ShowToastDialog.showToast('Please enter text');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ShowToastDialog.showToast('Please log in again.');
        return;
      }

      final text = inputText.isEmpty
          ? _buildAttachmentPrompt(selectedFileName.value)
          : inputText;

      messages.add(ChatMessage(role: 'user', text: text));
      textController.clear();
      isLoading.value = true;

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
        final data    = _decodeBody(responseBody.body);
        final reply   = (data['reply'] as String?) ?? 'No response.';
        final sources = (data['sources'] as List<dynamic>?)
                ?.map((s) => s.toString())
                .toList() ??
            [];
        messages.add(ChatMessage(role: 'model', text: reply, sources: sources));
      } else {
        final err = _decodeBody(responseBody.body);
        final msg = (err['error'] as String?)
            ?? 'Server error (${responseBody.statusCode}).';
        ShowToastDialog.showToast(msg);
        messages.add(ChatMessage(role: 'model', text: msg));
      }
    } on SocketException catch (e) {
      final msg = 'Cannot reach the AI server.\n'
          'Make sure the backend is running at ${Constant.globalUrl} '
          'and that your phone is on the same network.\n\n'
          'Details: ${e.message}';
      ShowToastDialog.showToast('Cannot reach server.');
      messages.add(ChatMessage(role: 'model', text: msg));
    } on TimeoutException {
      const msg = 'The AI server took too long to respond (90s timeout). '
          'The provider may be slow — please try again.';
      ShowToastDialog.showToast('Request timed out.');
      messages.add(ChatMessage(role: 'model', text: msg));
    } on HttpException catch (e) {
      ShowToastDialog.showToast('Network error.');
      messages.add(ChatMessage(role: 'model', text: 'Network error: ${e.message}'));
    } catch (e) {
      ShowToastDialog.showToast('Something went wrong.');
      messages.add(ChatMessage(role: 'model', text: 'Unexpected error: $e'));
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Fall through to a safe fallback map.
    }

    return <String, dynamic>{'error': 'Something went wrong.'};
  }

  String _buildAttachmentPrompt(String fileName) {
    final fileLabel = fileName.isEmpty ? 'the attached file' : 'the attached file "$fileName"';

    if (role == 'lawyer') {
      return 'Please analyze $fileLabel, identify the legal issues, highlight risks, summarize important facts, and suggest the next professional steps with any relevant principles or case law if available.';
    }

    return 'Please review $fileLabel and explain it in simple terms, including key issues, possible risks, and practical next steps.';
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
