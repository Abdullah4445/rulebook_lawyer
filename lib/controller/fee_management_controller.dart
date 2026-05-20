import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeeManagementController extends GetxController {
  final consultationFeeController = TextEditingController().obs;
  final hourlyRateController = TextEditingController().obs;

  final RxList<FeePackage> packages = <FeePackage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

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
        consultationFeeController.value.text =
            profile.consultationFee?.toString() ?? '';
        hourlyRateController.value.text = profile.hourlyRate?.toString() ?? '';
        packages.value = List<FeePackage>.from(profile.feePackages ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void addPackage() {
    packages.add(FeePackage(name: '', description: '', fee: 0));
  }

  void removePackage(int index) {
    if (index >= 0 && index < packages.length) {
      packages.removeAt(index);
    }
  }

  void updatePackage(int index, {String? name, String? description, double? fee}) {
    if (index < 0 || index >= packages.length) return;
    final p = packages[index];
    if (name != null) p.name = name;
    if (description != null) p.description = description;
    if (fee != null) p.fee = fee;
    packages.refresh();
  }

  Future<bool> save() async {
    isSaving.value = true;
    try {
      final m = driverModel.value;
      m.consultationFee =
          double.tryParse(consultationFeeController.value.text.trim());
      m.hourlyRate = double.tryParse(hourlyRateController.value.text.trim());
      m.feePackages = packages
          .where((p) => (p.name ?? '').trim().isNotEmpty)
          .map((p) => FeePackage(
                name: p.name?.trim(),
                description: p.description?.trim(),
                fee: p.fee,
              ))
          .toList();

      // Persist via the existing helper.
      await FirebaseFirestore.instance
          .collection(CollectionName.driverUsers)
          .doc(m.id)
          .set(m.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('FeeManagement save failed: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
