import 'package:cloud_firestore/cloud_firestore.dart';

import 'language_name.dart';

class ZoneModel {
  List<GeoPoint>? area;
  bool? publish;
  double? latitude;
  List<LanguageName>? name;
  String? id;
  double? longitude;

  ZoneModel({this.area, this.publish, this.latitude, this.name, this.id, this.longitude});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    if (json['area'] != null) {
      area = <GeoPoint>[];
      json['area'].forEach((v) {
        // Here's the change: check if 'v' is a Map and create a GeoPoint from it.
        // This handles cases where data might be coming from different sources (e.g., Firestore vs. local JSON)
        if (v is Map<String, dynamic>) {
          area!.add(GeoPoint(v['latitude'] as double, v['longitude'] as double));
        } else if (v is GeoPoint) {
          // This case handles data coming directly from Firestore which might already be a GeoPoint
          area!.add(v);
        }
      });
    }

    if (json['name'] != null) {
      name = <LanguageName>[];
      json['name'].forEach((v) {
        name!.add(LanguageName.fromJson(v));
      });
    }

    publish = json['publish'];
    latitude = json['latitude'];
    id = json['id'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (area != null) {
      // Correctly serialize GeoPoint back to a Map with latitude and longitude
      data['area'] = area!
          .map((v) => {
                'latitude': v.latitude,
                'longitude': v.longitude,
              })
          .toList();
    }
    if (name != null) {
      data['name'] = name!.map((v) => v.toJson()).toList();
    }
    data['publish'] = publish;
    data['latitude'] = latitude;
    data['id'] = id;
    data['longitude'] = longitude;
    return data;
  }
}
