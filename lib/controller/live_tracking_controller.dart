import 'dart:async';
import 'dart:math';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;


  @override
  void onInit() {
    if (Constant.selectedMapType == 'osm') {
      print("Is osm");
      ShowToastDialog.showLoader("Please wait");
      mapOsmController = MapController(initPosition: GeoPoint(latitude: 20.9153, longitude: -100.7439), useExternalTracking: false); //OSM
    }else{
      print("Not osm");
    }
    addMarkerSetup();
    Future.delayed(Duration.zero, () {
      getArgument(); // Safe now
    });
     // playSound();
    _startLiveDriverLocation();
    super.onInit();
  }
  StreamSubscription<Position>? _driverPositionStream;

  void _startLiveDriverLocation() {
    _driverPositionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // only update if moved at least 1 meter
      ),
    ).listen((Position position) {
      final LatLng driverLatLng = LatLng(position.latitude, position.longitude);

      markers[const MarkerId("Driver")] = Marker(
        markerId: const MarkerId("Driver"),
        position: driverLatLng,
        icon: driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        rotation: position.heading,
      );

      mapController?.animateCamera(CameraUpdate.newLatLng(driverLatLng)); // optional: camera follows

      update();
    });
  }


  @override
  void onClose() {
    ShowToastDialog.closeLoader();
    _driverPositionStream?.cancel();
    super.onClose();
  }

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<InterCityOrderModel> intercityOrderModel = InterCityOrderModel().obs;

  RxBool isLoading = true.obs;
  RxString type = "".obs;

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;


  Future<void> zoomToFit(GeoPoint start, GeoPoint end) async {
    BoundingBox box = BoundingBox(
      north: max(start.latitude, end.latitude),
      south: min(start.latitude, end.latitude),
      east: max(start.longitude, end.longitude),
      west: min(start.longitude, end.longitude),
    );
    await mapOsmController.zoomToBoundingBox(box, paddinInPixel: 50);
  }


  getArgument() async {
    print("In argmuent");
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      print("In argmuent 2");
      type.value = argumentData['type'];
      if (type.value == "routeOnly") {
        Future.delayed(Duration(milliseconds: 300), () async {
          LatLng driverLatLng = argumentData['driverLatLng'];
         LatLng customerLatLng = argumentData['customerLatLng'];

          print("My details are: $driverLatLng");
          print("My details are Customer: $customerLatLng");


          getPolyline(
            sourceLatitude: driverLatLng.latitude,
            sourceLongitude: driverLatLng.longitude,
            destinationLatitude: customerLatLng.latitude,
            destinationLongitude: customerLatLng.longitude,
          );

          isLoading.value = false;
          update();
        });
        return;
      }
      if (type.value == "orderModel") {
        OrderModel argumentOrderModel = argumentData['orderModel'];

        FireStoreUtils.fireStore.collection(CollectionName.orders).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            OrderModel orderModelStream = OrderModel.fromJson(event.data()!);

            orderModel.value = orderModelStream;
            FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (Constant.selectedMapType != 'osm') {
                  if (orderModel.value.status == Constant.rideInProgress) {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: orderModel.value.destinationLocationLatLng!.latitude,
                        destinationLongitude: orderModel.value.destinationLocationLatLng!.longitude);
                  } else {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: orderModel.value.sourceLocationLatLng!.latitude,
                        destinationLongitude: orderModel.value.sourceLocationLatLng!.longitude);
                  }
                } else {
                  if (orderModel.value.status == Constant.rideInProgress) {
                    getOSMPolyline(
                      GeoPoint(latitude: driverUserModel.value.location!.latitude!, longitude: driverUserModel.value.location!.longitude!),
                      GeoPoint(latitude: orderModel.value.destinationLocationLatLng!.latitude!, longitude: orderModel.value.destinationLocationLatLng!.longitude!),
                    );
                    setOsmMarker(
                      departure: GeoPoint(latitude: orderModel.value.sourceLocationLatLng?.latitude ?? 0.0, longitude: orderModel.value.sourceLocationLatLng?.longitude ?? 0.0),
                      destination:
                          GeoPoint(latitude: orderModel.value.destinationLocationLatLng?.latitude ?? 0.0, longitude: orderModel.value.destinationLocationLatLng?.longitude ?? 0.0),
                    );
                  } else {
                    getOSMPolyline(
                      GeoPoint(latitude: driverUserModel.value.location!.latitude!, longitude: driverUserModel.value.location!.longitude!),
                      GeoPoint(latitude: orderModel.value.sourceLocationLatLng!.latitude!, longitude: orderModel.value.sourceLocationLatLng!.longitude!),
                    );
                    setOsmMarker(
                      departure: GeoPoint(latitude: orderModel.value.sourceLocationLatLng?.latitude ?? 0.0, longitude: orderModel.value.sourceLocationLatLng?.longitude ?? 0.0),
                      destination:
                          GeoPoint(latitude: orderModel.value.destinationLocationLatLng!.latitude ?? 0.0, longitude: orderModel.value.destinationLocationLatLng!.longitude ?? 0.0),
                    );
                  }
                }
              }
            });

            if (orderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });
      } else {
        InterCityOrderModel argumentOrderModel = argumentData['interCityOrderModel'];
        FireStoreUtils.fireStore.collection(CollectionName.ordersIntercity).doc(argumentOrderModel.id).snapshots().listen((event) {
          if (event.data() != null) {
            InterCityOrderModel orderModelStream = InterCityOrderModel.fromJson(event.data()!);
            print("====>");
            intercityOrderModel.value = orderModelStream;
            FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(argumentOrderModel.driverId).snapshots().listen((event) {
              if (event.data() != null) {
                driverUserModel.value = DriverUserModel.fromJson(event.data()!);
                if (Constant.selectedMapType != 'osm') {
                  if (intercityOrderModel.value.status == Constant.rideInProgress) {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: intercityOrderModel.value.destinationLocationLatLng!.latitude,
                        destinationLongitude: intercityOrderModel.value.destinationLocationLatLng!.longitude);
                  } else {
                    getPolyline(
                        sourceLatitude: driverUserModel.value.location!.latitude,
                        sourceLongitude: driverUserModel.value.location!.longitude,
                        destinationLatitude: intercityOrderModel.value.sourceLocationLatLng!.latitude,
                        destinationLongitude: intercityOrderModel.value.sourceLocationLatLng!.longitude);
                  }
                } else {
                  if (intercityOrderModel.value.status == Constant.rideInProgress) {
                    getOSMPolyline(
                      GeoPoint(latitude: driverUserModel.value.location!.latitude!, longitude: driverUserModel.value.location!.longitude!),
                      GeoPoint(
                          latitude: intercityOrderModel.value.destinationLocationLatLng!.latitude!, longitude: intercityOrderModel.value.destinationLocationLatLng!.longitude!),
                    );
                    setOsmMarker(
                      departure: GeoPoint(
                        latitude: intercityOrderModel.value.sourceLocationLatLng!.latitude ?? 0.0,
                        longitude: intercityOrderModel.value.sourceLocationLatLng!.longitude ?? 0.0,
                      ),
                      destination: GeoPoint(
                          latitude: intercityOrderModel.value.destinationLocationLatLng!.latitude ?? 0.0,
                          longitude: intercityOrderModel.value.destinationLocationLatLng!.longitude ?? 0.0),
                    );
                  } else {
                    getOSMPolyline(
                      GeoPoint(latitude: driverUserModel.value.location!.latitude!, longitude: driverUserModel.value.location!.longitude!),
                      GeoPoint(latitude: intercityOrderModel.value.sourceLocationLatLng!.latitude!, longitude: intercityOrderModel.value.sourceLocationLatLng!.longitude!),
                    );
                    setOsmMarker(
                      departure: GeoPoint(
                        latitude: intercityOrderModel.value.sourceLocationLatLng!.latitude ?? 0.0,
                        longitude: intercityOrderModel.value.sourceLocationLatLng!.longitude ?? 0.0,
                      ),
                      destination: GeoPoint(
                        latitude: intercityOrderModel.value.destinationLocationLatLng!.latitude ?? 0.0,
                        longitude: intercityOrderModel.value.destinationLocationLatLng!.longitude ?? 0.0,
                      ),
                    );
                  }
                }
              }
            });

            if (intercityOrderModel.value.status == Constant.rideComplete) {
              Get.back();
            }
          }
        });
      }
    }
    else{
      print("In argmuent 2");
    }
    isLoading.value = false;
    update();
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    print('🔎 Routing from: ($sourceLatitude, $sourceLongitude)');
    print('🔎 To: ($destinationLatitude, $destinationLongitude)');

    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      );
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.mapAPIKey,
        request: polylineRequest,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      if (type.value == "orderModel") {
        addMarker(
            latitude: orderModel.value.sourceLocationLatLng!.latitude,
            longitude: orderModel.value.sourceLocationLatLng!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: orderModel.value.destinationLocationLatLng!.latitude,
            longitude: orderModel.value.destinationLocationLatLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(
            latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      }

      else if (type.value == "routeOnly") {
        // New case for showing route to customer
        addMarker(
          latitude: sourceLatitude!,
          longitude: sourceLongitude!,
          id: "Driver",
          descriptor: driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          rotation: 0.0,
        );
        addMarker(
          latitude: destinationLatitude!,
          longitude: destinationLongitude!,
          id: "Customer",
          descriptor: destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: 0.0,
        );
        _addPolyLine(polylineCoordinates);
      }

      else {
        addMarker(
            latitude: intercityOrderModel.value.sourceLocationLatLng!.latitude,
            longitude: intercityOrderModel.value.sourceLocationLatLng!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: intercityOrderModel.value.destinationLocationLatLng!.latitude,
            longitude: intercityOrderModel.value.destinationLocationLatLng!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
        addMarker(
            latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: driverUserModel.value.rotation);

        _addPolyLine(polylineCoordinates);
      }
    }
  }

  addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  addMarkerSetup() async {
    if (Constant.selectedMapType == 'google') {
      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 100);
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 100);
      final Uint8List driver = await Constant().getBytesFromAsset('assets/images/ic_cab.png', 50);
      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      driverIcon = BitmapDescriptor.fromBytes(driver);
    } else {
      departureOsmIcon = Image.asset("assets/images/pickup.png", width: 30, height: 30); //OSM
      destinationOsmIcon = Image.asset("assets/images/dropoff.png", width: 30, height: 30); //OSM
      driverOsmIcon = Image.asset("assets/images/ic_cab.png", width: 80, height: 80); //OSM
    }
  }


  PolylinePoints polylinePoints = PolylinePoints();

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      width: 6,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  //OSM
  late MapController mapOsmController;
  Rx<RoadInfo> roadInfo = RoadInfo().obs;
  Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
  Image? departureOsmIcon; //OSM
  Image? destinationOsmIcon; //OSM
  Image? driverOsmIcon;

  Future<void> getOSMPolyline(GeoPoint source, GeoPoint destination) async {
    try {
      final roadInfo = await mapOsmController.drawRoad(
        source,
        destination,
        roadType: RoadType.car,
      );

      print("🚗 Road distance: ${roadInfo.distance} km, duration: ${roadInfo.duration} min");
    } catch (e) {
      print("❌ Road drawing error: $e");
    }
  }

  Future<void> updateOSMCameraLocation({required GeoPoint source, required GeoPoint destination}) async {
    BoundingBox bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.latitude > destination.latitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    } else {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    }

    await mapOsmController.zoomToBoundingBox(bounds, paddinInPixel: 100);
  }

  setOsmMarker({required GeoPoint departure, required GeoPoint destination}) async {
    if (osmMarkers.containsKey('Source')) {
      await mapOsmController.removeMarker(osmMarkers['Source']!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await mapOsmController
          .addMarker(departure,
              markerIcon: MarkerIcon(iconWidget: departureOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Source'] = departure;
      });

      if (osmMarkers.containsKey('Destination')) {
        await mapOsmController.removeMarker(osmMarkers['Destination']!);
      }

      await mapOsmController
          .addMarker(destination,
              markerIcon: MarkerIcon(iconWidget: destinationOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Destination'] = destination;
      });
    });
  }
}
