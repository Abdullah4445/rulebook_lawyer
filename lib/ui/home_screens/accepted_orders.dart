import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/controller/accepted_orders_controller.dart';
import 'package:lawyer/model/order/driverId_accept_reject.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/case_duration_utils.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/location_view.dart';
import 'package:lawyer/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AcceptedOrders extends StatelessWidget {
  const AcceptedOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<AcceptedOrdersController>(
        init: AcceptedOrdersController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(CollectionName.orders)
                .where('acceptedDriverId', arrayContains: FireStoreUtils.getCurrentUid())
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong'.tr);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Constant.loader(context);
              }
              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text("No accepted case found".tr),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        OrderModel orderModel = OrderModel.fromJson(
                            snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                  width: 0.5),
                              boxShadow: themeChange.getThem()
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: const Color.fromRGBO(
                                            128, 128, 128, 0.5),
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
                                    userId: orderModel.userId.toString(),
                                    amount: orderModel.offerRate,
                                    distance: orderModel.distance,
                                    distanceType: orderModel.distanceType,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(),
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

                                      // ðŸ”¥ Fare Details container
                                      if (driverIdAcceptReject.fareDetails != null) {
                                        final fareDetails = driverIdAcceptReject.fareDetails!;
                                        final steps = fareDetails['steps'] != null
                                            ? List<Map<String, dynamic>>.from(fareDetails['steps'])
                                            : <Map<String, dynamic>>[];
                                        final caseDuration = CaseDurationUtils.formatDuration(
                                          fareDetails['caseDuration'] ?? fareDetails['duration'],
                                        );

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                                  color: const Color.fromRGBO(
                                                      0, 0, 0, 0.10),
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
                                                    "Fare Details".tr,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Theme.of(context).colorScheme.onSurface),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  if (caseDuration.isNotEmpty) ...[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Estimated Case Time".tr,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.color
                                                                ?.withValues(alpha: 0.72),
                                                          ),
                                                        ),
                                                        Text(
                                                          caseDuration,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: Theme.of(context).colorScheme.onSurface,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                  ],

                                                  // Steps
                                                  ...steps.map(
                                                        (step) {
                                                      final stepDuration = CaseDurationUtils.formatDuration(
                                                        step['duration'],
                                                      );
                                                      return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  step['title']?.toString() ?? '',
                                                                  style: GoogleFonts.poppins(
                                                                      fontSize: 14,
                                                                      color: Theme.of(context).colorScheme.onSurface),
                                                                ),
                                                                if (stepDuration.isNotEmpty)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      stepDuration,
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize: 12,
                                                                        color: Colors.blueGrey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            Constant.amountShow(
                                                                amount: step['price']?.toString() ?? '0'),
                                                            style: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w600,
                                                                color: Theme.of(context).colorScheme.onSurface),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    },
                                                  ),

                                                  const Divider(height: 20),

                                                  // Total
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Total".tr,
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: Theme.of(context).colorScheme.onSurface),
                                                      ),
                                                      Text(
                                                        Constant.amountShow(
                                                            amount: fareDetails['total']?.toString() ?? '0'),
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: Theme.of(context).colorScheme.onSurface),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
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


                            // FutureBuilder<DriverIdAcceptReject?>(
                                  //     future: FireStoreUtils.getAcceptedOrders(
                                  //         orderModel.id.toString(),
                                  //         FireStoreUtils.getCurrentUid()),
                                  //     builder: (context, snapshot) {
                                  //       switch (snapshot.connectionState) {
                                  //         case ConnectionState.waiting:
                                  //           return Constant.loader(context);
                                  //         case ConnectionState.done:
                                  //           if (snapshot.hasError) {
                                  //             return Text(snapshot.error.toString());
                                  //           } else {
                                  //             DriverIdAcceptReject driverIdAcceptReject =
                                  //                 snapshot.data!;
                                  //             return Padding(
                                  //               padding: const EdgeInsets.symmetric(
                                  //                   horizontal: 10),
                                  //               child: Container(
                                  //                 decoration: BoxDecoration(
                                  //                   color: themeChange.getThem()
                                  //                       ? AppColors
                                  //                           .darkContainerBackground
                                  //                       : AppColors.containerBackground,
                                  //                   borderRadius: const BorderRadius.all(
                                  //                       Radius.circular(10)),
                                  //                   border: Border.all(
                                  //                       color: themeChange.getThem()
                                  //                           ? AppColors
                                  //                               .darkContainerBorder
                                  //                           : AppColors.containerBorder,
                                  //                       width: 0.5),
                                  //                   boxShadow: themeChange.getThem()
                                  //                       ? null
                                  //                       : [
                                  //                           BoxShadow(
                                  //                             color: Colors.black
                                  //                                 .withOpacity(0.10),
                                  //                             blurRadius: 5,
                                  //                             offset: const Offset(0,
                                  //                                 4), // changes position of shadow
                                  //                           ),
                                  //                         ],
                                  //                 ),
                                  //                 child: Padding(
                                  //                   padding: const EdgeInsets.all(8.0),
                                  //                   child: Row(
                                  //                     children: [
                                  //                       Expanded(
                                  //                           child: Text("Offer Rate".tr,
                                  //                               style:
                                  //                                   GoogleFonts.poppins(
                                  //                                       fontWeight:
                                  //                                           FontWeight
                                  //                                               .w600,
                                  //                                       color: Colors
                                  //                                           .black))),
                                  //                       Text(
                                  //                         Constant.amountShow(
                                  //                             amount: driverIdAcceptReject
                                  //                                 .offerAmount
                                  //                                 .toString()),
                                  //                         style: TextStyle(
                                  //                             color: Colors.black),
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           }
                                  //         default:
                                  //           return Text('Error'.tr);
                                  //       }
                                  //     }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  LocationView(
                                      latitude: orderModel.sourceLocationLatLng?.latitude,
                                      longitude: orderModel.sourceLocationLatLng?.longitude,
                                      sourceLocation:
                                          orderModel.sourceLocationName.toString(),
                                      destinationLocation:
                                          orderModel.destinationLocationName == null ||
                                                  orderModel
                                                      .destinationLocationName!.isEmpty
                                              ? "Taxi Meter Preffered for this ride".tr
                                              : orderModel.destinationLocationName
                                                  .toString()),
                                ],
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
