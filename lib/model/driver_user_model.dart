import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/model/admin_commission.dart';
import 'package:lawyer/model/driver_rules_model.dart';
import 'package:lawyer/model/language_name.dart';
import 'package:lawyer/model/order/location_lat_lng.dart';
import 'package:lawyer/model/order/positions.dart';
import 'package:lawyer/model/subscription_plan_model.dart';

class DriverUserModel {
  String? phoneNumber;
  String? loginType;
  String? countryCode;
  String? profilePic;
  bool? documentVerification;
  String? fullName;
  bool? isOnline;
  String? id;
  /// Legacy single service id — kept in sync with the first item of [serviceIds]
  /// for backwards compatibility with documents that haven't been migrated yet
  /// and with downstream code that still reads a single value.
  String? serviceId;
  /// All categories the lawyer is an expert in. Source of truth for matching.
  List<String>? serviceIds;
  String? fcmToken;
  String? email;
  VehicleInformation? vehicleInformation;
  String? reviewsCount;
  String? reviewsSum;
  String? walletAmount;
  LocationLatLng? location;
  double? rotation;
  Positions? position;
  Timestamp? createdAt;
  List<dynamic>? zoneIds;
  String? subscriptionTotalOrders;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;

  // ─── Pakistan court jurisdiction (province + cities) ───
  /// The single province / capital territory the lawyer practices in.
  /// One of: Punjab, Sindh, Khyber Pakhtunkhwa, Balochistan,
  /// Islamabad Capital Territory, Azad Jammu & Kashmir, Gilgit-Baltistan.
  String? province;
  /// Cities within [province] the lawyer is willing to take cases from.
  /// City names act as IDs — see PakistanJurisdictions.
  List<String>? cityIds;

  // ─── Lawyer professional credentials (Phase 6 — additive, all nullable) ───
  /// Bar Council registration number (e.g. PBC-12345)
  String? barCouncilId;
  /// Date the lawyer was admitted to the bar
  Timestamp? barRegistrationDate;
  /// Years of legal practice — independent of the legacy `seats` field
  int? practiceYears;
  /// Highest legal qualification (LLB, LLM, etc.)
  String? qualification;
  /// Office / chamber address
  String? officeAddress;
  /// Per-consultation flat fee (in the platform currency)
  double? consultationFee;
  /// Hourly billing rate (in the platform currency)
  double? hourlyRate;


  DriverUserModel(
      {this.phoneNumber,
      this.loginType,
      this.countryCode,
      this.profilePic,
      this.documentVerification,
      this.fullName,
      this.isOnline,
      this.id,
      this.serviceId,
      this.serviceIds,
      this.province,
      this.cityIds,
      this.barCouncilId,
      this.barRegistrationDate,
      this.practiceYears,
      this.qualification,
      this.officeAddress,
      this.consultationFee,
      this.hourlyRate,
      this.fcmToken,
      this.email,
      this.location,
      this.vehicleInformation,
      this.reviewsCount,
      this.reviewsSum,
      this.rotation,
      this.position,
      this.walletAmount,
      this.createdAt,
      this.zoneIds,
      this.subscriptionTotalOrders,
      this.subscriptionPlanId,
        this.subscriptionExpiryDate,
        this.subscriptionPlan});

