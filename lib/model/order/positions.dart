import 'package:cloud_firestore/cloud_firestore.dart';

class Positions {
  String? geohash;
  GeoPoint? geoPoint;

  Positions({this.geohash, this.geoPoint});

  factory Positions.fromJson(Map<String, dynamic> json) {
    GeoPoint? parsedGeoPoint;

    final geopointData = json['geopoint'];
    if (geopointData == null) {
      parsedGeoPoint = null;
    } else if (geopointData is GeoPoint) {
      parsedGeoPoint = geopointData;
    } else if (geopointData is Map<String, dynamic>) {
      final lat = geopointData['latitude'];
      final lng = geopointData['longitude'];
      if (lat is num && lng is num) {
        parsedGeoPoint = GeoPoint(lat.toDouble(), lng.toDouble());
      }
    } else {
      print('⚠️ Unexpected geopoint format: $geopointData');
    }

    return Positions(
      geohash: json['geohash'] as String?,
      geoPoint: parsedGeoPoint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': geohash,
      'geopoint': geoPoint != null
          ? {'latitude': geoPoint!.latitude, 'longitude': geoPoint!.longitude}
          : null,
    };
  }
}
