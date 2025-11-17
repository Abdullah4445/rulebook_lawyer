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
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../controller/order_controller.dart';
import '../../model/wallet_transaction_model.dart';

class ActiveOrderScreen extends StatelessWidget {
   ActiveOrderScreen({Key? key}) : super(key: key);
  final corderController = Get.put(OrderController());
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<ActiveOrderController>(
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
                child: Text("No active rides Found".tr),
              )
                  : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    OrderModel orderModel = OrderModel.fromJson(
                        snapshot.data!.docs[index].data()
                        as Map<String, dynamic>);

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
                                color: Colors.grey.withOpacity(0.5),
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

                                // LOCATION UPAR - "Confirm Case Completed" button se pehle
                                LocationView(
                                  sourceLocation:
                                  orderModel.sourceLocationName.toString(),
                                  destinationLocation: orderModel
                                      .destinationLocationName
                                      .toString(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                // CONFIRM CASE COMPLETED BUTTON
                                ButtonThem.buildBorderButton(
                                  context,
                                  title: "Confirm Case Completed".tr,
                                  btnHeight: 44,
                                  iconVisibility: false,
                                  onPress: () async {
                                    Get.to(
                                      LiveTrackingScreen(
                                        orderModel: orderModel,
                                      ),
                                      arguments: {
                                        "driverLatLng": LatLng(
                                          Constant.currentLocation?.latitude ??
                                              0.0,
                                          Constant.currentLocation?.longitude ??
                                              0.0,
                                        ),
                                        "customerLatLng": LatLng(
                                          orderModel.sourceLocationLatLng
                                              ?.latitude ??
                                              0.0,
                                          orderModel.sourceLocationLatLng
                                              ?.longitude ??
                                              0.0,
                                        ),
                                        "type": "routeOnly",
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                // BOTTOM BUTTONS ROW
                                Row(
                                  children: [
                                    Expanded(
                                      child: orderModel.status ==
                                          Constant.caseInProgress
                                          ? ButtonThem.buildBorderButton(
                                        context,
                                        title: "Complete Ride".tr,
                                        btnHeight: 44,
                                        iconVisibility: false,
                                        onPress: () async {
                                          orderModel.status =
                                              Constant.caseComplete;

                                          controller.stopLocationUpdates();

                                          await FireStoreUtils.getCustomer(
                                              orderModel.userId
                                                  .toString())
                                              .then((value) async {
                                            if (value != null) {
                                              if (value.fcmToken != null) {
                                                Map<String, dynamic>
                                                playLoad =
                                                <String, dynamic>{
                                                  "type":
                                                  "city_order_complete",
                                                  "orderId": orderModel.id
                                                };

                                                await SendNotification
                                                    .sendOneNotification(
                                                    token: value.fcmToken
                                                        .toString(),
                                                    title:
                                                    'Ride complete!'
                                                        .tr,
                                                    body:
                                                    'Please complete your payment.'
                                                        .tr,
                                                    payload: playLoad);
                                              }
                                            }
                                          });

                                          await FireStoreUtils.setOrder(
                                              orderModel)
                                              .then((value) {
                                            if (value == true) {
                                              ShowToastDialog.showToast(
                                                  "Ride Complete successfully"
                                                      .tr);
                                              controller.homeController
                                                  .selectedIndex.value = 3;
                                            }
                                          });
                                        },
                                      )
                                          : Container(
                                        height: 44, // Same height as other buttons
                                        child: Visibility(
                                            visible: corderController.paymentModel.value
                                                .cash!.name ==
                                                orderModel.paymentType
                                                    .toString() &&
                                                orderModel.paymentStatus == false,
                                            child: ButtonThem.buildButton(
                                              context,
                                              title: "Confirm cash payment".tr,
                                              btnHeight: 44,
                                              onPress: () async {
                                                ShowToastDialog.showLoader(
                                                    "Please wait..".tr);
                                                orderModel.paymentStatus = true;
                                                orderModel.status =
                                                    Constant.caseComplete;
                                                orderModel.updateDate =
                                                    Timestamp.now();

                                                String? couponAmount = "0.0";
                                                if (orderModel.coupon != null) {
                                                  if (orderModel.coupon?.code !=
                                                      null) {
                                                    if (orderModel.coupon!.type ==
                                                        "fix") {
                                                      couponAmount = orderModel
                                                          .coupon!.amount
                                                          .toString();
                                                    } else {
                                                      couponAmount = ((double.parse(
                                                          orderModel
                                                              .finalRate
                                                              .toString()) *
                                                          double.parse(orderModel
                                                              .coupon!.amount
                                                              .toString())) /
                                                          100)
                                                          .toString();
                                                    }
                                                  }
                                                }

                                                WalletTransactionModel
                                                adminCommissionWallet =
                                                WalletTransactionModel(
                                                    id: Constant.getUuid(),
                                                    amount:
                                                    "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
                                                    createdDate: Timestamp.now(),
                                                    paymentType: "wallet".tr,
                                                    transactionId: orderModel.id,
                                                    orderType: "city",
                                                    userType: "driver",
                                                    userId: orderModel.driverId
                                                        .toString(),
                                                    note:
                                                    "Admin commission debited"
                                                        .tr);

                                                await FireStoreUtils
                                                    .setWalletTransaction(
                                                    adminCommissionWallet)
                                                    .then((value) async {
                                                  if (value == true) {
                                                    await FireStoreUtils
                                                        .updatedDriverWallet(
                                                        amount:
                                                        "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}");
                                                  }
                                                });

                                                await FireStoreUtils.getCustomer(
                                                    orderModel.userId.toString())
                                                    .then((value) async {
                                                  if (value != null) {
                                                    await SendNotification
                                                        .sendOneNotification(
                                                        token: value.fcmToken
                                                            .toString(),
                                                        title:
                                                        'Cash Payment confirmed'
                                                            .tr,
                                                        body:
                                                        'Driver has confirmed your cash payment'
                                                            .tr,
                                                        payload: {});
                                                  }
                                                });

                                                await FireStoreUtils
                                                    .getFirestOrderOrNOt(
                                                    orderModel)
                                                    .then((value) async {
                                                  if (value == true) {
                                                    await FireStoreUtils
                                                        .updateReferralAmount(
                                                        orderModel);
                                                  }
                                                });

                                                await FireStoreUtils.setOrder(
                                                    orderModel)
                                                    .then((value) {
                                                  if (value == true) {
                                                    ShowToastDialog.closeLoader();
                                                    ShowToastDialog.showToast(
                                                        "Payment Confirm successfully"
                                                            .tr);
                                                  }
                                                });
                                              },
                                            )),
                                      ),
                                    ),

                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                  height: 10,
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
                                            await _notifyCustomerAndCancelOrder(
                                                orderModel);

                                            Get.back();
                                          },
                                          onCancel: () {
                                            Get.back();
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

  otpDialog(
      BuildContext context, ActiveOrderController controller, OrderModel orderModel) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text("OTP verify from customer".tr,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.black)),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: PinCodeTextField(
                textStyle: TextStyle(color: Colors.black87),
                length: 6,
                appContext: context,
                keyboardType: TextInputType.phone,
                pinTheme: PinTheme(
                  fieldHeight: 40,
                  fieldWidth: 40,
                  activeColor: themeChange.getThem()
                      ? AppColors.darkTextFieldBorder
                      : AppColors.textFieldBorder,
                  selectedColor: themeChange.getThem()
                      ? AppColors.darkTextFieldBorder
                      : AppColors.textFieldBorder,
                  inactiveColor: themeChange.getThem()
                      ? AppColors.darkTextFieldBorder
                      : AppColors.textFieldBorder,
                  activeFillColor: themeChange.getThem()
                      ? AppColors.darkTextField
                      : AppColors.textField,
                  inactiveFillColor: themeChange.getThem()
                      ? AppColors.darkTextField
                      : AppColors.textField,
                  selectedFillColor: themeChange.getThem()
                      ? AppColors.darkTextField
                      : AppColors.textField,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                ),
                enableActiveFill: true,
                cursorColor: AppColors.primary,
                controller: controller.otpController.value,
                onCompleted: (v) async {},
                onChanged: (value) {},
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ButtonThem.buildButton(context, title: "OTP verify".tr, onPress: () async {
              if (orderModel.otp.toString() == controller.otpController.value.text) {
                Get.back();
                ShowToastDialog.showLoader("Please wait...".tr);
                orderModel.status = Constant.caseInProgress;

                await FireStoreUtils.getCustomer(orderModel.userId.toString())
                    .then((value) async {
                  if (value != null) {
                    await SendNotification.sendOneNotification(
                        token: value.fcmToken.toString(),
                        title: 'Ride Started'.tr,
                        body:
                        'The ride has officially started. Please follow the designated route to the destination.'
                            .tr,
                        payload: {});
                  }
                });

                await FireStoreUtils.setOrder(orderModel).then((value) {
                  if (value == true) {
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast("Customer pickup successfully".tr);
                  }
                });
              } else {
                ShowToastDialog.showToast("OTP Invalid".tr,
                    position: EasyLoadingToastPosition.center);
              }
            }),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _notifyCustomerAndCancelOrder(OrderModel orderModel) async {
  try {
    UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());

    if (customer != null && customer.fcmToken!.isNotEmpty) {
      await SendNotification.sendOneNotification(
        token: customer.fcmToken.toString(),
        title: 'ride_cancelled_title'.tr,
        body: 'ride_cancelled_body_customer'.tr,
        payload: {
          'orderId': orderModel.id,
          'type': 'ride_cancelled',
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
  }

  orderModel.status = Constant.caseCanceled;
  orderModel.acceptedDriverId = [];
  orderModel.driverId = null;
  orderModel.updateDate = Timestamp.now();

  try {
    await FireStoreUtils.setOrder(orderModel);
    print(
        "Order ${orderModel.id} cancelled successfully and status updated in Firestore.");
  } catch (e) {
    print("Error updating order ${orderModel.id} status to cancelled in Firestore: $e");
  }
}