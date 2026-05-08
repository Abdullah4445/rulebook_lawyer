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

  getVehicleTye() async {
    await FireStoreUtils.getService().then((value) {
      serviceList.value = value;
    });

    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        zoneList.value = value;
      }
    });

    // Be resilient to brand-new lawyers who have authenticated but haven't yet
    // completed their profile in Firestore — getDriverProfile may return null.
    final profile = await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid());
    if (profile != null) {
      driverModel.value = profile;
    } else {
      // First-time visit — keep the empty model and stamp the auth uid so
      // the eventual updateDriverUser writes against the right document.
      driverModel.value.id = FireStoreUtils.getCurrentUid();
    }

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
    }

    if (driverModel.value.zoneIds != null) {
      for (var element in driverModel.value.zoneIds!) {
        List<ZoneModel> list = zoneList.where((p0) => p0.id == element).toList();
        if (list.isNotEmpty) {
          selectedZone.add(element);
          zoneString.value =
              "$zoneString${zoneString.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
        }
      }
      zoneNameController.value.text = zoneString.value;
    }

    // Hydrate multi-select state from the loaded profile (handles both new
    // serviceIds list and legacy single serviceId docs).
    final existingIds = driverModel.value.serviceIds;
    if (existingIds != null && existingIds.isNotEmpty) {
      selectedServiceIds.assignAll(existingIds);
    } else if (driverModel.value.serviceId != null &&
        driverModel.value.serviceId!.isNotEmpty) {
      selectedServiceIds.add(driverModel.value.serviceId!);
    }
    selectedServiceId.value =
        selectedServiceIds.isEmpty ? null : selectedServiceIds.first;
    await FireStoreUtils.getVehicleType().then((value) {
      vehicleList = value!;
      if (driverModel.value.vehicleInformation != null) {
        for (var element in vehicleList) {
          if (element.id == driverModel.value.vehicleInformation!.vehicleTypeId) {
            selectedVehicle.value = element;
          }
        }
      }
    });

    await FireStoreUtils.getDriverRules().then((value) {
      if (value != null) {
        driverRulesList.value = value;
        if (driverModel.value.vehicleInformation != null) {
          if (driverModel.value.vehicleInformation!.driverRules != null) {
            for (var element in driverModel.value.vehicleInformation!.driverRules!) {
              selectedDriverRulesList.add(element);
            }
          }
        }
      }
    });
    isLoading.value = false;
    update();
  }
}
