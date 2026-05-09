import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/driver_rules_model.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/service_model.dart';
import 'package:lawyer/model/vehicle_type_model.dart';
import 'package:lawyer/model/zone_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehicleInformationController extends GetxController {
  Rx<TextEditingController> vehicleNumberController = TextEditingController().obs;
  Rx<TextEditingController> seatsController = TextEditingController().obs;
  Rx<TextEditingController> registrationDateController = TextEditingController().obs;
  Rx<TextEditingController> driverRulesController = TextEditingController().obs;
  Rx<TextEditingController> zoneNameController = TextEditingController().obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxBool isLoading = true.obs;

  Rx<String> selectedColor = "".obs;
  List<String> carColorList = <String>['Red', 'Black', 'White', 'Blue', 'Green', 'Orange', 'Silver', 'Gray', 'Yellow', 'Brown', 'Gold', 'Beige', 'Purple'].obs;
  List<String> sheetList = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getVehicleTye();
    super.onInit();
  }

  List<VehicleTypeModel> vehicleList = <VehicleTypeModel>[].obs;
  Rx<VehicleTypeModel> selectedVehicle = VehicleTypeModel().obs;
  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxList<DriverRulesModel> driverRulesList = <DriverRulesModel>[].obs;
  RxList<DriverRulesModel> selectedDriverRulesList = <DriverRulesModel>[].obs;

  RxList<ServiceModel> serviceList = <ServiceModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  RxList selectedZone = <String>[].obs;

  /// Legacy: kept as the first item of [selectedServiceIds] for compatibility
  /// with any code that still reads a single value.
  Rx<String?> selectedServiceId = "".obs;
  /// All categories the lawyer is an expert in.
  RxList<String> selectedServiceIds = <String>[].obs;
  RxString zoneString = "".obs;

  // ─── Pakistan jurisdiction state ───
  /// Currently selected province (single).
  Rx<String?> selectedProvince = Rx<String?>(null);
  /// Cities within [selectedProvince] the lawyer covers (multi).
  RxList<String> selectedCities = <String>[].obs;

  bool isServiceSelected(String? id) =>
      id != null && selectedServiceIds.contains(id);

  void toggleService(String? id) {
    if (id == null || id.isEmpty) return;
    if (selectedServiceIds.contains(id)) {
      selectedServiceIds.remove(id);
    } else {
      selectedServiceIds.add(id);
    }
    selectedServiceId.value =
        selectedServiceIds.isEmpty ? null : selectedServiceIds.first;
  }

  /// Switch province. Clears any city selection that doesn't belong
  /// to the new province (cities are scoped per-province by design).
  void setProvince(String? province) {
    if (selectedProvince.value == province) return;
    selectedProvince.value = province;
    selectedCities.clear();
  }

  bool isCitySelected(String city) => selectedCities.contains(city);

  void toggleCity(String city) {
    if (city.isEmpty) return;
    if (selectedCities.contains(city)) {
      selectedCities.remove(city);
    } else {
      selectedCities.add(city);
    }
  }

  getVehicleTye() async {
    // Each Firestore call is wrapped + timed out so a single hung query can
    // never trap the screen on the loader. Whatever happens, the `finally`
    // block at the bottom guarantees `isLoading.value = false`.
    try {
      await Future.wait<void>([
        // Services (legal categories)
        FireStoreUtils.getService()
            .then((value) {
          serviceList.value = value;
        }).catchError((e, s) {
          debugPrint('getService failed: $e');
        }).timeout(const Duration(seconds: 15), onTimeout: () {
          debugPrint('getService timed out — continuing with empty list');
        }),
        // Zones / jurisdictions
        FireStoreUtils.getZone()
            .then((value) {
          if (value != null) zoneList.value = value;
        }).catchError((e, s) {
          debugPrint('getZone failed: $e');
        }).timeout(const Duration(seconds: 15), onTimeout: () {
          debugPrint('getZone timed out — continuing with empty list');
        }),
        // Vehicle / court-of-practice types
        FireStoreUtils.getVehicleType()
            .then((value) {
          if (value != null) vehicleList = value;
        }).catchError((e, s) {
          debugPrint('getVehicleType failed: $e');
        }).timeout(const Duration(seconds: 15), onTimeout: () {
          debugPrint('getVehicleType timed out — continuing with empty list');
        }),
        // Driver rules / code of conduct
        FireStoreUtils.getDriverRules()
            .then((value) {
          if (value != null) driverRulesList.value = value;
        }).catchError((e, s) {
          debugPrint('getDriverRules failed: $e');
        }).timeout(const Duration(seconds: 15), onTimeout: () {
          debugPrint('getDriverRules timed out — continuing with empty list');
        }),
      ]);

      // Lawyer profile fetch — null-safe, never crashes.
      try {
        final profile = await FireStoreUtils.getDriverProfile(
                FireStoreUtils.getCurrentUid())
            .timeout(const Duration(seconds: 15));
        if (profile != null) {
          driverModel.value = profile;
        } else {
          driverModel.value.id = FireStoreUtils.getCurrentUid();
        }
      } catch (e) {
        debugPrint('getDriverProfile failed/timed out: $e');
        driverModel.value.id = FireStoreUtils.getCurrentUid();
      }

      // Hydrate vehicle/credential fields if present
      if (driverModel.value.vehicleInformation != null) {
        final v = driverModel.value.vehicleInformation!;
        vehicleNumberController.value.text = v.vehicleNumber?.toString() ?? '';
        if (v.registrationDate != null) {
          selectedDate.value = v.registrationDate!.toDate();
          registrationDateController.value.text =
              DateFormat("dd-MM-yyyy").format(selectedDate.value!);
        }
        selectedColor.value = v.vehicleColor?.toString() ?? '';
        seatsController.value.text = v.seats ?? '2';

        // Match selected vehicle/court-of-practice from loaded list
        for (var element in vehicleList) {
          if (element.id == v.vehicleTypeId) {
            selectedVehicle.value = element;
          }
        }
        // Hydrate selected driver rules
        if (v.driverRules != null) {
          for (var element in v.driverRules!) {
            selectedDriverRulesList.add(element);
          }
        }
      }

      // Hydrate selected zones
      if (driverModel.value.zoneIds != null) {
        for (var element in driverModel.value.zoneIds!) {
          final list =
              zoneList.where((p0) => p0.id == element).toList();
          if (list.isNotEmpty) {
            selectedZone.add(element);
            zoneString.value =
                "$zoneString${zoneString.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
          }
        }
        zoneNameController.value.text = zoneString.value;
      }

      // Hydrate multi-specialty selection
      final existingIds = driverModel.value.serviceIds;
      if (existingIds != null && existingIds.isNotEmpty) {
        selectedServiceIds.assignAll(existingIds);
      } else if (driverModel.value.serviceId != null &&
          driverModel.value.serviceId!.isNotEmpty) {
        selectedServiceIds.add(driverModel.value.serviceId!);
      }
      selectedServiceId.value =
          selectedServiceIds.isEmpty ? null : selectedServiceIds.first;

      // Hydrate Pakistan jurisdiction (province + cities)
      if (driverModel.value.province != null &&
          driverModel.value.province!.isNotEmpty) {
        selectedProvince.value = driverModel.value.province;
      }
      if (driverModel.value.cityIds != null &&
          driverModel.value.cityIds!.isNotEmpty) {
        selectedCities.assignAll(driverModel.value.cityIds!);
      }
    } catch (e, s) {
      // Catch-all so we still drop the loader.
      debugPrint('getVehicleTye unexpected error: $e\n$s');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
