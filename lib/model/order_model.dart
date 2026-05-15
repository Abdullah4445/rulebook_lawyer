import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/model/admin_commission.dart';
import 'package:lawyer/model/contact_model.dart';
import 'package:lawyer/model/coupon_model.dart';
import 'package:lawyer/model/order/location_lat_lng.dart';
import 'package:lawyer/model/order/positions.dart';
import 'package:lawyer/model/service_model.dart';
import 'package:lawyer/model/tax_model.dart';
import 'package:lawyer/model/zone_model.dart';

// âœ… New TitleItem model import karo (ya isi file me rakh lo)
// class TitleItem {
//   String? title;
//   String? type;
//
//   TitleItem({this.title, this.type});
//
//   factory TitleItem.fromJson(Map<String, dynamic> json) {
//     return TitleItem(
//       title: json['title'] ?? '',
//       type: json['type'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'type': type,
//     };
//   }
// }

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
  String? cityName;
  String? description;
  // new fields
  String? courtName;
  String? caseStatus;
  String? judgeName;
  String? caseNumber;
  String? lastHearingDate;
  String? nextHearingDate;

  /// ðŸ†• List of titles (like en, ar, fr)
  // List<TitleItem>? titleList;

  /// ðŸ”¥ New fields for live tracking
  GeoPoint? driverLocation;
  bool? customerIsWatchingLiveTracking;
  bool? notifyUserIfDriverIsNotMovingEvenRideActive;

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
    this.cityName,
    this.driverLocation,
    this.description,
    this.caseNumber,
    this.courtName,
    this.judgeName,
    this.caseStatus,
    this.lastHearingDate,
    this.nextHearingDate,
    // this.titleList,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    print("My Bilal json is: $json");
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
    someOneElse = json['someOneElse'] != null ? ContactModel.fromJson(json['someOneElse']) : null;
    id = json['id'];
    caseStatus = json['caseStatus'];
    caseNumber = json['caseNumber'];
    judgeName = json['judgeName'];
    lastHearingDate = json['lastHearingDate'];
    nextHearingDate = json['nextHearingDate'];
    courtName = json['courtName'];
    description = json['description'];
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
    cityName = json['cityName'];

    //ðŸ”¥ New fields
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

    if (json['taxList'] != null) {
      taxList = <TaxModel>[];
      json['taxList'].forEach((v) {
        taxList!.add(TaxModel.fromJson(v));
      });
    }

    // /// ðŸ†• Title list parse karo
    // if (json['title'] != null) {
    //   titleList = (json['title'] as List)
    //       .map((e) => TitleItem.fromJson(Map<String, dynamic>.from(e)))
    //       .toList();
    // }
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
    data['cityName'] = cityName;
    data['id'] = id;
    data['userId'] = userId;
    data['description'] = description;
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
    data['courtName'] = courtName;
    data['caseNumber'] = caseNumber;
    data['judgeName'] = judgeName;
    data['caseStatus'] = caseStatus;
    data['lastHearingDate'] = lastHearingDate;
    data['nextHearingDate'] = nextHearingDate;

    if (taxList != null) {
      data['taxList'] = taxList!.map((v) => v.toJson()).toList();
    }
    if (position != null) {
      data['position'] = position!.toJson();
    }

    // ðŸ”¥ New fields
    if (driverLocation != null) {
      data['driverLocation'] = {
        'latitude': driverLocation!.latitude,
        'longitude': driverLocation!.longitude,
      };
    }

    data['customerIsWatchingLiveTracking'] = customerIsWatchingLiveTracking;
    data['notifyUserIfDriverIsNotMovingEvenRideActive'] =
        notifyUserIfDriverIsNotMovingEvenRideActive;

    // /// ðŸ†• Title list ko JSON me convert karo
    // if (titleList != null) {
    //   data['title'] = titleList!.map((e) => e.toJson()).toList();
    // }

    return data;
  }
}










// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lawyer/model/admin_commission.dart';
// import 'package:lawyer/model/contact_model.dart';
// import 'package:lawyer/model/coupon_model.dart';
// import 'package:lawyer/model/order/location_lat_lng.dart';
// import 'package:lawyer/model/order/positions.dart';
// import 'package:lawyer/model/service_model.dart';
// import 'package:lawyer/model/tax_model.dart';
// import 'package:lawyer/model/zone_model.dart';
//
// class OrderModel {
//   String? sourceLocationName;
//   String? destinationLocationName;
//   String? paymentType;
//   LocationLatLng? sourceLocationLatLng;
//   LocationLatLng? destinationLocationLatLng;
//   String? id;
//   String? serviceId;
//   String? userId;
//   String? offerRate;
//   String? finalRate;
//   String? distance;
//   String? distanceType;
//   String? status;
//   String? driverId;
//   String? otp;
//   List<dynamic>? acceptedDriverId;
//   List<dynamic>? rejectedDriverId;
//   Positions? position;
//   Timestamp? createdDate;
//   Timestamp? updateDate;
//   bool? paymentStatus;
//   List<TaxModel>? taxList;
//   ContactModel? someOneElse;
//   CouponModel? coupon;
//   ServiceModel? service;
//   AdminCommission? adminCommission;
//   ZoneModel? zone;
//   String? zoneId;
//   String? description;
//   // new fields
//   String? courtName;
//   String? caseStatus;
//   String? judgeName;
//   String? caseNumber;
//   String? lastHearingDate;
//   String? nextHearingDate;
//   String? title;
//
//
//   /// ðŸ”¥ New fields for live tracking
//   GeoPoint? driverLocation;
//   bool? customerIsWatchingLiveTracking;
//   bool? notifyUserIfDriverIsNotMovingEvenRideActive;
//
//   OrderModel({
//     this.position,
//     this.serviceId,
//     this.paymentType,
//     this.sourceLocationName,
//     this.destinationLocationName,
//     this.sourceLocationLatLng,
//     this.destinationLocationLatLng,
//     this.id,
//     this.userId,
//     this.distance,
//     this.distanceType,
//     this.status,
//     this.driverId,
//     this.otp,
//     this.offerRate,
//     this.finalRate,
//     this.paymentStatus,
//     this.createdDate,
//     this.updateDate,
//     this.taxList,
//     this.coupon,
//     this.someOneElse,
//     this.service,
//     this.adminCommission,
//     this.zone,
//     this.zoneId,
//     this.driverLocation,
//     this.customerIsWatchingLiveTracking,
//     this.notifyUserIfDriverIsNotMovingEvenRideActive,
//     this.description,
//     this.caseNumber,
//     this.courtName,
//     this.judgeName,
//     this.caseStatus,
//     this.lastHearingDate,
//     this.nextHearingDate,
//     this.title
//   });
//
//   OrderModel.fromJson(Map<String, dynamic> json) {
//     print("My Bilal json is: $json");
//     serviceId = json['serviceId'];
//     sourceLocationName = json['sourceLocationName'];
//     destinationLocationName = json['destinationLocationName'];
//     paymentType = json['paymentType'];
//     final srcRaw = json['sourceLocationLatLng'];
//     if (srcRaw != null) {
//       if (srcRaw is GeoPoint) {
//         sourceLocationLatLng = LocationLatLng(
//           latitude: srcRaw.latitude,
//           longitude: srcRaw.longitude,
//         );
//       } else if (srcRaw is Map) {
//         sourceLocationLatLng = LocationLatLng(
//           latitude: srcRaw['latitude']?.toDouble() ?? 0.0,
//           longitude: srcRaw['longitude']?.toDouble() ?? 0.0,
//         );
//       }
//     }
//
//     final desRaw = json['destinationLocationLatLng'];
//     if (desRaw != null) {
//       if (desRaw is GeoPoint) {
//         destinationLocationLatLng = LocationLatLng(
//           latitude: desRaw.latitude,
//           longitude: desRaw.longitude,
//         );
//       } else if (desRaw is Map) {
//         destinationLocationLatLng = LocationLatLng(
//           latitude: desRaw['latitude']?.toDouble() ?? 0.0,
//           longitude: desRaw['longitude']?.toDouble() ?? 0.0,
//         );
//       }
//     }
//     coupon = json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
//     someOneElse =
//         json['someOneElse'] != null ? ContactModel.fromJson(json['someOneElse']) : null;
//     id = json['id'];
//     caseStatus=json['caseStatus'];
//     caseNumber=json['caseNumber'];
//     judgeName=json['judgeName'];
//     lastHearingDate=json['lastHearingDate'];
//     nextHearingDate=json['nextHearingDate'];
//     courtName=json['courtName'];
//     description=json['description'];
//     userId = json['userId'];
//     offerRate = json['offerRate'];
//     finalRate = json['finalRate'];
//     distance = json['distance'];
//     distanceType = json['distanceType'];
//     status = json['status'];
//     driverId = json['driverId'];
//     otp = json['otp'];
//     createdDate = json['createdDate'];
//     updateDate = json['updateDate'];
//     acceptedDriverId = json['acceptedDriverId'];
//     rejectedDriverId = json['rejectedDriverId'];
//     paymentStatus = json['paymentStatus'];
//     position = json['position'] != null ? Positions.fromJson(json['position']) : null;
//     service = json['service'] != null ? ServiceModel.fromJson(json['service']) : null;
//     adminCommission = json['adminCommission'] != null
//         ? AdminCommission.fromJson(json['adminCommission'])
//         : null;
//     zone = json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null;
//     zoneId = json['zoneId'];
//
//     // ðŸ”¥ New fields
//     final dLoc = json['driverLocation'];
//     if (dLoc is GeoPoint) {
//       driverLocation = dLoc;
//     } else if (dLoc is Map<String, dynamic>) {
//       driverLocation = GeoPoint(
//         dLoc['latitude']?.toDouble() ?? 0.0,
//         dLoc['longitude']?.toDouble() ?? 0.0,
//       );
//     }
//     customerIsWatchingLiveTracking = json['customerIsWatchingLiveTracking'];
//     notifyUserIfDriverIsNotMovingEvenRideActive =
//         json['notifyUserIfDriverIsNotMovingEvenRideActive'];
//
//     if (json['taxList'] != null) {
//       taxList = <TaxModel>[];
//       json['taxList'].forEach((v) {
//         taxList!.add(TaxModel.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['serviceId'] = serviceId;
//     data['sourceLocationName'] = sourceLocationName;
//     data['destinationLocationName'] = destinationLocationName;
//     if (sourceLocationLatLng != null) {
//       data['sourceLocationLatLng'] = sourceLocationLatLng!.toJson();
//     }
//     if (coupon != null) {
//       data['coupon'] = coupon!.toJson();
//     }
//     if (someOneElse != null) {
//       data['someOneElse'] = someOneElse!.toJson();
//     }
//     if (destinationLocationLatLng != null) {
//       data['destinationLocationLatLng'] = destinationLocationLatLng!.toJson();
//     }
//     if (service != null) {
//       data['service'] = service!.toJson();
//     }
//     if (adminCommission != null) {
//       data['adminCommission'] = adminCommission!.toJson();
//     }
//     if (zone != null) {
//       data['zone'] = zone!.toJson();
//     }
//     data['zoneId'] = zoneId;
//     data['id'] = id;
//     data['userId'] = userId;
//     data['description']=description;
//     data['paymentType'] = paymentType;
//     data['offerRate'] = offerRate;
//     data['finalRate'] = finalRate;
//     data['distance'] = distance;
//     data['distanceType'] = distanceType;
//     data['status'] = status;
//     data['driverId'] = driverId;
//     data['otp'] = otp;
//     data['createdDate'] = createdDate;
//     data['updateDate'] = updateDate;
//     data['acceptedDriverId'] = acceptedDriverId;
//     data['rejectedDriverId'] = rejectedDriverId;
//     data['paymentStatus'] = paymentStatus;
//     data['courtName']=courtName;
//     data['caseNumber']=caseNumber;
//     data['judgeName']=judgeName;
//     data['caseStatus']=caseStatus;
//     data['lastHearingDate']=lastHearingDate;
//     data['nextHearingDate']=nextHearingDate;
//
//     if (taxList != null) {
//       data['taxList'] = taxList!.map((v) => v.toJson()).toList();
//     }
//     if (position != null) {
//       data['position'] = position!.toJson();
//     }
//
//     // ðŸ”¥ New fields
//     if (driverLocation != null) {
//       data['driverLocation'] = {
//         'latitude': driverLocation!.latitude,
//         'longitude': driverLocation!.longitude,
//       };
//     }
//     data['customerIsWatchingLiveTracking'] = customerIsWatchingLiveTracking;
//     data['notifyUserIfDriverIsNotMovingEvenRideActive'] =
//         notifyUserIfDriverIsNotMovingEvenRideActive;
//
//     return data;
//   }
// }

