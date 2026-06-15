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

  // ─── Court jurisdiction (admin-managed country/province/cities) ───
  /// ISO 3166-1 alpha-2 of the country the lawyer practices in (e.g. "PK").
  String? countryIso;
  /// The single province / state / capital territory.
  String? province;
  /// Cities within [province] the lawyer is willing to take cases from.
  /// City names act as IDs in Firestore docs.
  List<String>? cityIds;

  // ─── Lawyer professional credentials (Phase 6 — additive, all nullable) ───
  /// License level: 'advocate' | 'advocate_hc' | 'advocate_sc'
  /// Determines jurisdiction zone automatically.
  String? licenseType;
  /// Local Bar Association name (e.g. "Lahore Bar Association")
  String? barAssociation;
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
  /// Short bio / about-me — pitched to clients on the lawyer profile.
  String? bio;
  /// Per-consultation flat fee (in the platform currency)
  double? consultationFee;
  /// Hourly billing rate (in the platform currency)
  double? hourlyRate;
  /// Pre-set service packages (e.g. "Divorce Khula — Rs 50,000")
  List<FeePackage>? feePackages;
  /// Saved canned chat replies for fast responses (Phase 2.6).
  List<ReplyTemplate>? replyTemplates;

  // ─── Identity verification documents (Firebase Storage URLs) ───
  String? cnicFrontUrl;
  String? cnicBackUrl;
  String? barCardFrontUrl;
  String? barCardBackUrl;
  /// Lawyer holding the Bar Council Card next to their face — anti-fraud
  String? selfieWithCardUrl;
  /// 'pending' | 'approved' | 'rejected' — null means never submitted
  String? verificationStatus;
  /// Admin-supplied reason when [verificationStatus] == 'rejected'
  String? rejectionReason;
  /// When the lawyer last submitted (or resubmitted) their documents
  Timestamp? documentsSubmittedAt;


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
      this.countryIso,
      this.province,
      this.cityIds,
      this.licenseType,
      this.barAssociation,
      this.barCouncilId,
      this.barRegistrationDate,
      this.practiceYears,
      this.qualification,
      this.officeAddress,
      this.bio,
      this.consultationFee,
      this.hourlyRate,
      this.feePackages,
      this.replyTemplates,
      this.cnicFrontUrl,
      this.cnicBackUrl,
      this.barCardFrontUrl,
      this.barCardBackUrl,
      this.selfieWithCardUrl,
      this.verificationStatus,
      this.rejectionReason,
      this.documentsSubmittedAt,
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

    // Court jurisdiction
    countryIso = json['countryIso'] as String?;
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
    licenseType = json['licenseType'] as String?;
    barAssociation = json['barAssociation'] as String?;
    barCouncilId = json['barCouncilId'] as String?;
    barRegistrationDate = json['barRegistrationDate'] as Timestamp?;
    practiceYears = (json['practiceYears'] is int)
        ? json['practiceYears'] as int
        : (json['practiceYears'] != null
            ? int.tryParse(json['practiceYears'].toString())
            : null);
    qualification = json['qualification'] as String?;
    officeAddress = json['officeAddress'] as String?;
    bio = json['bio'] as String?;
    consultationFee = (json['consultationFee'] != null)
        ? double.tryParse(json['consultationFee'].toString())
        : null;
    hourlyRate = (json['hourlyRate'] != null)
        ? double.tryParse(json['hourlyRate'].toString())
        : null;
    if (json['feePackages'] is List) {
      feePackages = (json['feePackages'] as List)
          .whereType<Map>()
          .map((m) => FeePackage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    if (json['replyTemplates'] is List) {
      replyTemplates = (json['replyTemplates'] as List)
          .whereType<Map>()
          .map((m) => ReplyTemplate.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // Identity documents
    cnicFrontUrl = json['cnicFrontUrl'] as String?;
    cnicBackUrl = json['cnicBackUrl'] as String?;
    barCardFrontUrl = json['barCardFrontUrl'] as String?;
    barCardBackUrl = json['barCardBackUrl'] as String?;
    selfieWithCardUrl = json['selfieWithCardUrl'] as String?;
    verificationStatus = json['verificationStatus'] as String?;
    rejectionReason = json['rejectionReason'] as String?;
    documentsSubmittedAt = json['documentsSubmittedAt'] as Timestamp?;
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
    // Court jurisdiction
    if (countryIso != null) data['countryIso'] = countryIso;
    if (province != null) data['province'] = province;
    if (cityIds != null) data['cityIds'] = cityIds;

    // Lawyer credentials — only persist non-null values to keep docs lean.
    if (licenseType != null) data['licenseType'] = licenseType;
    if (barAssociation != null) data['barAssociation'] = barAssociation;
    if (barCouncilId != null) data['barCouncilId'] = barCouncilId;
    if (barRegistrationDate != null) data['barRegistrationDate'] = barRegistrationDate;
    if (practiceYears != null) data['practiceYears'] = practiceYears;
    if (qualification != null) data['qualification'] = qualification;
    if (officeAddress != null) data['officeAddress'] = officeAddress;
    if (bio != null) data['bio'] = bio;
    if (consultationFee != null) data['consultationFee'] = consultationFee;
    if (hourlyRate != null) data['hourlyRate'] = hourlyRate;
    if (feePackages != null) {
      data['feePackages'] = feePackages!.map((p) => p.toJson()).toList();
    }
    if (replyTemplates != null) {
      data['replyTemplates'] =
          replyTemplates!.map((r) => r.toJson()).toList();
    }

    // Identity documents
    if (cnicFrontUrl != null) data['cnicFrontUrl'] = cnicFrontUrl;
    if (cnicBackUrl != null) data['cnicBackUrl'] = cnicBackUrl;
    if (barCardFrontUrl != null) data['barCardFrontUrl'] = barCardFrontUrl;
    if (barCardBackUrl != null) data['barCardBackUrl'] = barCardBackUrl;
    if (selfieWithCardUrl != null) data['selfieWithCardUrl'] = selfieWithCardUrl;
    if (verificationStatus != null) data['verificationStatus'] = verificationStatus;
    if (rejectionReason != null) data['rejectionReason'] = rejectionReason;
    if (documentsSubmittedAt != null) data['documentsSubmittedAt'] = documentsSubmittedAt;
    return data;
  }
}

/// A saved canned chat reply the lawyer can tap to insert (Phase 2.6).
class ReplyTemplate {
  String? id;
  /// Short label shown in the picker (e.g. "Send document list").
  String? label;
  /// The actual message body that gets inserted into the chat input.
  String? body;

  ReplyTemplate({this.id, this.label, this.body});

  ReplyTemplate.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    label = json['label'] as String?;
    body = json['body'] as String?;
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (label != null) 'label': label,
        if (body != null) 'body': body,
      };
}

/// Pre-set service package a lawyer offers (e.g. "Divorce Khula — Rs 50,000").
class FeePackage {
  String? name;
  String? description;
  double? fee;

  FeePackage({this.name, this.description, this.fee});

  FeePackage.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    description = json['description'] as String?;
    fee = json['fee'] != null ? double.tryParse(json['fee'].toString()) : null;
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (fee != null) 'fee': fee,
      };
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
