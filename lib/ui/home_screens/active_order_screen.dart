import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/active_order_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/home_screens/live_tracking_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../model/order/driverId_accept_reject.dart';
import '../faredetails_screen/faredetails_screen.dart';

class ActiveOrderScreen extends StatelessWidget {
  const ActiveOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return
      // Text("BILAL");

      GetBuilder<ActiveOrderController>(
          init: ActiveOrderController(),
          builder: (controller) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(CollectionName.orders)
                  .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
                  .where('status', whereIn: [
                Constant.caseInProgress,
                Constant.caseActive
              ]).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong'.tr);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Constant.loader(context);
                }
                return snapshot.data!.docs.isEmpty
                    ? Center(
                  child: Text("No active cases Found".tr),
                )
                    : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      print("BILAL Saeed");
                      Map<String, dynamic> data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      print(data['sourceLocationName']);
                      print(data['sourceLocationLatLng']);
                      OrderModel orderModel = OrderModel.fromJson(
                          snapshot.data!.docs[index].data()
                          as Map<String, dynamic>);
                      print('-----');
                      print(orderModel.sourceLocationLatLng?.latitude.toString());
                      print(orderModel.sourceLocationLatLng?.longitude.toString());

                      if ((orderModel.status == Constant.caseInProgress ||
                          orderModel.status == Constant.caseActive)) {
                        controller.startLocationUpdates(orderModel);
                      }
                      return InkWell(
                        onTap: () {
                          if (Constant.mapType == "inappmap") {
                            if (orderModel.status == Constant.caseActive ||
                                orderModel.status == Constant.caseInProgress) {
                              Get.to(LiveTrackingScreen(), arguments: {
                                "orderModel": orderModel,
                                "type": "orderModel",
                              });
                            }
                          } else {
                            if (orderModel.status == Constant.caseInProgress) {
                              Utils.redirectMap(
                                  curName: orderModel.sourceLocationName!,
                                  curLat:
                                  orderModel.sourceLocationLatLng!.latitude!,
                                  curLon:
                                  orderModel.sourceLocationLatLng!.longitude!,
                                  latitude: orderModel
                                      .destinationLocationLatLng!.latitude!,
                                  longLatitude: orderModel
                                      .destinationLocationLatLng!.longitude!,
                                  name: orderModel.destinationLocationName
                                      .toString());
                            } else {
                              Utils.redirectMap(
                                  curName: orderModel.sourceLocationName!,
                                  curLat:
                                  orderModel.sourceLocationLatLng!.latitude!,
                                  curLon:
                                  orderModel.sourceLocationLatLng!.longitude!,
                                  latitude: orderModel
                                      .destinationLocationLatLng!.latitude!,
                                  longLatitude: orderModel
                                      .destinationLocationLatLng!.longitude!,
                                  name: orderModel.destinationLocationName
                                      .toString());
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppColors.darkContainerBackground
                                  : AppColors.containerBackground,
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: themeChange.getThem()
                                      ? AppColors.darkContainerBorder
                                      : AppColors.containerBorder,
                                  width: 0.5),
                              boxShadow: themeChange.getThem()
                                  ? null
                                  : [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(128), // replaced withOpacity(0.5)
                                  blurRadius: 8,
                                  offset: const Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Column(
                                children: [
                                  UserView(
                                    userId: orderModel.userId,
                                    amount: orderModel.finalRate,
                                    distance: orderModel.distance,
                                    distanceType: orderModel.distanceType,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(),
                                  ),
                                  // ButtonThem.buildBorderButton(
                                  //   context,
                                  //   title: "Show Route to Customer".tr,
                                  //   btnHeight: 44,
                                  //   iconVisibility: false,
                                  //   onPress: () async {
                                  //     // print("My order details are: ");
                                  //     // print( orderModel.toJson());
                                  //
                                  //     Get.to(
                                  //       LiveTrackingScreen(
                                  //         orderModel: orderModel,
                                  //       ),
                                  //       arguments: {
                                  //         "driverLatLng": LatLng(
                                  //           Constant.currentLocation?.latitude ??
                                  //               0.0,
                                  //           Constant.currentLocation?.longitude ??
                                  //               0.0,
                                  //         ),
                                  //         "customerLatLng": LatLng(
                                  //           orderModel.sourceLocationLatLng
                                  //               ?.latitude ??
                                  //               0.0,
                                  //           orderModel.sourceLocationLatLng
                                  //               ?.longitude ??
                                  //               0.0,
                                  //         ),
                                  //         "type": "routeOnly",
                                  //       },
                                  //     );
                                  //     // Get.to(
                                  //     //   const LiveTrackingScreen(),
                                  //     //   arguments: {
                                  //     //     "driverLatLng": Constant.currentLocation,
                                  //     //     "customerLatLng": orderModel.sourceLocationLatLng,
                                  //     //     "type": "routeOnly",
                                  //     //   },
                                  //     // );
                                  //   },
                                  // ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(),
                                  ),
                                  LocationView(
                                    sourceLocation:
                                    orderModel.sourceLocationName.toString(),
                                    // destinationLocation: orderModel
                                    //     .destinationLocationName
                                    //     .toString(),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),


                                  FutureBuilder<DriverIdAcceptReject?>(
                                    future: FireStoreUtils.getAcceptedOrders(
                                      orderModel.id.toString(),
                                      FireStoreUtils.getCurrentUid(),
                                    ),
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Constant.loader(context);

                                        case ConnectionState.done:
                                          if (snapshot.hasError) {
                                            return Text(snapshot.error.toString());
                                          } else if (!snapshot.hasData || snapshot.data == null) {
                                            return SizedBox();
                                          } else {
                                            final driverIdAcceptReject = snapshot.data!;

                                            // 🔥 Fare Details container
                                            if (driverIdAcceptReject.fareDetails != null) {
                                              final fareDetails = driverIdAcceptReject.fareDetails!;
                                              final steps = fareDetails['steps'] != null
                                                  ? List<Map<String, dynamic>>.from(fareDetails['steps'])
                                                  : <Map<String, dynamic>>[];

                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                child: StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Get.to(() => FareDetailsScreen(
                                                          orderId: orderModel.id?.toString() ?? "",
                                                          acceptedDriverId: driverIdAcceptReject.driverId?.toString() ?? "",
                                                          fareDetails: driverIdAcceptReject.fareDetails ?? {},
                                                        ));
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: themeChange.getThem()
                                                              ? AppColors.darkContainerBackground
                                                              : AppColors.containerBackground,
                                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                          border: Border.all(
                                                            color: themeChange.getThem()
                                                                ? AppColors.darkContainerBorder
                                                                : AppColors.containerBorder,
                                                            width: 0.5,
                                                          ),
                                                          boxShadow: themeChange.getThem()
                                                              ? null
                                                              : [
                                                            BoxShadow(
                                                              color: Colors.black.withAlpha(26), // replaced withOpacity(0.10)
                                                              blurRadius: 5,
                                                              offset: const Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(12),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "Billing Details".tr,
                                                                style: GoogleFonts.poppins(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Colors.black),
                                                              ),
                                                              const SizedBox(height: 8),

                                                              // Steps
                                                              ...steps.map((stepEntry) {
                                                                final step = Map<String, dynamic>.from(stepEntry);
                                                                return Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              step['title']?.toString() ?? '',
                                                                              style: GoogleFonts.poppins(
                                                                                  fontSize: 14, color: Colors.black87),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            Constant.amountShow(
                                                                                amount: step['price']?.toString() ?? '0'),
                                                                            style: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.black),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    // per-step buttons removed to show single pair inside fare container

                                                                  ],
                                                                );
                                                              }).toList(),

                                                              const Divider(height: 20),

                                                              // Total
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Total".tr,
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize: 15, fontWeight: FontWeight.bold,color: Colors.black),
                                                                  ),
                                                                  Text(
                                                                    Constant.amountShow(
                                                                        amount: fareDetails['total']?.toString() ?? '0'),
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize: 15, fontWeight: FontWeight.bold,color: Colors.black),
                                                                  ),
                                                                ],
                                                              ),

                                                              const SizedBox(height: 12),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          }

                                        default:
                                          return Text('Error'.tr);
                                      }
                                    },
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: orderModel.status == Constant.caseInProgress
                                              ? ButtonThem.buildBorderButton(
                                                  context,
                                                  title: "Complete Case".tr,
                                                  btnHeight: 44,
                                                  iconVisibility: false,
                                                  onPress: () async {
                                                    ShowToastDialog.showLoader("Please wait...".tr);
                                                    // Require fare approval from both lawyer and customer before completing
                                                    final approved = await _isFareFullyApproved(orderModel.id);
                                                    if (!approved) {
                                                      ShowToastDialog.closeLoader();
                                                      ShowToastDialog.showToast(
                                                          "Please complete billing from customer and lawyer before completing the case".tr);
                                                      return;
                                                    }
                                                    // Immediately complete the order
                                                    orderModel.status = Constant.caseComplete;
                                                    // Also mark payment as confirmed when driver completes the case
                                                    orderModel.paymentStatus = true;
                                                    try {
                                                      controller.stopLocationUpdates();
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    try {
                                                      final customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                                      if (customer != null && (customer.fcmToken ?? '').isNotEmpty) {
                                                        final playLoad = {"type": "city_order_complete", "orderId": orderModel.id};
                                                        await SendNotification.sendOneNotification(
                                                          token: customer.fcmToken.toString(),
                                                          title: 'Case complete!'.tr,
                                                          body: 'Please complete your payment.'.tr,
                                                          payload: playLoad,
                                                        );
                                                      }
                                                    } catch (e) {
                                                      print('Notification error: $e');
                                                    }
                                                    orderModel.updateDate = Timestamp.now();
                                                    final success = await FireStoreUtils.setOrder(orderModel);
                                                    ShowToastDialog.closeLoader();
                                                    if (success == true) {
                                                      ShowToastDialog.showToast("Case Complete successfully".tr);
                                                      controller.homeController.selectedIndex.value = 3;
                                                    } else {
                                                      ShowToastDialog.showToast("Failed to complete case".tr);
                                                    }
                                                  },
                                                )
                                              : ButtonThem.buildBorderButton(
                                                  context,
                                                  title: "Case completed".tr,
                                                  btnHeight: 74,
                                                  iconVisibility: false,
                                                  onPress: () async {
                                                    // Require fare approval from both lawyer and customer before completing
                                                    ShowToastDialog.showLoader("Please wait...".tr);
                                                    final approved = await _isFareFullyApproved(orderModel.id);
                                                    if (!approved) {
                                                      ShowToastDialog.closeLoader();
                                                      ShowToastDialog.showToast(
                                                          "Please complete billing from customer and lawyer before completing the case".tr);
                                                      return;
                                                    }

                                                    // Immediately complete the order
                                                    orderModel.status = Constant.caseComplete;
                                                    // Also mark payment as confirmed when driver completes the case
                                                    orderModel.paymentStatus = true;
                                                    try {
                                                      controller.stopLocationUpdates();
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    try {
                                                      final customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                                      if (customer != null && (customer.fcmToken ?? '').isNotEmpty) {
                                                        final playLoad = {"type": "city_order_complete", "orderId": orderModel.id};
                                                        await SendNotification.sendOneNotification(
                                                          token: customer.fcmToken.toString(),
                                                          title: 'Case complete!'.tr,
                                                          body: 'Please complete your payment.'.tr,
                                                          payload: playLoad,
                                                        );
                                                      }
                                                    } catch (e) {
                                                      print('Notification error: $e');
                                                    }
                                                    orderModel.updateDate = Timestamp.now();
                                                    final success = await FireStoreUtils.setOrder(orderModel);
                                                    ShowToastDialog.closeLoader();
                                                    if (success == true) {
                                                      ShowToastDialog.showToast("Case Complete successfully".tr);
                                                      controller.homeController.selectedIndex.value = 3;
                                                    } else {
                                                      ShowToastDialog.showToast("Failed to complete case".tr);
                                                    }
                                                  },
                                                ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              UserModel? customer =
                                              await FireStoreUtils.getCustomer(
                                                  orderModel.userId.toString());
                                              DriverUserModel? driver =
                                              await FireStoreUtils
                                                  .getDriverProfile(orderModel
                                                  .driverId
                                                  .toString());

                                              Get.to(ChatScreens(
                                                driverId: driver!.id,
                                                customerId: customer!.id,
                                                customerName: customer.fullName,
                                                customerProfileImage:
                                                customer.profilePic,
                                                driverName: driver.fullName,
                                                driverProfileImage:
                                                driver.profilePic,
                                                orderId: orderModel.id,
                                                token: customer.fcmToken,
                                              ));
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary,
                                                  borderRadius:
                                                  BorderRadius.circular(5)),
                                              child: Icon(Icons.chat,
                                                  color: themeChange.getThem()
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              UserModel? customer =
                                              await FireStoreUtils.getCustomer(
                                                  orderModel.userId.toString());
                                              Constant.makePhoneCall(
                                                  "${customer!.countryCode}${customer.phoneNumber}");
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary,
                                                  borderRadius:
                                                  BorderRadius.circular(5)),
                                              child: Icon(Icons.call,
                                                  color: themeChange.getThem()
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              Get.defaultDialog(
                                                title: 'cancel_ride_title'.tr,
                                                middleText:
                                                'cancel_ride_message'.tr,
                                                textCancel: 'no'.tr,
                                                textConfirm: 'yes'.tr,
                                                confirmTextColor: Colors.black87,
                                                cancelTextColor: Colors.black87,
                                                onConfirm: () async {
// 2) Helper: notify assigned/accepted drivers, then cancel order

                                                  await _notifyCustomerAndCancelOrder(
                                                      orderModel);

                                                  Get.back(); // close dialog after confirm
                                                },
                                                onCancel: () {
                                                  Get.back(); // just close if user presses "No"
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppColors.darkModePrimary
                                                      : AppColors.primary,
                                                  borderRadius:
                                                  BorderRadius.circular(5)),
                                              child: Icon(Icons.close,
                                                  color: themeChange.getThem()
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              },
            );
          });
  }
}

