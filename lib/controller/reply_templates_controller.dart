import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

/// State + persistence for the lawyer's reply templates (Phase 2.6).
class ReplyTemplatesController extends GetxController {
  final RxList<ReplyTemplate> templates = <ReplyTemplate>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  /// Default starter templates seeded on first save if the lawyer has none.
  static List<ReplyTemplate> get seedTemplates => [
        ReplyTemplate(
          id: const Uuid().v4(),
          label: 'Greeting',
          body:
              'Assalam-o-Alaikum. Thank you for reaching out — I have reviewed your case and will get back to you shortly with the next steps.',
        ),
        ReplyTemplate(
          id: const Uuid().v4(),
          label: 'Request documents',
          body:
              'Please share the following documents so I can proceed:\n1. CNIC (front + back)\n2. Any FIR / case papers you already have\n3. Witness contacts if applicable',
        ),
        ReplyTemplate(
          id: const Uuid().v4(),
          label: 'Share fee',
          body:
              'For this case, my consultation fee is PKR ____ and my hourly rate is PKR ____. Let me know if you would like to proceed.',
        ),
        ReplyTemplate(
          id: const Uuid().v4(),
          label: 'Hearing reminder',
          body:
              'Reminder: our next hearing is scheduled for ____ at ____. Please reach the court 30 minutes early and bring the original documents.',
        ),
      ];

  @override
  void onInit() {
    _load();
    super.onInit();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final uid = FireStoreUtils.getCurrentUid();
      if (uid.isEmpty) return;
      final profile = await FireStoreUtils.getDriverProfile(uid);
      if (profile != null) {
        driverModel.value = profile;
        templates.value =
            List<ReplyTemplate>.from(profile.replyTemplates ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void addBlank() {
    templates.add(ReplyTemplate(
      id: const Uuid().v4(),
      label: '',
      body: '',
    ));
  }

  void remove(int i) {
    if (i >= 0 && i < templates.length) templates.removeAt(i);
  }

  void editAt(int i, {String? label, String? body}) {
    if (i < 0 || i >= templates.length) return;
    final t = templates[i];
    if (label != null) t.label = label;
    if (body != null) t.body = body;
    templates.refresh();
  }

  void seedDefaults() {
    templates.assignAll(seedTemplates);
  }

  Future<bool> save() async {
    isSaving.value = true;
    try {
      final m = driverModel.value;
      m.replyTemplates = templates
          .where((t) =>
              (t.label ?? '').trim().isNotEmpty &&
              (t.body ?? '').trim().isNotEmpty)
          .map((t) => ReplyTemplate(
                id: t.id,
                label: (t.label ?? '').trim(),
                body: (t.body ?? '').trim(),
              ))
          .toList();
      await FirebaseFirestore.instance
          .collection(CollectionName.driverUsers)
          .doc(m.id)
          .set(m.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('ReplyTemplates save failed: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Static helper for the chat screen — fetches the live templates list.
  static Future<List<ReplyTemplate>> loadForCurrentLawyer() async {
    try {
      final uid = FireStoreUtils.getCurrentUid();
      if (uid.isEmpty) return [];
      final profile = await FireStoreUtils.getDriverProfile(uid);
      return profile?.replyTemplates ?? const [];
    } catch (_) {
      return const [];
    }
  }
}
