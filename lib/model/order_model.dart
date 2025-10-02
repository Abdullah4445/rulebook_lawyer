import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/admin_commission.dart';
import 'package:driver/model/contact_model.dart';
import 'package:driver/model/coupon_model.dart';
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/order/positions.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/tax_model.dart';
import 'package:driver/model/zone_model.dart';

class OrderModel {
  String? sourceLocationName;
  String? destinationLocationName;
  String? paymentType;
  LocationLatLng? sourceLocationLatLng;
  LocationLatLng? destinationLocationLatLng;
  String? id;
  String? serviceId;
  String? userId;
  String? offerRate;
  String? finalRate;
  String? distance;
  String? distanceType;
  String? status;
  String? driverId;
  String? otp;
  List<dynamic>? acceptedDriverId;
  List<dynamic>? rejectedDriverId;
  Positions? position;
  Timestamp? createdDate;
  Timestamp? updateDate;
  bool? paymentStatus;
  List<TaxModel>? taxList;
  ContactModel? someOneElse;
  CouponModel? coupon;
  ServiceModel? service;
  AdminCommission? adminCommission;
  ZoneModel? zone;
  String? zoneId;

  /// 🔥 New fields for live tracking and taxi meter
  GeoPoint? driverLocation;
  bool? customerIsWatchingLiveTracking;
  bool? notifyUserIfDriverIsNotMovingEvenRideActive;

  // Meter status and tracking fields
  String? meterStatus; // "on", "off", "paused"
  double? meterFare; // live fare calculated in real-time
  Timestamp? startMeterTime; // when meter was turned on
  LocationLatLng? meterStartLocation; // where the meter started
  Map<String, dynamic>? meterRate; // rates for the taxi meter (base fare, per km, etc.)
  Map<String, dynamic>?
      meterTracking; // live tracking data for fare calculation (distance, time, etc.)