// class OrderModel {
//   String? sourceLocationName;
//   String? destinationLocationName;
//   String? paymentType;
//   LocationLatLng? sourceLocationLatLng;
//   LocationLatLng? destinationLocationLatLng;
//   String? id;
//   String? serviceId;
//   String? userId;
//   String? offerRate;
//   String? finalRate;
//   String? distance;
//   String? distanceType;
//   String? status;
//   String? driverId;
//   String? otp;
//   List<dynamic>? acceptedDriverId;
//   List<dynamic>? rejectedDriverId;
//   Positions? position;
//   Timestamp? createdDate;
//   Timestamp? updateDate;
//   bool? paymentStatus;
//   List<TaxModel>? taxList;
//   ContactModel? someOneElse;
//   CouponModel? coupon;
//   ServiceModel? service;
//   AdminCommission? adminCommission;
//   ZoneModel? zone;
//   String? zoneId;
//
//   // âœ… New fields for live tracking logic
//   GeoPoint? driverLocation;
//   bool? notifyUserIfDriverIsNotMovingEvenRideActive;
//   bool? customerIsWatchingLiveTracking;
//   String? customerName;
//   String? phoneNumber;
//
//   OrderModel({
//     this.position,
//     this.serviceId,
//     this.paymentType,
//     this.sourceLocationName,
//     this.destinationLocationName,
//     this.sourceLocationLatLng,
//     this.destinationLocationLatLng,
//     this.id,
//     this.userId,
//     this.distance,
//     this.distanceType,
//     this.status,
//     this.driverId,
//     this.otp,
//     this.offerRate,
//     this.finalRate,
//     this.paymentStatus,
//     this.createdDate,
//     this.updateDate,
//     this.taxList,
//     this.coupon,
//     this.someOneElse,
//     this.service,
//     this.adminCommission,
//     this.zone,
//     this.zoneId,
//     this.driverLocation,
//     this.notifyUserIfDriverIsNotMovingEvenRideActive,
//     this.customerIsWatchingLiveTracking,
//   });
//
//   OrderModel.fromJson(Map<String, dynamic> json) {
//     print("DEBUG: Unmapped fields: ${json.keys.where((k) => ![
//           'serviceId',
//           'sourceLocationName',
//           'destinationLocationName',
//           'paymentType',
//           'customerName',
//           'phoneNumber',
//           'sourceLocationLatLng',
//           'destinationLocationLatLng',
//           'coupon',
//           'someOneElse',
//           'id',
//           'userId',
//           'offerRate',
//           'finalRate',
//           'distance',
//           'distanceType',
//           'status',
//           'driverId',
//           'otp',
//           'createdDate',
//           'updateDate',
//           'acceptedDriverId',
//           'rejectedDriverId',
//           'paymentStatus',
//           'position',
//           'service',
//           'adminCommission',
//           'zone',
//           'zoneId',
//           'driverLocation',
//           'notifyUserIfDriverIsNotMovingEvenRideActive',
//           'customerIsWatchingLiveTracking',
//           'taxList',
//         ].contains(k)).toList()}");
//
//     serviceId = json['serviceId'];
//     sourceLocationName = json['sourceLocationName'];
//     destinationLocationName = json['destinationLocationName'];
//     paymentType = json['paymentType'];
//
//     customerName = json['customerName'];
//     phoneNumber = json['phoneNumber'];
//
//     sourceLocationLatLng = json['sourceLocationLatLng'] != null
//         ? LocationLatLng(
//             latitude: json['sourceLocationLatLng']['latitude'],
//             longitude: json['sourceLocationLatLng']['longitude'],
//           )
//         : null;
//
//     destinationLocationLatLng = json['destinationLocationLatLng'] != null
//         ? LocationLatLng(
//             latitude: json['destinationLocationLatLng']['latitude'],
//             longitude: json['destinationLocationLatLng']['longitude'],
//           )
//         : null;
//
//     coupon = json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null;
//     someOneElse =
//         json['someOneElse'] != null ? ContactModel.fromJson(json['someOneElse']) : null;
//     id = json['id'];
//     userId = json['userId'];
//     offerRate = json['offerRate'];
//     finalRate = json['finalRate'];
//     distance = json['distance'];
//     distanceType = json['distanceType'];
//     status = json['status'];
//     driverId = json['driverId'];
//     otp = json['otp'];
//     createdDate = json['createdDate'];
//     updateDate = json['updateDate'];
//     acceptedDriverId = json['acceptedDriverId'];
//     rejectedDriverId = json['rejectedDriverId'];
//     paymentStatus = json['paymentStatus'];
//     position = json['position'] != null ? Positions.fromJson(json['position']) : null;
//     service = json['service'] != null ? ServiceModel.fromJson(json['service']) : null;
//     adminCommission = json['adminCommission'] != null
//         ? AdminCommission.fromJson(json['adminCommission'])
//         : null;
//     zone = json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null;
//     zoneId = json['zoneId'];
//
//     // âœ… New fields
//     driverLocation = json['driverLocation'];
//     notifyUserIfDriverIsNotMovingEvenRideActive =
//         json['notifyUserIfDriverIsNotMovingEvenRideActive'];
//     customerIsWatchingLiveTracking = json['customerIsWatchingLiveTracking'];
//
//     if (json['taxList'] != null) {
//       taxList = <TaxModel>[];
//       json['taxList'].forEach((v) {
//         taxList!.add(TaxModel.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//
//     data['serviceId'] = serviceId;
//     data['sourceLocationName'] = sourceLocationName;
//     data['destinationLocationName'] = destinationLocationName;
//     data['paymentType'] = paymentType;
//     data['id'] = id;
//     data['userId'] = userId;
//     data['offerRate'] = offerRate;
//     data['finalRate'] = finalRate;
//     data['distance'] = distance;
//     data['distanceType'] = distanceType;
//     data['status'] = status;
//     data['driverId'] = driverId;
//     data['otp'] = otp;
//     data['createdDate'] = createdDate;
//     data['updateDate'] = updateDate;
//     data['acceptedDriverId'] = acceptedDriverId;
//     data['rejectedDriverId'] = rejectedDriverId;
//     data['paymentStatus'] = paymentStatus;
//     data['zoneId'] = zoneId;
//
//     if (sourceLocationLatLng != null)
//       data['sourceLocationLatLng'] = sourceLocationLatLng!.toJson();
//     if (destinationLocationLatLng != null)
//       data['destinationLocationLatLng'] = destinationLocationLatLng!.toJson();
//     if (coupon != null) data['coupon'] = coupon!.toJson();
//     if (someOneElse != null) data['someOneElse'] = someOneElse!.toJson();
//     if (service != null) data['service'] = service!.toJson();
//     if (adminCommission != null) data['adminCommission'] = adminCommission!.toJson();
//     if (zone != null) data['zone'] = zone!.toJson();
//     if (taxList != null) data['taxList'] = taxList!.map((v) => v.toJson()).toList();
//     if (position != null) data['position'] = position!.toJson();
//
//     // âœ… Add new fields
//     if (driverLocation != null) data['driverLocation'] = driverLocation;
//     if (notifyUserIfDriverIsNotMovingEvenRideActive != null) {
//       data['notifyUserIfDriverIsNotMovingEvenRideActive'] =
//           notifyUserIfDriverIsNotMovingEvenRideActive;
//     }
//     if (customerIsWatchingLiveTracking != null) {
//       data['customerIsWatchingLiveTracking'] = customerIsWatchingLiveTracking;
//     }
//
//     return data;
//   }
// }
