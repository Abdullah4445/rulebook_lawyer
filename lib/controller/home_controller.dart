import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/order/positions.dart';
import 'package:driver/ui/home_screens/accepted_orders.dart';
import 'package:driver/ui/home_screens/active_order_screen.dart';
import 'package:driver/ui/home_screens/completed_orders.dart';
import 'package:driver/ui/home_screens/new_orders_screen.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:driver/widget/geoflutterfire/src/models/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as lo;
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/order_model.dart';
import '../utils/notification_service.dart';
import '../utils/utils.dart';
import 'global_setting_conroller.dart';

class HomeController extends GetxController {
  // added new variable for testing
  RxList<OrderModel> availableRides = <OrderModel>[].obs;

  RxInt selectedIndex = 0.obs;
  List<Widget> widgetOptions = <Widget>[const NewOrderScreen(), const AcceptedOrders(),     ActiveOrderScreen(),const CompletedOrders()];
  DashBoardController dashboardController = Get.put(DashBoardController());

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getDriver();
    getActiveRide();
    notificationInit();
    /// added function in the oninit function
    getAvailableRides();

    _listenToCallEvents();

    super.onInit();
  }

  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxBool isLoading = true.obs;

  getDriver() async {
    print("BILAL getting driver details:");

    FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((event) {
      if (event.exists) {
        driverModel.value = DriverUserModel.fromJson(event.data()!);
      }
    });
    updateCurrentLocation();
  }

  RxInt isActiveValue = 0.obs;

  getActiveRide() {
    FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('status', whereIn: [Constant.caseInProgress, Constant.caseActive])
        .snapshots()
        .listen((event) {
      isActiveValue.value = event.size;
        });
  }

  lo.Location location = lo.Location();
/// added new function for checking and testing the available rides for driver
  void getAvailableRides() {
    FirebaseFirestore.instance
        .collection(CollectionName.orders)
        .where('status', isEqualTo: "Case Placed")
        .where('driverId', isNull: true)
        .snapshots()
        .listen((event) {
      print("🚖 Available Rides: ${event.docs.length}");
      availableRides.value =
          event.docs.map((e) => OrderModel.fromJson(e.data())).toList();
    });
  }
  void acceptRide(String? rideId)
  async {
    try {
      // get current driver info
      final driver = driverModel.value;

      // Firestore collection update
      await FirebaseFirestore.instance
          .collection(CollectionName.orders)
          .doc(rideId)
          .update({
        'driverId': driver.id,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Ride accepted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to accept ride: $e");
    }
  }



  updateCurrentLocation() async {
    print("BILAL getting driver details: location");
    lo.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      location.changeSettings(accuracy: lo.LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),interval: 2000);
      print("BILAL getting driver details: location2");
      location.onLocationChanged.listen((locationData) {
        Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
        FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
          DriverUserModel driverUserModel = value!;
          if (driverUserModel.isOnline == true) {
            driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            GeoFirePoint position = Geoflutterfire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);
            driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
            driverUserModel.rotation = locationData.heading;
            FireStoreUtils.updateDriverUser(driverUserModel);
          }
        });
      });
    } else {
      print("not granted");
      location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(accuracy: lo.LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),interval: 2000);
          location.onLocationChanged.listen((locationData) async {
            Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);

            FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
              DriverUserModel driverUserModel = value!;
              if (driverUserModel.isOnline == true) {
                driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
                driverUserModel.rotation = locationData.heading;
                GeoFirePoint position = Geoflutterfire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);

                driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);

                FireStoreUtils.updateDriverUser(driverUserModel);
              }
            });
          });
        }
      });
    }
    isLoading.value = false;
    update();
  }



  Future<void> setupFCMToken(String driverId) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    String? token = await _firebaseMessaging.getToken();
    print("New token for this driver is: $token");
    if (token != null) {
      await _updateTokenInFirestore(driverId, token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _updateTokenInFirestore(driverId, newToken);
    });
  }


  void _listenToCallEvents() async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallAccept:
          print("✅ Driver accepted the ride request.");

          // ✅ Navigate to the page


          // ✅ End the call UI after a short delay
          await Future.delayed(Duration(seconds: 2));
          await FlutterCallkitIncoming.endCall(event.body['id']);

          break;

        case Event.actionCallDecline:
          print("❌ Driver declined the ride request.");
          break;

        case Event.actionCallTimeout:
          print("⏳ Missed ride request.");
          break;

        case Event.actionCallEnded:
          print("🔚 Call ended.");
          break;

        default:
          print("ℹ️ Unhandled CallKit event: ${event.event}");
          break;
      }
    });
  }



  Future<void> _updateTokenInFirestore(String driverId, String token) async {
    await FirebaseFirestore.instance
        .collection('driver_users')
        .doc(driverId)
        .update({'fcmToken': token});
    print("✅ FCM Token Updated in Firestore: $token");
  }


  ///Permissions from the app


  void notificationInit() {
    NotificationService().initInfo().then((_) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await setupFCMToken(user.uid);
      }
    });
  }

}