Future<void> _notifyCustomerAndCancelOrder(OrderModel orderModel) async {
  // 1. Notify the Customer associated with the order
  try {
    // Fetch the customer details using userId from the orderModel
    UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());

    if (customer != null && customer.fcmToken!.isNotEmpty) {
      await SendNotification.sendOneNotification(
        token: customer.fcmToken.toString(),
        title: 'ride_cancelled_title'.tr, // Use a specific title for cancellation
        body: 'ride_cancelled_body_customer'
            .tr, // Use a specific body for cancellation for the customer
        payload: {
          'orderId': orderModel.id,
          'type':
          'ride_cancelled', // You can use a specific type for client-side handling
        },
      );
    } else {
      if (customer == null) {
        print("Error: Customer not found for ID ${orderModel.userId}");
      } else if (customer.fcmToken!.isEmpty) {
        print(
            "Warning: Customer ${customer.id} has no FCM token. Cannot send cancellation notification.");
      }
    }
  } catch (e) {
    print("Error sending cancellation notification to customer ${orderModel.userId}: $e");
    // Decide if you want to proceed with cancellation even if notification fails
  }

  // 2. THEN update order status to Canceled
  orderModel.status = Constant.caseCanceled;
  // Clear any driver associations as the ride is cancelled
  orderModel.acceptedDriverId = []; // Clear list of accepted drivers
  orderModel.driverId = null; // No active driver after cancellation
  orderModel.updateDate = Timestamp.now(); // Update the modification time

  try {
    await FireStoreUtils.setOrder(orderModel);
    print(
        "Order ${orderModel.id} cancelled successfully and status updated in Firestore.");
  } catch (e) {
    print("Error updating order ${orderModel.id} status to cancelled in Firestore: $e");
    // Handle this error appropriately - the order might be cancelled in the app
    // but not in the database, which could lead to inconsistencies.
  }
}

