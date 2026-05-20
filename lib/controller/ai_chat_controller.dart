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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/conversation_model.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/utils/fire_store_utils.dart';

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

  /// Records the case id we last seeded from so re-entering the screen
  /// for the same case doesn't double-prompt the AI.
  String? _seededCaseId;

  AiChatController({required this.role});

  /// Builds a comprehensive prompt from the case and submits it to the AI
  /// as the first user turn so the lawyer lands in the chat with an
  /// initial legal analysis already in flight. Subsequent messages from
  /// the lawyer continue the conversation in full case context.
  ///
  /// Idempotent — calling again with the same case is a no-op.
  Future<void> seedFromCase(OrderModel order) async {
    if (order.id == null || order.id!.isEmpty) return;
    if (_seededCaseId == order.id) return;
    _seededCaseId = order.id;

    final summary = StringBuffer();
    summary.writeln('Please review the following active case in full and provide:');
    summary.writeln('  1. A concise legal summary of the matter');
    summary.writeln('  2. Likely legal issues and applicable principles / case law');
    summary.writeln('  3. Risks the lawyer should flag to the client');
    summary.writeln('  4. Suggested next professional steps');
    summary.writeln();
    summary.writeln('=== CASE FILE ===');
    summary.writeln('Case ID: ${order.id}');
    if (order.caseNumber?.trim().isNotEmpty == true) {
      summary.writeln('Case Number: ${order.caseNumber}');
    }
    if (order.status?.trim().isNotEmpty == true) {
      summary.writeln('Status: ${order.status}');
    }
    if (order.caseStatus?.trim().isNotEmpty == true) {
      summary.writeln('Case Stage: ${order.caseStatus}');
    }
    if (order.service?.title != null) {
      try {
        final categoryTitle =
            Constant().localizationTitle(order.service!.title!, 'Category');
        if (categoryTitle.isNotEmpty) {
          summary.writeln('Category / Specialty: $categoryTitle');
        }
      } catch (_) {/* tolerate localization shape changes */}
    }
    if (order.courtName?.trim().isNotEmpty == true) {
      summary.writeln('Court: ${order.courtName}');
    }
    if (order.judgeName?.trim().isNotEmpty == true) {
      summary.writeln('Judge: ${order.judgeName}');
    }
    if (order.lastHearingDate?.trim().isNotEmpty == true) {
      summary.writeln('Last hearing: ${order.lastHearingDate}');
    }
    if (order.nextHearingDate?.trim().isNotEmpty == true) {
      summary.writeln('Next hearing: ${order.nextHearingDate}');
    }
    if (order.sourceLocationName?.trim().isNotEmpty == true) {
      summary.writeln('Filed from: ${order.sourceLocationName}');
    }
    if (order.sourceLocationLatLng?.latitude != null &&
        order.sourceLocationLatLng?.longitude != null) {
      summary.writeln(
          'Coordinates: ${order.sourceLocationLatLng!.latitude!.toStringAsFixed(5)}, ${order.sourceLocationLatLng!.longitude!.toStringAsFixed(5)}');
    }
    if (order.offerRate?.trim().isNotEmpty == true) {
      summary.writeln('Proposed fee: ${order.offerRate}');
    }
    if (order.finalRate?.trim().isNotEmpty == true) {
      summary.writeln('Agreed fee: ${order.finalRate}');
    }
    if (order.createdDate != null) {
      summary.writeln(
          'Filed at: ${Constant.dateAndTimeFormatTimestamp(order.createdDate)}');
    }
    if (order.description?.trim().isNotEmpty == true) {
      summary.writeln();
      summary.writeln('=== CLIENT DESCRIPTION ===');
      summary.writeln(order.description!.trim());
    } else {
      summary.writeln();
      summary.writeln(
          '(The client has not yet provided a written description of the case.)');
    }

    // Pull the lawyer-client chat thread for this case (chat/{orderId}/thread)
    // and any attachments so the AI gets the full conversation context, not
    // just the headline fields. Failures are non-fatal — the seed continues
    // with whatever was gathered so far.
    final List<ConversationModel> thread = await _fetchChatThread(order.id!);
    if (thread.isNotEmpty) {
      summary.writeln();
      summary.writeln(
          '=== LAWYER–CLIENT CHAT THREAD (${thread.length} message${thread.length == 1 ? "" : "s"}, chronological) ===');
      final attachments = <String>[];
      final lawyerUid = FireStoreUtils.getCurrentUid();
      for (final m in thread) {
        final ts = m.createdAt != null
            ? Constant.dateAndTimeFormatTimestamp(m.createdAt)
            : '';
        final author = m.senderId == lawyerUid ? 'Lawyer' : 'Client';
        final body = (m.message ?? '').trim();
        final mime = m.url?.mime ?? '';
        final url = m.url?.url ?? '';
        if (url.isNotEmpty) {
          attachments.add('  • [$ts] $author shared (${mime.isEmpty ? "file" : mime}): $url');
        }
        if (body.isNotEmpty) {
          summary.writeln('[$ts] $author: $body');
        } else if (url.isNotEmpty) {
          summary.writeln('[$ts] $author shared a ${mime.isEmpty ? "file" : mime}.');
        }
      }
      if (attachments.isNotEmpty) {
        summary.writeln();
        summary.writeln('=== ATTACHMENTS IN THIS CASE ===');
        for (final a in attachments) {
          summary.writeln(a);
        }
        summary.writeln(
            '(You cannot fetch these URLs directly. If you need to analyse a specific document or image, ask the lawyer to forward it in this chat — they can attach it with the paperclip button.)');
      }
    } else {
      summary.writeln();
      summary.writeln(
          '(No prior chat messages between the lawyer and client for this case.)');
    }

    summary.writeln();
    summary.writeln(
        'Treat the above as authoritative case context. The lawyer may follow up with additional details, attached documents, or images — please incorporate everything into your reasoning.');

    // Show the seed text in the UI as a normal user turn so the lawyer
    // sees exactly what was fed to the AI.
    textController.text = summary.toString();
    await sendMessage();
  }

  /// Reads chat/{orderId}/thread in chronological order. Caps at 200
  /// messages so a runaway thread doesn't blow the prompt token budget.
  Future<List<ConversationModel>> _fetchChatThread(String orderId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(CollectionName.chat)
          .doc(orderId)
          .collection('thread')
          .orderBy('createdAt', descending: false)
          .limit(200)
          .get()
          .timeout(const Duration(seconds: 12));
      return snap.docs
          .map((d) => ConversationModel.fromJson(d.data()))
          .toList();
    } catch (e) {
      debugPrint('seedFromCase: chat thread fetch failed: $e');
      return [];
    }
  }

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
      // Bypass ngrok-free's browser warning interstitial. Without this,
      // ngrok serves an HTML "Visit Site" page instead of forwarding the
      // request, which crashes jsonDecode → "Something went wrong".
      request.headers['ngrok-skip-browser-warning'] = 'true';
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

      // Guard: detect non-JSON / HTML response (ngrok interstitial, Laravel
      // exception page, etc.) before attempting jsonDecode.
      final contentType = responseBody.headers['content-type'] ?? '';
      if (!contentType.contains('json') &&
          responseBody.body.trimLeft().startsWith('<')) {
        ShowToastDialog.showToast(
            'Backend returned HTML — check ngrok tunnel & backend logs.');
        final preview = responseBody.body
            .substring(0, responseBody.body.length.clamp(0, 300));
        messages.add(ChatMessage(
            role: 'model',
            text:
                'Got HTML response (likely ngrok interstitial). First 300 chars:\n$preview'));
        return;
      }

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
