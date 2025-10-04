import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../constant/collection_name.dart';
import '../constant/constant.dart';
import '../model/order_model.dart';

class ActiveOrderController extends GetxController {
  HomeController homeController = Get.put(HomeController());
  Rx<TextEditingController> otpController = TextEditingController().obs;

  Timer? _locationUpdateTimer;
  GeoPoint? _lastSavedLocation;
  DateTime? _lastMovedTime;
  final RxBool _userShouldBeNotified = false.obs;
  String? _activeOrderId;

  var customerIsPicked = false.obs;

  // 🔁 New: Real-time watch for customer's live tracking
  bool _customerIsWatching = false;
  StreamSubscription<DocumentSnapshot>? _customerWatchSubscription;

  void startLocationUpdates(OrderModel orderModel) {
    // Avoid starting multiple timers for the same order
    if (_activeOrderId == orderModel.id) return;

    stopLocationUpdates(); // clear any previous session
    _activeOrderId = orderModel.id;
    _lastSavedLocation = null;
    _lastMovedTime = DateTime.now();

    // Listen to customer live tracking
    _customerWatchSubscription = FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .snapshots()
        .listen((doc) {
      _customerIsWatching = doc.data()?["customerIsWatchingLiveTracking"] ?? false;
      print(
          "[Tracking] Customer is ${_customerIsWatching ? '' : 'NOT '}watching live tracking.");
    });

    _locationUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      GeoPoint currentLocation =
          GeoPoint(currentPosition.latitude, currentPosition.longitude);

      // 1️⃣ Send driver location only if customer is watching OR taxi meter is active
      if (_customerIsWatching || taxiMeterActive.value) {
        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({
          "driverLocation": currentLocation,
          "updatedAt": Timestamp.now(),
        });
        print(
            "[Tracking] Location updated: ${currentLocation.latitude}, ${currentLocation.longitude}");
      }

      // 2️⃣ Update distance & fare only when ride is in progress and meter is active
      if (orderModel.status == Constant.rideInProgress && taxiMeterActive.value) {
        double lastLat = _lastSavedLocation?.latitude ?? currentLocation.latitude;
        double lastLng = _lastSavedLocation?.longitude ?? currentLocation.longitude;

        double distanceIncrement = Geolocator.distanceBetween(
              lastLat,
              lastLng,
              currentLocation.latitude,
              currentLocation.longitude,
            ) /
            1000; // meters -> km

        double previousDistance = double.tryParse(orderModel.distance ?? '0') ?? 0.0;
        double newDistance = previousDistance + distanceIncrement;

        // Update distance in Firestore
        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({"distance": newDistance.toStringAsFixed(2)});

        // Calculate fare based on finalRate
        double ratePerKm = double.tryParse(orderModel.finalRate ?? '0') ?? 0.0;
        double newFare = ratePerKm * newDistance;
        taxiMeterFare.value = newFare;

        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({'meterFare': newFare});

        _lastSavedLocation = currentLocation;
        _lastMovedTime = DateTime.now();
      }

      // 3️⃣ Notify if driver has not moved for 4+ minutes
      bool shouldNotify = DateTime.now().difference(_lastMovedTime!).inMinutes >= 4;
      if (shouldNotify != _userShouldBeNotified.value) {
        _userShouldBeNotified.value = shouldNotify;

        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({"notifyUserIfDriverIsNotMovingEvenRideActive": shouldNotify});

        print("[Tracking] notifyUserIfDriverIsNotMovingEvenRideActive = $shouldNotify");
      }
    });
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    _customerWatchSubscription?.cancel();
    _customerWatchSubscription = null;

    _activeOrderId = null;
    _customerIsWatching = false;

    print("[Tracking] Location updates stopped.");
  }

  // Taxi meter state
  RxBool taxiMeterActive = false.obs;
  RxDouble taxiMeterFare = 0.0.obs;

// Timer for fare calculation
  Timer? _taxiMeterTimer;

// Local tracker for taxi meter distance
  RxDouble taxiMeterDistance = 0.0.obs;

// Start taxi meter
  void startTaxiMeter(OrderModel orderModel) {
    if (taxiMeterActive.value) return;

    taxiMeterActive.value = true;

    // Initialize local distance
    taxiMeterDistance.value = double.tryParse(orderModel.distance ?? '0') ?? 0.0;
    double ratePerKm = double.tryParse(orderModel.finalRate ?? '0') ?? 0.0;
    taxiMeterFare.value = taxiMeterDistance.value * ratePerKm;

    // Set meter status on Firestore
    FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .update({
      'meterStatus': 'on',
      'startMeterTime': Timestamp.now(),
      'meterStartLocation': {
        'latitude': Constant.currentLocation?.latitude ?? 0.0,
        'longitude': Constant.currentLocation?.longitude ?? 0.0,
      },
    });

    _taxiMeterTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      GeoPoint currentLocation =
          GeoPoint(currentPosition.latitude, currentPosition.longitude);

      // Update driver location always
      await FirebaseFirestore.instance
          .collection(CollectionName.orders)
          .doc(orderModel.id)
          .update({
        "driverLocation": currentLocation,
        "updatedAt": Timestamp.now(),
      });

      // Only calculate fare if ride in progress
      if (orderModel.status == Constant.rideInProgress) {
        double lastLat = _lastSavedLocation?.latitude ?? currentLocation.latitude;
        double lastLng = _lastSavedLocation?.longitude ?? currentLocation.longitude;

        double distanceIncrement = Geolocator.distanceBetween(
              lastLat,
              lastLng,
              currentLocation.latitude,
              currentLocation.longitude,
            ) /
            1000; // meters -> km

        // Use local taxiMeterDistance to accumulate
        taxiMeterDistance.value += distanceIncrement;

        // Update Firestore with rounded distance
        String distanceStr = taxiMeterDistance.value.toStringAsFixed(2);
        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({"distance": distanceStr});

        // Update fare
        taxiMeterFare.value = taxiMeterDistance.value * ratePerKm;
        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({'meterFare': taxiMeterFare.value});
        orderModel.finalRate = taxiMeterFare.value.toString();

        _lastSavedLocation = currentLocation;
        _lastMovedTime = DateTime.now();

        print("[TaxiMeter] Distance: $distanceStr km, Fare: ${taxiMeterFare.value}");
      }
    });
  }

// Stop taxi meter
  void stopTaxiMeter(OrderModel orderModel) {
    if (!taxiMeterActive.value) return;

    print("[TaxiMeter] Stopping taxi meter...");
    taxiMeterActive.value = false;

    _taxiMeterTimer?.cancel();
    _taxiMeterTimer = null;

    FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .update({'meterStatus': 'off'});

    // Optional: finalize meter fare
    orderModel.finalRate = taxiMeterFare.value.toString();
    FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .update({'finalRate': orderModel.finalRate});

    print("[TaxiMeter] Final fare recorded: ${taxiMeterFare.value}");
  }
}