  OrderModel({
    this.position,
    this.serviceId,
    this.paymentType,
    this.sourceLocationName,
    this.destinationLocationName,
    this.sourceLocationLatLng,
    this.destinationLocationLatLng,
    this.id,
    this.userId,
    this.distance,
    this.distanceType,
    this.status,
    this.driverId,
    this.otp,
    this.offerRate,
    this.finalRate,
    this.paymentStatus,
    this.createdDate,
    this.updateDate,
    this.taxList,
    this.coupon,
    this.someOneElse,
    this.service,
    this.adminCommission,
    this.zone,
    this.zoneId,
    this.driverLocation,
    this.customerIsWatchingLiveTracking,
    this.notifyUserIfDriverIsNotMovingEvenRideActive,
    this.meterStatus,
    this.meterFare,
    this.startMeterTime,
    this.meterStartLocation,
    this.meterRate,
    this.meterTracking,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    serviceId = json['serviceId'];
    sourceLocationName = json['sourceLocationName'];
    destinationLocationName = json['destinationLocationName'];
    paymentType = json['paymentType'];
    final srcRaw = json['sourceLocationLatLng'];
    if (srcRaw != null) {
      if (srcRaw is GeoPoint) {
        sourceLocationLatLng = LocationLatLng(
          latitude: srcRaw.latitude,
          longitude: srcRaw.longitude,
        );
      } else if (srcRaw is Map) {
        sourceLocationLatLng = LocationLatLng(
          latitude: srcRaw['latitude']?.toDouble() ?? 0.0,
          longitude: srcRaw['longitude']?.toDouble() ?? 0.0,
        );
      }
    }

    final desRaw = json['destinationLocationLatLng'];
    if (desRaw != null) {
      if (desRaw is GeoPoint) {
        destinationLocationLatLng = LocationLatLng(
          latitude: desRaw.latitude,
          longitude: desRaw.longitude,
        );
      } else if (desRaw is Map) {
        destinationLocationLatLng = LocationLatLng(
          latitude: desRaw['latitude']?.toDouble() ?? 0.0,
          longitude: desRaw['longitude']?.toDouble() ?? 0.0,
        );
      }
    }
    coupon = json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
    someOneElse =
        json['someOneElse'] != null ? ContactModel.fromJson(json['someOneElse']) : null;
    id = json['id'];
    userId = json['userId'];
    offerRate = json['offerRate'];
    finalRate = json['finalRate'];
    distance = json['distance'];
    distanceType = json['distanceType'];
    status = json['status'];
    driverId = json['driverId'];
    otp = json['otp'];
    createdDate = json['createdDate'];
    updateDate = json['updateDate'];
    acceptedDriverId = json['acceptedDriverId'];
    rejectedDriverId = json['rejectedDriverId'];
    paymentStatus = json['paymentStatus'];
    position = json['position'] != null ? Positions.fromJson(json['position']) : null;
    service = json['service'] != null ? ServiceModel.fromJson(json['service']) : null;
    adminCommission = json['adminCommission'] != null
        ? AdminCommission.fromJson(json['adminCommission'])
        : null;
    zone = json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null;
    zoneId = json['zoneId'];

    // 🔥 New fields
    final dLoc = json['driverLocation'];
    if (dLoc is GeoPoint) {
      driverLocation = dLoc;
    } else if (dLoc is Map<String, dynamic>) {
      driverLocation = GeoPoint(
        dLoc['latitude']?.toDouble() ?? 0.0,
        dLoc['longitude']?.toDouble() ?? 0.0,
      );
    }
    customerIsWatchingLiveTracking = json['customerIsWatchingLiveTracking'];
    notifyUserIfDriverIsNotMovingEvenRideActive =
        json['notifyUserIfDriverIsNotMovingEvenRideActive'];

    meterStatus = json['meterStatus'];
    meterFare = json['meterFare']?.toDouble();
    startMeterTime = json['startMeterTime'];
    meterStartLocation = json['meterStartLocation'] != null
        ? LocationLatLng.fromJson(json['meterStartLocation'])
        : null;
    meterRate =
        json['meterRate'] != null ? Map<String, dynamic>.from(json['meterRate']) : null;
    meterTracking = json['meterTracking'] != null
        ? Map<String, dynamic>.from(json['meterTracking'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceId'] = serviceId;
    data['sourceLocationName'] = sourceLocationName;
    data['destinationLocationName'] = destinationLocationName;
    if (sourceLocationLatLng != null) {
      data['sourceLocationLatLng'] = sourceLocationLatLng!.toJson();
    }
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    if (someOneElse != null) {
      data['someOneElse'] = someOneElse!.toJson();
    }
    if (destinationLocationLatLng != null) {
      data['destinationLocationLatLng'] = destinationLocationLatLng!.toJson();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    if (zone != null) {
      data['zone'] = zone!.toJson();
    }
    data['zoneId'] = zoneId;
    data['id'] = id;
    data['userId'] = userId;
    data['paymentType'] = paymentType;
    data['offerRate'] = offerRate;
    data['finalRate'] = finalRate;
    data['distance'] = distance;
    data['distanceType'] = distanceType;
    data['status'] = status;
    data['driverId'] = driverId;
    data['otp'] = otp;
    data['createdDate'] = createdDate;
    data['updateDate'] = updateDate;
    data['acceptedDriverId'] = acceptedDriverId;
    data['rejectedDriverId'] = rejectedDriverId;
    data['paymentStatus'] = paymentStatus;

    if (taxList != null) {
      data['taxList'] = taxList!.map((v) => v.toJson()).toList();
    }
    if (position != null) {
      data['position'] = position!.toJson();
    }

    // 🔥 New fields
    if (driverLocation != null) {
      data['driverLocation'] = {
        'latitude': driverLocation!.latitude,
        'longitude': driverLocation!.longitude,
      };
    }
    data['customerIsWatchingLiveTracking'] = customerIsWatchingLiveTracking;
    data['notifyUserIfDriverIsNotMovingEvenRideActive'] =
        notifyUserIfDriverIsNotMovingEvenRideActive;
    data['meterStatus'] = meterStatus;
    data['meterFare'] = meterFare;
    if (meterStartLocation != null) {
      data['meterStartLocation'] = meterStartLocation!.toJson();
    }
    if (meterRate != null) {
      data['meterRate'] = meterRate;
    }
    if (meterTracking != null) {
      data['meterTracking'] = meterTracking;
    }
    return data;
  }
}
