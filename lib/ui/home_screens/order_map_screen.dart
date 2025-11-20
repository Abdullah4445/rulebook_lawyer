import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/order_map_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as myOsm;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class OrderMapScreen extends StatelessWidget {
  const OrderMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<OrderMapController>(
        init: OrderMapController(),
        builder: (controller) {
          print(
              "My current locations is: ${Constant.currentLocation?.longitude.toString()}");
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  )),
            ),
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Column(
                    children: [
                      Container(
                        height: Responsive.width(10, context),
                        width: Responsive.width(100, context),
                        color: AppColors.primary,
                      ),
                      Expanded(
                        child: Container(
                          transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25))),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                            child: Stack(
                              children: [
                                Constant.selectedMapType == 'osm'
                                    ? myOsm.OSMFlutter(
                                        controller: controller
                                                .mapOsmController ??
                                            myOsm.MapController(
                                                initPosition: myOsm.GeoPoint(
                                                    latitude: 20.9153,
                                                    longitude: -100.7439),
                                                useExternalTracking: false),
                                        osmOption: const myOsm.OSMOption(
                                          userTrackingOption:
                                              myOsm.UserTrackingOption(
                                            enableTracking: false,
                                            unFollowUser: false,
                                          ),
                                          zoomOption: myOsm.ZoomOption(
                                            initZoom: 12,
                                            minZoomLevel: 2,
                                            maxZoomLevel: 19,
                                            stepZoom: 1.0,
                                          ),
                                          roadConfiguration: myOsm.RoadOption(
                                            roadColor: Colors.yellowAccent,
                                          ),
                                        ),
                                        onMapIsReady: (active) async {
                                          if (active) {
                                            controller.getOSMPolyline(
                                                themeChange.getThem());
                                            ShowToastDialog.closeLoader();
                                          }
                                        })
                                    : GoogleMap(
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        mapType: MapType.terrain,
                                        zoomControlsEnabled: false,
                                        polylines: Set<Polyline>.of(
                                            controller.polyLines.values),
                                        padding: const EdgeInsets.only(
                                          top: 22.0,
                                        ),
                                        markers: Set<Marker>.of(
                                            controller.markers.values),
                                        onMapCreated: (GoogleMapController
                                            mapController) {
                                          controller.mapController
                                              .complete(mapController);
                                        },
                                        initialCameraPosition: CameraPosition(
                                          zoom: 15,
                                          target: LatLng(
                                            Constant.currentLocation
                                                    ?.latitude ??
                                                30.0421,
                                            Constant.currentLocation
                                                    ?.longitude ??
                                                72.3524,
                                          ),
                                        ),
                                      ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: themeChange.getThem()
                                            ? AppColors.darkContainerBackground
                                            : AppColors.containerBackground,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            color: themeChange.getThem()
                                                ? AppColors.darkContainerBorder
                                                : AppColors.containerBorder,
                                            width: 0.5),
                                        boxShadow: themeChange.getThem()
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              UserView(
                                                userId: controller
                                                    .orderModel.value.userId
                                                    .toString(),
                                                amount: controller
                                                    .orderModel.value.offerRate,
                                                distance: controller
                                                    .orderModel.value.distance,
                                                distanceType: controller
                                                    .orderModel
                                                    .value
                                                    .distanceType,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: Divider(),
                                              ),
                                              LocationView(
                                                  sourceLocation: controller
                                                      .orderModel
                                                      .value
                                                      .sourceLocationName
                                                      .toString(),
                                                  destinationLocation: controller
                                                                  .orderModel
                                                                  .value
                                                                  .destinationLocationName ==
                                                              null ||
                                                          (controller
                                                                  .orderModel
                                                                  .value
                                                                  .destinationLocationName
                                                                  ?.isEmpty ??
                                                              true) // ← NULL SAFE CHECK
                                                      ? "Taxi Meter Preffered for this ride"
                                                          .tr
                                                      : controller
                                                          .orderModel
                                                          .value
                                                          .destinationLocationName
                                                          .toString()),
                                              const SizedBox(height: 10),
                                              Visibility(
                                                visible: controller
                                                        .orderModel
                                                        .value
                                                        .service
                                                        ?.offerRate ==
                                                    true,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: (controller
                                                              .orderModel
                                                              .value
                                                              .destinationLocationName
                                                              ?.isEmpty ??
                                                          true) // ← NULL SAFE CHECK
                                                      ? Container()
                                                      : Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ButtonThem
                                                                .roundButton(
                                                              context,
                                                              title: "- 500",
                                                              btnWidthRatio:
                                                                  0.23,
                                                              onPress: () {
                                                                if (bool.tryParse(controller
                                                                        .newAmount
                                                                        .value) ??
                                                                    0 >= 10) {
                                                                  controller
                                                                      .newAmount
                                                                      .value = ((double.tryParse(controller.newAmount.value) ??
                                                                              0) -
                                                                          500)
                                                                      .toString();
                                                                  controller
                                                                          .enterOfferRateController
                                                                          .value
                                                                          .text =
                                                                      controller
                                                                          .newAmount
                                                                          .value;
                                                                } else {
                                                                  controller
                                                                      .newAmount
                                                                      .value = "0";
                                                                }
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                width: 20),
                                                            Text(
                                                                Constant.amountShow(
                                                                    amount: controller
                                                                        .newAmount
                                                                        .value
                                                                        .toString()),
                                                                style: GoogleFonts
                                                                    .poppins()),
                                                            const SizedBox(
                                                                width: 20),
                                                            ButtonThem
                                                                .roundButton(
                                                              context,
                                                              title: "+ 500",
                                                              btnWidthRatio:
                                                                  0.23,
                                                              onPress: () {
                                                                final decimalDigits = Constant
                                                                        .currencyModel
                                                                        ?.decimalDigits ??
                                                                    2; // ← NULL SAFE
                                                                controller
                                                                    .newAmount
                                                                    .value = ((double.tryParse(controller.newAmount.value) ??
                                                                            0) +
                                                                        500)
                                                                    .toStringAsFixed(
                                                                        decimalDigits);
                                                                controller
                                                                        .enterOfferRateController
                                                                        .value
                                                                        .text =
                                                                    controller
                                                                        .newAmount
                                                                        .value;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ),

                                              FareButtonsSection(),

                                              // const SizedBox(height: 10),
                                              // Card(
                                              //     elevation: 3,
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(12),),
                                              //     color: Colors.white,
                                              //     child: Padding(
                                              //       padding:
                                              //           const EdgeInsets.all(
                                              //               16.0),
                                              //       child: Column(
                                              //         children: [
                                              //           Text(
                                              //             "Step No.1",
                                              //             style: TextStyle(
                                              //                 color:
                                              //                     Colors.black,
                                              //                 fontSize: 20),
                                              //           ),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText:
                                              //                   "Enter Title",
                                              //               // ← Only title now
                                              //               controller: controller
                                              //                   .titleController
                                              //                   .value,
                                              //               // ← Use a new controller for title
                                              //               keyBoardType:
                                              //                   TextInputType
                                              //                       .text,
                                              //               prefix:
                                              //                   const Padding(
                                              //                 padding: EdgeInsets
                                              //                     .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Icon(Icons
                                              //                     .title), // ← Simple icon instead of currency
                                              //               ),
                                              //             ),
                                              //           ),
                                              //           SizedBox(height: 10),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText: (controller
                                              //                           .orderModel
                                              //                           .value
                                              //                           .destinationLocationName
                                              //                           ?.isEmpty ??
                                              //                       true) // ← NULL SAFE CHECK
                                              //                   ? "Enter Taxi Meter rate"
                                              //                   : "Enter Fare rate"
                                              //                       .tr,
                                              //               controller: controller
                                              //                   .enterOfferRateController
                                              //                   .value,
                                              //               keyBoardType:
                                              //                   const TextInputType
                                              //                       .numberWithOptions(
                                              //                       decimal:
                                              //                           true,
                                              //                       signed:
                                              //                           false),
                                              //               onChanged: (value) {
                                              //                 controller
                                              //                         .newAmount
                                              //                         .value =
                                              //                     value.isEmpty
                                              //                         ? "0.0"
                                              //                         : value;
                                              //               },
                                              //               prefix: Padding(
                                              //                 padding:
                                              //                     const EdgeInsets
                                              //                         .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Text(Constant
                                              //                         .currencyModel
                                              //                         ?.symbol ??
                                              //                     ''), // ← NULL SAFE
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     )),
                                              // const SizedBox(height: 10),
                                              // Card(
                                              //     elevation: 3,
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               12),
                                              //     ),
                                              //     color: Colors.white,
                                              //     child: Padding(
                                              //       padding:
                                              //           const EdgeInsets.all(
                                              //               16.0),
                                              //       child: Column(
                                              //         children: [
                                              //           Text(
                                              //             "Step No.2",
                                              //             style: TextStyle(
                                              //                 color:
                                              //                     Colors.black,
                                              //                 fontSize: 20),
                                              //           ),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText:
                                              //                   "Enter Title",
                                              //               // ← Only title now
                                              //               controller: controller
                                              //                   .titleController
                                              //                   .value,
                                              //               // ← Use a new controller for title
                                              //               keyBoardType:
                                              //                   TextInputType
                                              //                       .text,
                                              //               prefix:
                                              //                   const Padding(
                                              //                 padding: EdgeInsets
                                              //                     .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Icon(Icons
                                              //                     .title), // ← Simple icon instead of currency
                                              //               ),
                                              //             ),
                                              //           ),
                                              //           SizedBox(height: 10),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText: (controller
                                              //                           .orderModel
                                              //                           .value
                                              //                           .destinationLocationName
                                              //                           ?.isEmpty ??
                                              //                       true) // ← NULL SAFE CHECK
                                              //                   ? "Enter Taxi Meter rate"
                                              //                   : "Enter Fare rate"
                                              //                       .tr,
                                              //               controller: controller
                                              //                   .enterOfferRateController
                                              //                   .value,
                                              //               keyBoardType:
                                              //                   const TextInputType
                                              //                       .numberWithOptions(
                                              //                       decimal:
                                              //                           true,
                                              //                       signed:
                                              //                           false),
                                              //               onChanged: (value) {
                                              //                 controller
                                              //                         .newAmount
                                              //                         .value =
                                              //                     value.isEmpty
                                              //                         ? "0.0"
                                              //                         : value;
                                              //               },
                                              //               prefix: Padding(
                                              //                 padding:
                                              //                     const EdgeInsets
                                              //                         .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Text(Constant
                                              //                         .currencyModel
                                              //                         ?.symbol ??
                                              //                     ''), // ← NULL SAFE
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     )),
                                              // const SizedBox(height: 10),
                                              // Card(
                                              //     elevation: 3,
                                              //     shape: RoundedRectangleBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               12),
                                              //     ),
                                              //     color: Colors.white,
                                              //     child: Padding(
                                              //       padding:
                                              //           const EdgeInsets.all(
                                              //               16.0),
                                              //       child: Column(
                                              //         children: [
                                              //           Text(
                                              //             "Step No.3",
                                              //             style: TextStyle(
                                              //                 color:
                                              //                     Colors.black,
                                              //                 fontSize: 20),
                                              //           ),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText:
                                              //                   "Enter Title",
                                              //               // ← Only title now
                                              //               controller: controller
                                              //                   .titleController
                                              //                   .value,
                                              //               // ← Use a new controller for title
                                              //               keyBoardType:
                                              //                   TextInputType
                                              //                       .text,
                                              //               prefix:
                                              //                   const Padding(
                                              //                 padding: EdgeInsets
                                              //                     .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Icon(Icons
                                              //                     .title), // ← Simple icon instead of currency
                                              //               ),
                                              //             ),
                                              //           ),
                                              //           SizedBox(height: 10),
                                              //           Visibility(
                                              //             visible: controller
                                              //                     .orderModel
                                              //                     .value
                                              //                     .service
                                              //                     ?.offerRate ==
                                              //                 true,
                                              //             child: TextFieldThem
                                              //                 .buildTextFiledWithPrefixIcon(
                                              //               context,
                                              //               hintText: (controller
                                              //                           .orderModel
                                              //                           .value
                                              //                           .destinationLocationName
                                              //                           ?.isEmpty ??
                                              //                       true) // ← NULL SAFE CHECK
                                              //                   ? "Enter Taxi Meter rate"
                                              //                   : "Enter Fare rate"
                                              //                       .tr,
                                              //               controller: controller
                                              //                   .enterOfferRateController
                                              //                   .value,
                                              //               keyBoardType:
                                              //                   const TextInputType
                                              //                       .numberWithOptions(
                                              //                       decimal:
                                              //                           true,
                                              //                       signed:
                                              //                           false),
                                              //               onChanged: (value) {
                                              //                 controller
                                              //                         .newAmount
                                              //                         .value =
                                              //                     value.isEmpty
                                              //                         ? "0.0"
                                              //                         : value;
                                              //               },
                                              //               prefix: Padding(
                                              //                 padding:
                                              //                     const EdgeInsets
                                              //                         .only(
                                              //                         right:
                                              //                             10),
                                              //                 child: Text(Constant
                                              //                         .currencyModel
                                              //                         ?.symbol ??
                                              //                     ''), // ← NULL SAFE
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     )),
                                              // const SizedBox(height: 20),




                                              ButtonThem.buildButton(
                                                context,
                                                title:
                                                    "Accept fare on ${Constant.amountShow(amount: controller.newAmount.value)}"
                                                        .tr,
                                                onPress: () async {
                                                  final amountValue =
                                                      double.tryParse(controller
                                                              .newAmount
                                                              .value) ??
                                                          -1;
                                                  if (controller.newAmount.value
                                                          .isNotEmpty &&
                                                      amountValue > -1) {
                                                    if (controller
                                                            .driverModel
                                                            .value
                                                            .subscriptionTotalOrders ==
                                                        "-1") {
                                                      controller.acceptOrder();
                                                    } else {
                                                      final isSubscriptionApplied =
                                                          Constant.isSubscriptionModelApplied ==
                                                              false;
                                                      final isCommissionEnabled =
                                                          Constant.adminCommission
                                                                  ?.isEnabled ==
                                                              false; // ← NULL SAFE

                                                      if (isSubscriptionApplied &&
                                                          isCommissionEnabled) {
                                                        controller
                                                            .acceptOrder();
                                                      } else {
                                                        final hasValidSubscription = controller
                                                                        .driverModel
                                                                        .value
                                                                        .subscriptionExpiryDate !=
                                                                    null &&
                                                                controller
                                                                    .driverModel
                                                                    .value
                                                                    .subscriptionExpiryDate!
                                                                    .toDate()
                                                                    .isAfter(
                                                                        DateTime
                                                                            .now()) ||
                                                            controller
                                                                    .driverModel
                                                                    .value
                                                                    .subscriptionPlan
                                                                    ?.expiryDay ==
                                                                '-1';

                                                        if (hasValidSubscription) {
                                                          if (controller
                                                                  .driverModel
                                                                  .value
                                                                  .subscriptionTotalOrders !=
                                                              '0') {
                                                            controller
                                                                .acceptOrder();
                                                          } else {
                                                            ShowToastDialog
                                                                .showToast(
                                                                    "Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                                                          }
                                                        } else {
                                                          ShowToastDialog.showToast(
                                                              "Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    ShowToastDialog.showToast(
                                                        "Please enter valid offer rate"
                                                            .tr);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }
}




class FareButtonsSection extends StatelessWidget {
  final OrderMapController controller = Get.put(OrderMapController());

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================== HORIZONTAL BUTTONS ==================
          Row(
            children: [
              Expanded(
                child: ButtonThem.buildButton(
                  bgColors: Colors.white,
                  textColor: Colors.black,
                  context,
                  title: "Case Total",
                  onPress: () {
                    controller.selectedButton.value =
                    controller.selectedButton.value == 0 ? -1 : 0;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ButtonThem.buildButton(
                  context,
                  title: "Create Steps",
                  onPress: () {
                    controller.selectedButton.value =
                    controller.selectedButton.value == 1 ? -1 : 1;

                    // Jab Create Steps khule
                    if (controller.selectedButton.value == 1) {
                      // 2 default steps add karo
                      controller.initializeDefaultSteps();

                      // Case Total ka value totalPriceController me copy karo
                      controller.totalPriceController.value.text =
                          controller.enterOfferRateController.value.text;

                      // Automatically divide price among steps
                      controller.onTotalPriceChanged();
                    }
                  },
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

          // ================== CONTENT FOR BUTTON 1 (CASE TOTAL) ==================
          if (controller.selectedButton.value == 0)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: _buildStepCard(
                context: context,
                step: "Step No.1",
                controller: controller,
              ),
            ),

          // ================== CONTENT FOR BUTTON 2 (STEPS) ==================
          if (controller.selectedButton.value == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ---------- TOTAL PRICE FIELD ----------
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: TextFieldThem.buildTextFiledWithPrefixIcon(
                    context,
                    hintText: "Enter Total Price",
                    controller: controller.totalPriceController.value,
                    keyBoardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(Constant.currencyModel?.symbol ?? ''),
                    ),
                    onChanged: (value) {
                      controller.onTotalPriceChanged();
                    },
                  ),
                ),

                // ---------- Steps List ----------
                Obx(() {
                  return Column(
                    children: List.generate(controller.steps.length, (index) {
                      return Column(
                        children: [
                          _buildDynamicStepCard(
                            context: context,
                            stepNumber: index + 1,
                            stepModel: controller.steps[index],
                            controller: controller,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  );
                }),

                const SizedBox(height: 10),

                // ---------- Add Step ----------
                ButtonThem.buildButton(
                  context,
                  title: "Add Step",
                  onPress: () {
                    controller.addStep();
                  },
                ),

                const SizedBox(height: 10),

                // ---------- Remove Step ----------
                Obx(() {
                  return controller.steps.isNotEmpty
                      ? ButtonThem.buildButton(
                    context,
                    bgColors: Colors.red,
                    title: "Remove Step",
                    onPress: () {
                      controller.removeLastStep();
                    },
                  )
                      : const SizedBox();
                }),

                const SizedBox(height: 15),
              ],
            ),
        ],
      ),
    );
  }

  // ========== STATIC CARD FOR CASE TOTAL ==========
  Widget _buildStepCard({
    required BuildContext context,
    required String step,
    required OrderMapController controller,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              step,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            // Title Field
            TextFieldThem.buildTextFiledWithPrefixIcon(
              context,
              hintText: "Enter Title",
              controller: controller.titleController.value,
              keyBoardType: TextInputType.text,
              prefix: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 10),
            // Price Field
            TextFieldThem.buildTextFiledWithPrefixIcon(
              context,
              hintText: (controller.orderModel.value.destinationLocationName
                  ?.isEmpty ??
                  true)
                  ? "Enter Taxi Meter rate"
                  : "Enter Fare rate",
              controller: controller.enterOfferRateController.value,
              keyBoardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(Constant.currencyModel?.symbol ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DYNAMIC STEP CARDS ==========
  Widget _buildDynamicStepCard({
    required BuildContext context,
    required int stepNumber,
    required StepModel stepModel,
    required OrderMapController controller,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Step No. $stepNumber",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Title Field
            TextFieldThem.buildTextFiledWithPrefixIcon(
              context,
              hintText: "Enter Title",
              controller: stepModel.titleController,
              keyBoardType: TextInputType.text,
              prefix: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 10),
            // Price Field (always visible)
            TextFieldThem.buildTextFiledWithPrefixIcon(
              context,
              hintText: "Enter Step Price",
              controller: stepModel.rateController,
              keyBoardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(Constant.currencyModel?.symbol ?? ''),
              ),
              onChanged: (value) {
                controller.onTotalPriceChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}





