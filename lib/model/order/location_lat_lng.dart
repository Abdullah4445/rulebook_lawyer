import 'package:cloud_firestore/cloud_firestore.dart';

class LocationLatLng {
  double? latitude;
  double? longitude;

  LocationLatLng({this.latitude, this.longitude});

  factory LocationLatLng.fromJson(Map<String, dynamic> json) {
    return LocationLatLng(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  factory LocationLatLng.fromGeoPoint(GeoPoint point) {
    return LocationLatLng(
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }


  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}