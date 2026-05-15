import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/model/driver_rules_model.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/jurisdiction_models.dart';
import 'package:lawyer/model/service_model.dart';
import 'package:lawyer/model/vehicle_type_model.dart';
import 'package:lawyer/model/zone_model.dart';
import 'package:lawyer/services/jurisdiction_service.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class VehicleInformationController extends GetxController {
  Rx<TextEditingController> vehicleNumberController = TextEditingController().obs;
  Rx<TextEditingController> seatsController = TextEditingController().obs;
  Rx<TextEditingController> registrationDateController = TextEditingController().obs;
  Rx<TextEditingController> driverRulesController = TextEditingController().obs;
  Rx<TextEditingController> zoneNameController = TextEditingController().obs;
  Rx<TextEditingController> qualificationController = TextEditingController().obs;
  Rx<TextEditingController> officeAddressController = TextEditingController().obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  // Lawyer professional credentials
  RxString licenseType = "".obs;
  RxString barAssociation = "".obs;

  // Certificate image for OCR auto-verification
  Rx<File?> certificateFile = Rx<File?>(null);
  RxBool isVerifying = false.obs;

  // Snapshot of credentials at load time — used to detect changes that need re-verification
  String _originalLicenseType = '';
  String _originalBarCouncilId = '';

  bool get credentialsChanged =>
      licenseType.value != _originalLicenseType ||
      vehicleNumberController.value.text != _originalBarCouncilId;

  // ── Certificate image picker ──────────────────────────────────────────────
  Future<void> pickCertificateImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (picked != null) {
      certificateFile.value = File(picked.path);
    }
  }

  Future<void> pickCertificateCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (picked != null) {
      certificateFile.value = File(picked.path);
    }
  }

  // ── Auto-verify via Laravel OCR endpoint ─────────────────────────────────
  /// Returns: 'verified' | 'pending' | 'rejected' | 'error'
  Future<String> verifyCredentialsWithOcr() async {
    final file = certificateFile.value;
    final barId = vehicleNumberController.value.text.trim();
    final uid   = FirebaseAuth.instance.currentUser?.uid ?? driverModel.value.id ?? '';
    final name  = driverModel.value.fullName ?? '';

    if (file == null || barId.isEmpty || uid.isEmpty) return 'error';

    isVerifying.value = true;
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return 'error';

      final uri     = Uri.parse('${Constant.globalUrl}api/verify-lawyer-credentials');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $idToken'
        ..fields['bar_council_id'] = barId
        ..fields['full_name']      = name
        ..fields['driver_uid']     = uid
        ..files.add(await http.MultipartFile.fromPath(
            'certificate', file.path,
            contentType: MediaType('image', 'jpeg')));

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final body   = response.body;
        if (body.contains('"status":"verified"')) return 'verified';
        if (body.contains('"status":"pending"'))  return 'pending';
        return 'rejected';
      }
      return 'error';
    } catch (_) {
      return 'error';
    } finally {
      isVerifying.value = false;
    }
  }

  static const List<Map<String, String>> licenseOptions = [
    {'value': 'advocate',    'label': 'Advocate (District / Lower Courts)'},
    {'value': 'advocate_hc', 'label': 'Advocate High Court (Province)'},
    {'value': 'advocate_sc', 'label': 'Advocate Supreme Court (National)'},
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

  // ─── Jurisdiction state (admin-managed: country → province → cities) ───
  /// Full hierarchy fetched from /api/jurisdictions.
  RxList<JurisdictionCountry> countries = <JurisdictionCountry>[].obs;
  /// Whether the jurisdictions network call is currently in flight.
  RxBool isLoadingJurisdictions = false.obs;
  /// Last error from the jurisdictions fetch (null when last fetch succeeded).
  RxnString jurisdictionsError = RxnString();
  /// Currently selected country ISO code (single).
  Rx<String?> selectedCountryIso = Rx<String?>(null);
  /// Currently selected province (single, scoped to selected country).
  Rx<String?> selectedProvince = Rx<String?>(null);
  /// Cities within [selectedProvince] the lawyer covers (multi).
  RxList<String> selectedCities = <String>[].obs;

  /// Re-fetches the country/province/city catalog. Bound to a Retry
  /// button in the info screen when the previous load failed (e.g. the
  /// admin server's LAN IP changed).
  Future<void> reloadJurisdictions() async {
    isLoadingJurisdictions.value = true;
    jurisdictionsError.value = null;
    try {
      final list = await JurisdictionService.instance
          .getCountries(forceRefresh: true)
          .timeout(const Duration(seconds: 15));
      countries.assignAll(list);
      if (list.isEmpty) {
        jurisdictionsError.value =
            'Could not load countries. Check that the admin server is reachable.';
      }
    } catch (e) {
      jurisdictionsError.value =
          'Failed to load jurisdictions: $e. Pull to retry once the admin server is reachable.';
    } finally {
      isLoadingJurisdictions.value = false;
    }
  }

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

  /// Switch country. Clears province + cities (they're scoped per country).
  void setCountry(String? iso) {
    if (selectedCountryIso.value == iso) return;
    selectedCountryIso.value = iso;
    selectedProvince.value = null;
    selectedCities.clear();
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

  /// Lookup helpers for the UI.
  JurisdictionCountry? get currentCountry {
    final iso = selectedCountryIso.value;
    if (iso == null) return null;
    final found = countries.firstWhereOrNull((c) => c.iso == iso);
    return found;
  }

  List<JurisdictionProvince> get provincesForCurrentCountry =>
      currentCountry?.provinces ?? const [];

  JurisdictionProvince? get currentProvinceObject {
    final p = selectedProvince.value;
    if (p == null) return null;
    return provincesForCurrentCountry.firstWhereOrNull((x) => x.name == p);
  }

  List<JurisdictionCity> get citiesForCurrentProvince =>
      currentProvinceObject?.cities ?? const [];

  getVehicleTye() async {
    // Each Firestore call is wrapped + timed out so a single hung query can
    // never trap the screen on the loader. Whatever happens, the `finally`
    // block at the bottom guarantees `isLoading.value = false`.
    try {
      // Load jurisdictions (countries → provinces → cities) from admin API.
      // Awaited so the form reliably has the catalog ready before the user
      // taps the country dropdown. reloadJurisdictions handles its own
      // timeout and surfaces a user-visible error via jurisdictionsError.
      final jurisdictionsFuture = reloadJurisdictions();

      await Future.wait<void>([
        jurisdictionsFuture,
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

      // Hydrate jurisdiction (country / province / cities)
      // Default to Pakistan if the lawyer hasn't picked a country yet.
      if (driverModel.value.countryIso != null &&
          driverModel.value.countryIso!.isNotEmpty) {
        selectedCountryIso.value = driverModel.value.countryIso;
      } else if (countries.isNotEmpty) {
        selectedCountryIso.value = countries
            .firstWhere((c) => c.iso == 'PK', orElse: () => countries.first)
            .iso;
      }
      if (driverModel.value.province != null &&
          driverModel.value.province!.isNotEmpty) {
        selectedProvince.value = driverModel.value.province;
      }
      if (driverModel.value.cityIds != null &&
          driverModel.value.cityIds!.isNotEmpty) {
        selectedCities.assignAll(driverModel.value.cityIds!);
      }

      // Hydrate lawyer professional credentials
      if (driverModel.value.licenseType != null) {
        licenseType.value = driverModel.value.licenseType!;
      }
      if (driverModel.value.barAssociation != null) {
        barAssociation.value = driverModel.value.barAssociation!;
      }
      if (driverModel.value.qualification != null) {
        qualificationController.value.text = driverModel.value.qualification!;
      }
      if (driverModel.value.officeAddress != null) {
        officeAddressController.value.text = driverModel.value.officeAddress!;
      }
      // Snapshot for change detection
      _originalLicenseType = licenseType.value;
      _originalBarCouncilId = vehicleNumberController.value.text;
    } catch (e, s) {
      // Catch-all so we still drop the loader.
      debugPrint('getVehicleTye unexpected error: $e\n$s');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
