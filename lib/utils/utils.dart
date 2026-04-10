import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/order/location_lat_lng.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/global_setting_conroller.dart';
import '../services/localization_service.dart';

class Utils {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    print("GETTING LOCATIONNN1234ðŸŒðŸŒº $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print("GETTING LOCATIONNNðŸŒðŸŒº ");
    Position? position = await Geolocator.getCurrentPosition();
    print("GETTING LOCATIONNNðŸŒðŸŒº ${position.latitude} ${position.longitude}");
    Constant.currentLocation =
        LocationLatLng(latitude: position.latitude, longitude: position.longitude);
    return await Geolocator.getCurrentPosition();
  }

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static redirectMap(
      {required String curName,
      required String name,
      required double curLat,
      required curLon,
      required double latitude,
      required double longLatitude}) async {
    if (Constant.mapType == "google") {
      bool? isGoogleAvailable = await MapLauncher.isMapAvailable(MapType.google);
      if (isGoogleAvailable == true) {
        print("In google maps");
        print("My source Lat: $curLat");
        print("My source Lon: $curLon");

        print("My desti Lat: $latitude");
        print("My desti Lon: $longLatitude");
        await MapLauncher.showDirections(
          mapType: MapType.google,
          directionsMode: DirectionsMode.driving,
          origin: Coords(curLat, curLon),
          originTitle: curName,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        bool? isAppleAvailable = await MapLauncher.isMapAvailable(MapType.apple);
        if (isAppleAvailable == true) {
          print("In Apple maps");
          print("My source Lat: $curLat");
          print("My source Lon: $curLon");

          print("My desti Lat: $latitude");
          print("My desti Lon: $longLatitude");

          await MapLauncher.showDirections(
            mapType: MapType.apple,
            directionsMode: DirectionsMode.driving,
            origin: Coords(curLat, curLon),
            originTitle: curName,
            destinationTitle: name,
            destination: Coords(latitude, longLatitude),
          );
        } else {
          ShowToastDialog.showToast(
                  "No supported map apps are installed. Either Install google ")
              .tr;
        }
      }
    } else if (Constant.mapType == "googleGo") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.googleGo);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.googleGo,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed").tr;
      }
    } else if (Constant.mapType == "waze") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.waze);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.waze,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed").tr;
      }
    } else if (Constant.mapType == "mapswithme") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.mapswithme);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.mapswithme,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed").tr;
      }
    } else if (Constant.mapType == "yandexNavi") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexNavi);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexNavi,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed").tr;
      }
    } else if (Constant.mapType == "yandexMaps") {
      bool? isAvailable = await MapLauncher.isMapAvailable(MapType.yandexMaps);
      if (isAvailable == true) {
        await MapLauncher.showDirections(
          mapType: MapType.yandexMaps,
          directionsMode: DirectionsMode.driving,
          destinationTitle: name,
          destination: Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed").tr;
      }
    }
  }

  Future<void> requestBackgroundLocationPermission() async {
    print('Requesting background location permission...');
    final status =
        await Permission.locationAlways.request(); // or locationWhenInUse.request()

    if (status.isGranted) {
      print('Background location permission granted.');
    } else if (status.isDenied) {
      print('Background location permission denied.');
      // Handle the denied case (e.g., show a message to the user).
    } else if (status.isPermanentlyDenied) {
      print('Background location permission permanently denied.');
      // Handle the permanently denied case (e.g., open app settings).
      openAppSettings();
    }
  }

  Future<bool> isBackgroundLocationPermissionGranted() async {
    return await Permission.locationAlways.isGranted;
  }
}

// A simple LatLng model for clarity.
class MyLatLng {
  final double latitude;
  final double longitude;

  MyLatLng(this.latitude, this.longitude);
}

