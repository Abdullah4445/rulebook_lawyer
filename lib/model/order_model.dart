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
  LocationLatLng? sourceLocationLAtLng;
  LocationLatLng? destinationLocationLAtLng;
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

  // ✅ New fields for live tracking logic
  GeoPoint? driverLocation;
  bool? notifyUserIfDriverIsNotMovingEvenRideActive;
  bool? customerIsWatchingLiveTracking;
  String? customerName;
  String? phoneNumber;

  OrderModel({
    this.position,
    this.serviceId,
    this.paymentType,
    this.sourceLocationName,
    this.destinationLocationName,
    this.sourceLocationLAtLng,
    this.destinationLocationLAtLng,
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
    this.notifyUserIfDriverIsNotMovingEvenRideActive,
    this.customerIsWatchingLiveTracking,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {

    print("DEBUG: Unmapped fields: ${json.keys.where((k) => ![
      'serviceId',
      'sourceLocationName',
      'destinationLocationName',
      'paymentType',
      'customerName',
      'phoneNumber',
      'sourceLocationLAtLng',
      'destinationLocationLAtLng',
      'coupon',
      'someOneElse',
      'id',
      'userId',
      'offerRate',
      'finalRate',
      'distance',
      'distanceType',
      'status',
      'driverId',
      'otp',
      'createdDate',
      'updateDate',
      'acceptedDriverId',
      'rejectedDriverId',
      'paymentStatus',
      'position',
      'service',
      'adminCommission',
      'zone',
      'zoneId',
      'driverLocation',
      'notifyUserIfDriverIsNotMovingEvenRideActive',
      'customerIsWatchingLiveTracking',
      'taxList',
    ].contains(k)).toList()}");



    serviceId = json['serviceId'];
    sourceLocationName = json['sourceLocationName'];
    destinationLocationName = json['destinationLocationName'];
    paymentType = json['paymentType'];

    customerName = json['customerName'];
    phoneNumber = json['phoneNumber'];

    sourceLocationLAtLng = json['sourceLocationLAtLng'] != null
        ? LocationLatLng(
      latitude: json['sourceLocationLAtLng']['latitude'],
      longitude:json['sourceLocationLAtLng']['longitude'],
    )
        : null;

    destinationLocationLAtLng = json['destinationLocationLatLng'] != null
        ? LocationLatLng(
      latitude: json['destinationLocationLAtLng']['latitude'],
      longitude: json['destinationLocationLAtLng']['longitude'],
    )
        : null;

    coupon = json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
    someOneElse = json['someOneElse'] != null ? ContactModel.fromJson(json['someOneElse']) : null;
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
    adminCommission = json['adminCommission'] != null ? AdminCommission.fromJson(json['adminCommission']) : null;
    zone = json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null;
    zoneId = json['zoneId'];

    // ✅ New fields
    driverLocation = json['driverLocation'];
    notifyUserIfDriverIsNotMovingEvenRideActive = json['notifyUserIfDriverIsNotMovingEvenRideActive'];
    customerIsWatchingLiveTracking = json['customerIsWatchingLiveTracking'];

    if (json['taxList'] != null) {
      taxList = <TaxModel>[];
      json['taxList'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['serviceId'] = serviceId;
    data['sourceLocationName'] = sourceLocationName;
    data['destinationLocationName'] = destinationLocationName;
    data['paymentType'] = paymentType;
    data['id'] = id;
    data['userId'] = userId;
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
    data['zoneId'] = zoneId;

    if (sourceLocationLAtLng != null) data['sourceLocationLAtLng'] = sourceLocationLAtLng!.toJson();
    if (destinationLocationLAtLng != null) data['destinationLocationLAtLng'] = destinationLocationLAtLng!.toJson();
    if (coupon != null) data['coupon'] = coupon!.toJson();
    if (someOneElse != null) data['someOneElse'] = someOneElse!.toJson();
    if (service != null) data['service'] = service!.toJson();
    if (adminCommission != null) data['adminCommission'] = adminCommission!.toJson();
    if (zone != null) data['zone'] = zone!.toJson();
    if (taxList != null) data['taxList'] = taxList!.map((v) => v.toJson()).toList();
    if (position != null) data['position'] = position!.toJson();

    // ✅ Add new fields
    if (driverLocation != null) data['driverLocation'] = driverLocation;
    if (notifyUserIfDriverIsNotMovingEvenRideActive != null) {
      data['notifyUserIfDriverIsNotMovingEvenRideActive'] = notifyUserIfDriverIsNotMovingEvenRideActive;
    }
    if (customerIsWatchingLiveTracking != null) {
      data['customerIsWatchingLiveTracking'] = customerIsWatchingLiveTracking;
    }

    return data;
  }
}
