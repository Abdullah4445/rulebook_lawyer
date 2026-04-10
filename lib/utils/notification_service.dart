import 'dart:convert';
import 'dart:developer';

import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/intercity_order_model.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/model/user_model.dart';
import 'package:lawyer/ui/chat_screen/chat_screen.dart';
import 'package:lawyer/ui/home_screens/order_map_screen.dart';
import 'package:lawyer/ui/order_intercity_screen/complete_intecity_order_screen.dart';
import 'package:lawyer/ui/order_screen/complete_order_screen.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';




class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) {
            return;
          }

          try {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(jsonDecode(payload));
            _handleNotificationNavigation(data);
          } catch (e) {
            log('Failed to parse notification payload: $e');
          }
        },
      );
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
    }

    // if (initialMessage != null) {
    //   log('Message also contained a notification: ${initialMessage.notification!.body}');
    // }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.data.toString());
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log("::::::::::::onMessageOpenedApp:::::::::::::::::");
      if (message.notification != null) {
        log(message.data.toString());
        _handleNotificationNavigation(message.data);
      }
    });

    await FirebaseMessaging.instance.subscribeToTopic("rulebook_lawyer");

  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      final notificationContent = _buildProfessionalNotificationContent(message);
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'rulebook_lawyer_channel',
        'Rulebook Lawyer Notifications',
        description: 'Professional legal services notifications',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name, channelDescription: 'Rulebook Lawyer notifications', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        notificationContent['title'],
        notificationContent['body'],
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Map<String, String> _buildProfessionalNotificationContent(RemoteMessage message) {
    final String type = (message.data['type'] ?? '').toString().toLowerCase();
    final String title = (message.notification?.title ?? '').trim();
    final String body = (message.notification?.body ?? '').trim();

    if (type == 'new_ride' || type == 'city_order' || _containsLegacyRideCopy(title, body)) {
      return {
        'title': 'New Case Request',
        'body': 'A new legal case is available for review. Open the app to view the case details.',
      };
    }

    return {
      'title': title,
      'body': body,
    };
  }

  bool _containsLegacyRideCopy(String title, String body) {
    final combined = '${title.toLowerCase()} ${body.toLowerCase()}';
    return combined.contains('ride') ||
        combined.contains('pedido') ||
        combined.contains('order id') ||
        combined.contains('un cliente necesita un viaje');
  }

  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    final String type = (data['type'] ?? '').toString();

    if (type == "city_order" || type == "new_ride") {
      Get.to(const OrderMapScreen(), arguments: {"orderModel": data['orderId']});
    } else if (type == "city_order_payment_complete") {
      OrderModel? orderModel = await FireStoreUtils.getOrder(data['orderId']);
      Get.to(const CompleteOrderScreen(), arguments: {
        "orderModel": orderModel,
      });
    } else if (type == "intercity_order_payment_complete") {
      InterCityOrderModel? orderModel = await FireStoreUtils.getInterCityOrder(data['orderId']);
      Get.to(const CompleteIntercityOrderScreen(), arguments: {
        "orderModel": orderModel,
      });
    } else if (type == "chat") {
      UserModel? customer = await FireStoreUtils.getCustomer(data['customerId']);
      DriverUserModel? driver = await FireStoreUtils.getDriverProfile(data['driverId']);

      if (customer == null || driver == null) {
        return;
      }

      Get.to(ChatScreens(
        driverId: driver.id,
        customerId: customer.id,
        customerName: customer.fullName,
        customerProfileImage: customer.profilePic,
        driverName: driver.fullName,
        driverProfileImage: driver.profilePic,
        orderId: data['orderId'],
        token: customer.fcmToken,
      ));
    }
  }
}
