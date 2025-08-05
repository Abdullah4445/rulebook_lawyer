import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/widget/geoflutterfire/src/models/distance_doc_snapshot.dart';
import 'package:driver/widget/geoflutterfire/src/models/point.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class GeoFireCollectionRef extends BaseGeoFireCollectionRef<Map<String, dynamic>> {
  GeoFireCollectionRef(super.collectionReference);

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> within({
    required GeoFirePoint center,
    required double radius,
    required String field,
    bool? strictMode,
  }) {
    return protectedWithin(
      center: center,
      radius: radius,
      field: field,
      geopointFrom: (snapData) => geopointFromMap(
        field: field,
        snapData: snapData,
      ),
      strictMode: strictMode,
    );
  }

  Stream<List<DistanceDocSnapshot<Map<String, dynamic>>>> withinWithDistance({
    required GeoFirePoint center,
    required double radius,
    required String field,
    bool? strictMode,
  }) {
    return protectedWithinWithDistance(
      center: center,
      radius: radius,
      field: field,
      geopointFrom: (snapData) => geopointFromMap(
        field: field,
        snapData: snapData,
      ),
      strictMode: strictMode,
    );
  }

  @visibleForTesting
  static GeoPoint? geopointFromMap({
    required String field,
    required Map<String, dynamic> snapData,
  }) {
    // split and fetch geoPoint from the nested Map
    final fieldList = field.split('.');
    dynamic geoPointField = snapData[fieldList[0]];

    if (fieldList.length > 1) {
      for (int i = 1; i < fieldList.length; i++) {
        geoPointField = geoPointField?[fieldList[i]];
      }
    }

    final dynamic geopoint = geoPointField?['geopoint'];

    if (geopoint == null) return null;

    if (geopoint is GeoPoint) {
      return geopoint;
    } else if (geopoint is Map<String, dynamic>) {
      final lat = geopoint['latitude'];
      final lng = geopoint['longitude'];
      if (lat is num && lng is num) {
        return GeoPoint(lat.toDouble(), lng.toDouble());
      }
    }

    print("⚠️ Unexpected format in geopointFromMap: $geopoint");
    return null;
  }
}