// Helper: check that fare details (for the acceptedDriver record) are marked done by both lawyer and customer
Future<bool> _isFareFullyApproved(String? orderId) async {
  if (orderId == null) return false;
  try {
    final accepted = await FireStoreUtils.getAcceptedOrders(orderId.toString(), FireStoreUtils.getCurrentUid());
    if (accepted == null) return false;
    final fareDetails = accepted.fareDetails;
    if (fareDetails == null) return false;

    List steps = [];
    final type = fareDetails['type']?.toString();

    if (type == 'multi_steps') {
      if (fareDetails['steps'] is List) {
        steps = List<Map<String, dynamic>>.from(fareDetails['steps']);
      } else if (fareDetails['steps'] is Map) {
        steps = (fareDetails['steps'] as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } else {
      // case_total or unspecified -> try to normalize
      if (fareDetails['steps'] is List) {
        steps = List<Map<String, dynamic>>.from(fareDetails['steps']);
      } else if (fareDetails['steps'] is Map) {
        steps = (fareDetails['steps'] as Map).values
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        // build single-step from top-level fields if present
        steps = [
          {
            'lawyerStatus': fareDetails['lawyerStatus'] ?? 'pending',
            'customerStatus': fareDetails['customerStatus'] ?? 'pending',
          }
        ];
      }
    }

    if (steps.isEmpty) return false;

    for (var s in steps) {
      final lawyer = (s['lawyerStatus'] ?? s['lawyerstatus'] ?? '').toString().toLowerCase();
      final customer = (s['customerStatus'] ?? s['customerstatus'] ?? '').toString().toLowerCase();
      if (lawyer != 'done' || customer != 'done') return false;
    }

    return true;
  } catch (e) {
    print('Error checking fare approval: $e');
    return false;
  }
}