  DriverUserModel.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'];
    loginType = json['loginType'];
    countryCode = json['countryCode'];
    profilePic = json['profilePic'] ?? '';
    documentVerification = json['documentVerification'];
    fullName = json['fullName'];
    isOnline = json['isOnline'];
    id = json['id'];
    serviceId = json['serviceId'];
    if (json['serviceIds'] is List) {
      serviceIds = (json['serviceIds'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (serviceId != null && serviceId!.isNotEmpty) {
      // Legacy doc with only the single field — promote it to the list.
      serviceIds = [serviceId!];
    } else {
      serviceIds = [];
    }
    fcmToken = json['fcmToken'];
    email = json['email'];
    vehicleInformation = json['vehicleInformation'] != null ? VehicleInformation.fromJson(json['vehicleInformation']) : null;
    reviewsCount = json['reviewsCount'] ?? '0.0';
    reviewsSum = json['reviewsSum'] ?? '0.0';
    rotation = json['rotation'];
    walletAmount = json['walletAmount'] ?? "0.0";
    location = json['location'] != null ? LocationLatLng.fromJson(json['location']) : null;
    position = json['position'] != null ? Positions.fromJson(json['position']) : null;
    createdAt = json['createdAt'];
    zoneIds = json['zoneIds'];
    subscriptionTotalOrders = json['subscriptionTotalOrders'];
    subscriptionPlanId = json['subscriptionPlanId'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    subscriptionPlan = json['subscription_plan'] != null ? SubscriptionPlanModel.fromJson(json['subscription_plan']) : null;

    // Pakistan jurisdiction
    province = json['province'] as String?;
    if (json['cityIds'] is List) {
      cityIds = (json['cityIds'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      cityIds = null;
    }

    // Lawyer credentials (all nullable — older docs simply won't have these)
    barCouncilId = json['barCouncilId'] as String?;
    barRegistrationDate = json['barRegistrationDate'] as Timestamp?;
    practiceYears = (json['practiceYears'] is int)
        ? json['practiceYears'] as int
        : (json['practiceYears'] != null
            ? int.tryParse(json['practiceYears'].toString())
            : null);
    qualification = json['qualification'] as String?;
    officeAddress = json['officeAddress'] as String?;
    consultationFee = (json['consultationFee'] != null)
        ? double.tryParse(json['consultationFee'].toString())
        : null;
    hourlyRate = (json['hourlyRate'] != null)
        ? double.tryParse(json['hourlyRate'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneNumber'] = phoneNumber;
    data['loginType'] = loginType;
    data['countryCode'] = countryCode;
    data['profilePic'] = profilePic;
    data['documentVerification'] = documentVerification;
    data['fullName'] = fullName;
    data['isOnline'] = isOnline;
    data['id'] = id;
    // Keep legacy single field in sync with the first specialty so old code
    // and unmigrated queries continue to work.
    final List<String> normalisedIds =
        (serviceIds ?? const <String>[]).where((e) => e.isNotEmpty).toList();
    data['serviceIds'] = normalisedIds;
    data['serviceId'] =
        normalisedIds.isNotEmpty ? normalisedIds.first : serviceId;
    data['fcmToken'] = fcmToken;
    data['email'] = email;
    data['rotation'] = rotation;
    data['createdAt'] = createdAt;
    if (vehicleInformation != null) {
      data['vehicleInformation'] = vehicleInformation!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    data['walletAmount'] = walletAmount;
    data['zoneIds'] = zoneIds;
    if (position != null) {
      data['position'] = position!.toJson();
    }
    data['subscriptionTotalOrders'] = subscriptionTotalOrders;
    data['subscriptionPlanId'] = subscriptionPlanId;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    data['subscription_plan'] = subscriptionPlan?.toJson();
    // Pakistan jurisdiction
    if (province != null) data['province'] = province;
    if (cityIds != null) data['cityIds'] = cityIds;

    // Lawyer credentials — only persist non-null values to keep docs lean.
    if (barCouncilId != null) data['barCouncilId'] = barCouncilId;
    if (barRegistrationDate != null) data['barRegistrationDate'] = barRegistrationDate;
    if (practiceYears != null) data['practiceYears'] = practiceYears;
    if (qualification != null) data['qualification'] = qualification;
    if (officeAddress != null) data['officeAddress'] = officeAddress;
    if (consultationFee != null) data['consultationFee'] = consultationFee;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
    return data;
  }
}

class VehicleInformation {
  List<LanguageName>? vehicleType;
  String? vehicleTypeId;
  Timestamp? registrationDate;
  String? vehicleColor;
  String? vehicleNumber;
  String? seats;
  List<DriverRulesModel>? driverRules;

  VehicleInformation({this.vehicleType, this.vehicleTypeId, this.registrationDate, this.vehicleColor, this.vehicleNumber, this.seats, this.driverRules});

  VehicleInformation.fromJson(Map<String, dynamic> json) {
    if (json['vehicleType'] != null) {
      vehicleType = <LanguageName>[];
      json['vehicleType'].forEach((v) {
        vehicleType!.add(LanguageName.fromJson(v));
      });
    }
    vehicleTypeId = json['vehicleTypeId'];
    registrationDate = json['registrationDate'];
    vehicleColor = json['vehicleColor'];
    vehicleNumber = json['vehicleNumber'];
    seats = json['seats'];
    if (json['driverRules'] != null) {
      driverRules = <DriverRulesModel>[];
      json['driverRules'].forEach((v) {
        driverRules!.add(DriverRulesModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vehicleType != null) {
      data['vehicleType'] = vehicleType!.map((v) => v.toJson()).toList();
    }
    data['vehicleTypeId'] = vehicleTypeId;
    data['registrationDate'] = registrationDate;
    data['vehicleColor'] = vehicleColor;
    data['vehicleNumber'] = vehicleNumber;
    data['seats'] = seats;
    if (driverRules != null) {
      data['driverRules'] = driverRules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
