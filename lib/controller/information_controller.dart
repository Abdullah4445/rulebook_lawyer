import 'dart:developer';
import 'dart:io';

import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Document slot keys used by the upload tiles in the signup screen.
enum DocumentSlot {
  profilePhoto,
  cnicFront,
  cnicBack,
  barCardFront,
  barCardBack,
  selfieWithCard,
}

class InformationController extends GetxController {
  Rx<TextEditingController> fullNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> barCouncilIdController = TextEditingController().obs;
  Rx<TextEditingController> qualificationController = TextEditingController().obs;
  Rx<TextEditingController> officeAddressController = TextEditingController().obs;

  RxString countryCode = "+92".obs;
  RxString loginType = "".obs;

  // Lawyer-specific selections
  RxString licenseType = "".obs;      // 'advocate' | 'advocate_hc' | 'advocate_sc'
  RxString barAssociation = "".obs;
  RxString province = "".obs;

  // ─── Identity verification ────────────────────────────────────────
  /// Picked local files awaiting upload, keyed by slot.
  final RxMap<DocumentSlot, File> pickedFiles = <DocumentSlot, File>{}.obs;
  /// Already-uploaded URLs (hydrated from existing profile on resubmission).
  final RxMap<DocumentSlot, String> uploadedUrls = <DocumentSlot, String>{}.obs;
  /// 'pending' | 'approved' | 'rejected' | '' (never submitted)
  final RxString verificationStatus = "".obs;
  final RxString rejectionReason = "".obs;

  static const List<Map<String, String>> licenseOptions = [
    {'value': 'advocate',    'label': 'Advocate (District / Lower Courts)'},
    {'value': 'advocate_hc', 'label': 'Advocate High Court (Province)'},
    {'value': 'advocate_sc', 'label': 'Advocate Supreme Court (National)'},
  ];

  static const List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Azad Jammu & Kashmir',
    'Gilgit-Baltistan',
  ];

  static const List<String> barAssociations = [
    'Lahore Bar Association',
    'Karachi Bar Association',
    'Islamabad Bar Association',
    'Peshawar Bar Association',
    'Quetta Bar Association',
    'Rawalpindi Bar Association',
    'Faisalabad Bar Association',
    'Multan Bar Association',
    'Gujranwala Bar Association',
    'Sialkot Bar Association',
    'Hyderabad Bar Association',
    'Sukkur Bar Association',
    'Abbottabad Bar Association',
    'Other',
  ];

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<DriverUserModel> userModel = DriverUserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.value.text = userModel.value.phoneNumber.toString();
        countryCode.value = userModel.value.countryCode.toString();
      } else {
        emailController.value.text = userModel.value.email.toString();
        fullNameController.value.text = userModel.value.fullName.toString();
      }
      // Pre-fill lawyer fields if editing existing profile
      if (userModel.value.barCouncilId != null) {
        barCouncilIdController.value.text = userModel.value.barCouncilId!;
      }
      if (userModel.value.qualification != null) {
        qualificationController.value.text = userModel.value.qualification!;
      }
      if (userModel.value.officeAddress != null) {
        officeAddressController.value.text = userModel.value.officeAddress!;
      }
      if (userModel.value.licenseType != null) {
        licenseType.value = userModel.value.licenseType!;
      }
      if (userModel.value.barAssociation != null) {
        barAssociation.value = userModel.value.barAssociation!;
      }
      if (userModel.value.province != null) {
        province.value = userModel.value.province!;
      }

      // Hydrate verification state + existing document URLs (for resubmission UI)
      verificationStatus.value = userModel.value.verificationStatus ?? "";
      rejectionReason.value = userModel.value.rejectionReason ?? "";
      if (userModel.value.profilePic != null && userModel.value.profilePic!.isNotEmpty) {
        uploadedUrls[DocumentSlot.profilePhoto] = userModel.value.profilePic!;
      }
      if (userModel.value.cnicFrontUrl != null) {
        uploadedUrls[DocumentSlot.cnicFront] = userModel.value.cnicFrontUrl!;
      }
      if (userModel.value.cnicBackUrl != null) {
        uploadedUrls[DocumentSlot.cnicBack] = userModel.value.cnicBackUrl!;
      }
      if (userModel.value.barCardFrontUrl != null) {
        uploadedUrls[DocumentSlot.barCardFront] = userModel.value.barCardFrontUrl!;
      }
      if (userModel.value.barCardBackUrl != null) {
        uploadedUrls[DocumentSlot.barCardBack] = userModel.value.barCardBackUrl!;
      }
      if (userModel.value.selfieWithCardUrl != null) {
        uploadedUrls[DocumentSlot.selfieWithCard] = userModel.value.selfieWithCardUrl!;
      }

      log("------->${loginType.value} status=${verificationStatus.value}");
    }
    update();
  }

  /// Whether the documents section should be editable.
  /// While pending or approved, the lawyer cannot change documents.
  bool get isEditable =>
      verificationStatus.value.isEmpty || verificationStatus.value == 'rejected';

  bool get isResubmission => verificationStatus.value == 'rejected';

  /// Pick from camera for selfie, gallery for everything else.
  Future<void> pickDocument(DocumentSlot slot) async {
    if (!isEditable) {
      ShowToastDialog.showToast(
          "Documents are locked while under review.".tr);
      return;
    }
    final picker = ImagePicker();
    final source = slot == DocumentSlot.selfieWithCard
        ? ImageSource.camera
        : ImageSource.gallery;
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null) return;
    pickedFiles[slot] = File(picked.path);
  }

  String _slotPath(DocumentSlot slot) {
    switch (slot) {
      case DocumentSlot.profilePhoto:
        return 'profilePhoto';
      case DocumentSlot.cnicFront:
        return 'cnicFront';
      case DocumentSlot.cnicBack:
        return 'cnicBack';
      case DocumentSlot.barCardFront:
        return 'barCardFront';
      case DocumentSlot.barCardBack:
        return 'barCardBack';
      case DocumentSlot.selfieWithCard:
        return 'selfieWithCard';
    }
  }

  /// Upload every newly-picked file to Firebase Storage and merge the
  /// resulting URLs into [uploadedUrls]. Returns false if any upload fails.
  Future<bool> uploadPendingDocuments(String userId) async {
    for (final entry in pickedFiles.entries) {
      final slot = entry.key;
      final file = entry.value;
      try {
        final url = await Constant.uploadUserImageToFireStorage(
          file,
          'lawyer_documents/$userId',
          '${_slotPath(slot)}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        uploadedUrls[slot] = url;
      } catch (e) {
        log("Upload failed for ${_slotPath(slot)}: $e");
        return false;
      }
    }
    pickedFiles.clear();
    return true;
  }

  /// True when every required document slot has either a picked file or an
  /// already-uploaded URL.
  bool get hasAllDocuments {
    bool _hasSlot(DocumentSlot slot) =>
        pickedFiles.containsKey(slot) || uploadedUrls.containsKey(slot);
    return _hasSlot(DocumentSlot.profilePhoto) &&
        _hasSlot(DocumentSlot.cnicFront) &&
        _hasSlot(DocumentSlot.cnicBack) &&
        _hasSlot(DocumentSlot.barCardFront) &&
        _hasSlot(DocumentSlot.barCardBack) &&
        _hasSlot(DocumentSlot.selfieWithCard);
  }
}