// This is your zone model. Adapt as needed.
class MyZoneModel {
  final List<MyLatLng> area;
  final String currency; // language code (e.g. "fr", "en", etc.)
  final String language; // language code (e.g. "fr", "en", etc.)
  final String name; // language code (e.g. "fr", "en", etc.)
  final String id; // language code (e.g. "fr", "en", etc.)
  // Other fields omitted for brevity

  MyZoneModel(
      {required this.area,
      required this.currency,
      required this.id,
      required this.name,
      required this.language});

  factory MyZoneModel.fromJson(Map<String, dynamic> json) {
    // Convert Firestore GeoPoint list to a List<LatLng>
    List<dynamic> areaData = json['area'] ?? [];

    List<MyLatLng> area = areaData.map((gp) {
      // Assuming each element is a GeoPoint (or a map with latitude/longitude keys)
      if (gp is GeoPoint) {
        return MyLatLng(gp.latitude, gp.longitude);
      } else if (gp is Map) {
        return MyLatLng(gp['latitude'], gp['longitude']);
      }
      return MyLatLng(0, 0);
    }).toList();

    return MyZoneModel(
      name: json['name'][0]['name'].toString().isEmpty
          ? json['name'][1]['name']
          : json['name'][0]['name'],
      id: json['id'],
      area: area,
      currency: json['currency'] ?? 'en',
      language: json['language'] ?? 'en',
    );
  }
}

/// Checks whether [point] is inside the polygon defined by [polygon].
/// Uses the ray-casting algorithm.
bool isPointInPolygon(MyLatLng point, List<MyLatLng> polygon) {
  int intersectCount = 0;
  for (int j = 0; j < polygon.length; j++) {
    int i = (j + 1) % polygon.length;
    if (((polygon[j].longitude > point.longitude) !=
            (polygon[i].longitude > point.longitude)) &&
        (point.latitude <
            (polygon[i].latitude - polygon[j].latitude) *
                    (point.longitude - polygon[j].longitude) /
                    (polygon[i].longitude - polygon[j].longitude) +
                polygon[j].latitude)) {
      intersectCount++;
    }
  }
  return (intersectCount % 2) == 1;
}

/// Fetch zones from Firestore (only published ones) and return a list of ZoneModels.
Future<List<MyZoneModel>> fetchZones() async {
  List<MyZoneModel> zones = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('zone')
      .where('publish', isEqualTo: true)
      .get();
  for (var doc in snapshot.docs) {
    zones.add(MyZoneModel.fromJson(doc.data() as Map<String, dynamic>));
  }
  return zones;
}

/// Given the user's [position], find the zone that contains the point.
/// You can modify this to choose the closest zone if no polygon contains the point.
Future<MyZoneModel?> getZoneForPosition(Position position) async {
  MyLatLng userPoint = MyLatLng(position.latitude, position.longitude);
  List<MyZoneModel> zones = await fetchZones();

  // Try to find a zone where the user is inside its polygon.
  for (MyZoneModel zone in zones) {
    if (zone.area.isNotEmpty && isPointInPolygon(userPoint, zone.area)) {
      return zone;
    }
  }
  // If none found, you might choose to return the nearest zone. For now, return null.
  return null;
}

/// Call this function after the current location is obtained.
/// It fetches the best zone based on the location and updates the app language.
Future<void> updateAppLanguageBasedOnLocation(Position currentPosition) async {
  MyZoneModel? zone = await getZoneForPosition(currentPosition);
  if (zone != null) {
    myCurrencyId = zone.currency;
    String langCode = zone.language;
    Locale newLocale = Locale(langCode);
    Get.updateLocale(newLocale);
    LocalizationService.locale = newLocale;
    GlobalSettingController().getCurrentCurrencyAndLanguage();
  } else {
    print("No matching zone found for the current location. Using default language.");
  }
}

String myCurrencyId = '';
String myLanguageId = '';

class MyLocationLatLng {
  double? latitude;
  double? longitude;

  MyLocationLatLng({this.latitude, this.longitude});

  MyLocationLatLng.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
