import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../constant/collection_name.dart';
import '../model/order_model.dart';

class ActiveOrderController extends GetxController {
  HomeController homeController = Get.put(HomeController());
  Rx<TextEditingController> otpController = TextEditingController().obs;

  Timer? _locationUpdateTimer;
  GeoPoint? _lastSavedLocation;
  DateTime? _lastMovedTime;
  final RxBool _userShouldBeNotified = false.obs;
  String? _activeOrderId;

  // ðŸ” New: Real-time watch for customer's live tracking
  bool _customerIsWatching = false;
  StreamSubscription<DocumentSnapshot>? _customerWatchSubscription;

  void startLocationUpdates(OrderModel orderModel) {
    if (_activeOrderId == orderModel.id) return;

    stopLocationUpdates(); // clear previous session
    _activeOrderId = orderModel.id;

    _lastSavedLocation = null;
    _lastMovedTime = DateTime.now();

    // ðŸ” Listen to customer's live tracking view
    _customerWatchSubscription = FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .snapshots()
        .listen((doc) {
      _customerIsWatching = doc.data()?["customerIsWatchingLiveTracking"] ?? false;
      print("[Tracking] Customer is ${_customerIsWatching ? '' : 'NOT '}watching live tracking.");
    });

    _locationUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      print("[Tracking] Timer tick - checking location...");

      if (!_customerIsWatching) {
        print("[Tracking] Skipped location update â€” customer not watching.");
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      GeoPoint currentLocation = GeoPoint(currentPosition.latitude, currentPosition.longitude);
      print("[Tracking] Current location: ${currentPosition.latitude}, ${currentPosition.longitude}");

      if (_lastSavedLocation == null ||
          Geolocator.distanceBetween(
            _lastSavedLocation!.latitude,
            _lastSavedLocation!.longitude,
            currentLocation.latitude,
            currentLocation.longitude,
          ) > 1) {
        await FirebaseFirestore.instance.collection(CollectionName.orders).doc(orderModel.id).update({
          "driverLocation": currentLocation,
          "updatedAt": Timestamp.now(),
        });
        print("[Tracking] Location updated to Firestore: ${currentLocation.latitude}, ${currentLocation.longitude}");

        _lastSavedLocation = currentLocation;
        _lastMovedTime = DateTime.now();
      }

      bool shouldNotify = DateTime.now().difference(_lastMovedTime!).inMinutes >= 4;
      if (shouldNotify != _userShouldBeNotified.value) {
        _userShouldBeNotified.value = shouldNotify;

        await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.id)
            .update({"notifyUserIfDriverIsNotMovingEvenRideActive": shouldNotify});

        print("[Tracking] Updated notifyUserIfDriverIsNotMovingEvenRideActive = $shouldNotify");
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
}
