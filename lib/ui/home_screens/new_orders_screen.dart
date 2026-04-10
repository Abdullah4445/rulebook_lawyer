import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/controller/home_controller.dart';
import 'package:lawyer/model/order_model.dart';

import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/responsive.dart';
import 'package:lawyer/ui/home_screens/order_map_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:lawyer/widget/location_view.dart';
import 'package:lawyer/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../model/language_title.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
      init: HomeController(),
      dispose: (state) {
        FireStoreUtils().closeStream();
      },
      builder: (controller) {
        return controller.isLoading.value
            ? Constant.loader(context)
            : controller.driverModel.value.isOnline == false
            ? Center(
          child: Text(
            "You are Now offline so you can't get nearest cases.".tr,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        )
            : StreamBuilder<List<OrderModel>>(
          stream: FireStoreUtils().getOrders(
              controller.driverModel.value,
              Constant.currentLocation?.latitude,
              Constant.currentLocation?.longitude),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Constant.loader(context);
            }
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: Text(
                  "No new Cases found".tr,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final orderModel = snapshot.data![index];

                  final serviceImage = orderModel.service?.image ?? '';
                  final caseTitle = orderModel.service?.title != null &&
                      orderModel.service!.title!.isNotEmpty
                      ? orderModel.service!.title!.firstWhere(
                        (e) => e.type == 'en',
                    orElse: () => LanguageTitle(title: 'No title', type: 'en'),
                  ).title ?? ''
                      : 'No title';


                  return Card(
                    elevation: themeChange.getThem() ? 0 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: themeChange.getThem()
                            ? AppColors.darkContainerBorder
                            : AppColors.containerBorder,
                        width: 0.7,
                      ),
                    ),
                    color: themeChange.getThem()
                        ? AppColors.darkContainerBackground
                        : AppColors.containerBackground,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Get.to(const OrderMapScreen(), arguments: {
                          "orderModel": orderModel.id.toString()
                        })?.then((value) {
                          if (value == true) {
                            controller.selectedIndex.value = 1;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [






                            /// ðŸ‘¤ User info
                            UserView(
                              userId: orderModel.userId,
                              amount: orderModel.offerRate,
                            ),

                            const SizedBox(height: 8),
                            /// ðŸ§¾ Title + Image Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (serviceImage.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      serviceImage,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        caseTitle,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: themeChange.getThem()
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        orderModel.description ??
                                            "No description",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: themeChange.getThem()
                                              ? Colors.grey[400]
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            /// ðŸ“ Location
                            LocationView(
                              sourceLocation:
                              orderModel.sourceLocationName ??
                                  "No source location",
                            ),

                            const SizedBox(height: 10),
                            const Divider(),

                            /// ðŸ’µ Payment Info
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: _infoItem(
                                    "Payment Type",
                                    orderModel.paymentType ?? "N/A",
                                    Icons.payment,
                                    themeChange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: _infoItem(
                                    "Offer Rate",
                                    "${orderModel.offerRate ?? '0'} PKR",
                                    Icons.local_offer,
                                    themeChange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            /// âš–ï¸ Case Type / Status / OTP
                            // Row(
                            //   mainAxisAlignment:
                            //   MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     // _infoItem(
                            //     //   "Type",
                            //     //   orderModel.service?.type ?? "N/A",
                            //     //   Icons.gavel,
                            //     //   themeChange,
                            //     // ),
                            //     _infoItem(
                            //       "Status",
                            //       orderModel.status ?? "N/A",
                            //       Icons.timelapse,
                            //       themeChange,
                            //     ),
                            //     _infoItem(
                            //       "OTP",
                            //       orderModel.otp ?? "-",
                            //       Icons.vpn_key,
                            //       themeChange,
                            //     ),
                            //   ],
                            // ),

                            const SizedBox(height: 8),

                            /// ðŸ•’ Created Date
                            Text(
                              "Created on: ${orderModel.createdDate?.toDate().toLocal().toString().split('.')[0] ?? 'Unknown'}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  /// ðŸ”¹ Reusable Info Item Widget
  Widget _infoItem(
      String title, String value, IconData icon, DarkThemeProvider themeChange) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: themeChange.getThem() ? Colors.grey[400] : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: themeChange.getThem() ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



















// import 'package:lawyer/constant/constant.dart';
// import 'package:lawyer/controller/home_controller.dart';
// import 'package:lawyer/model/order_model.dart';
// import 'package:lawyer/themes/app_colors.dart';
// import 'package:lawyer/themes/responsive.dart';
// import 'package:lawyer/ui/home_screens/order_map_screen.dart';
// import 'package:lawyer/utils/DarkThemeProvider.dart';
// import 'package:lawyer/utils/fire_store_utils.dart';
// import 'package:lawyer/widget/location_view.dart';
// import 'package:lawyer/widget/user_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// class NewOrderScreen extends StatelessWidget {
//   const NewOrderScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     return GetX<HomeController>(
//         init: HomeController(),
//         dispose: (state) {
//           FireStoreUtils().closeStream();
//         },
//         builder: (controller) {
//           return controller.isLoading.value
//               ? Constant.loader(context)
//               : controller.driverModel.value.isOnline == false
//                   ? Center(
//                       child:
//                           Text("You are Now offline so you can't get nearest order.".tr),
//                     )
//                   :
//           // Obx(() {
//           //   if (controller.availableRides.isEmpty) {
//           //     return const Center(child: Text("No new rides available"));
//           //   }
//           //   return ListView.builder(
//           //     itemCount: controller.availableRides.length,
//           //     itemBuilder: (context, index) {
//           //       final ride = controller.availableRides[index];
//           //       return ListTile(
//           //         title: Text(ride.sourceLocationName ?? "No source"),
//           //         subtitle: Text(ride.destinationLocationName ?? "No destination"),
//           //         trailing: ElevatedButton(
//           //           onPressed: () {
//           //             controller.acceptRide(ride.id??"");
//           //           },
//           //           child: const Text("Accept"),
//           //         ),
//           //       );
//           //     },
//           //   );
//           // });
//
//           StreamBuilder<List<OrderModel>>(
//                       stream: FireStoreUtils().getOrders(
//                           controller.driverModel.value,
//                           Constant.currentLocation?.latitude,
//                           Constant.currentLocation?.longitude),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return Constant.loader(context);
//                         }
//                         if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
//                           return Center(
//                             child: Text("New Rides Not found".tr),
//                           );
//                         } else {
//                           // ordersList = snapshot.data!;
//                           return ListView.builder(
//                             itemCount: snapshot.data!.length,
//                             shrinkWrap: true,
//                             itemBuilder: (context, index) {
//                               OrderModel orderModel = snapshot.data![index];
//                               print("My data is: ${orderModel.toJson()}");
//
//                               // Safely extract values or use fallback
//                               // final kmCharge = orderModel.service?.kmCharge ?? 0.0;
//                               // final distance = orderModel.distance ?? 0.0;
//                               // final decimals = Constant.currencyModel?.decimalDigits ?? 2;
//
//                               // Now it's safe to parse
//
//                               print("orderModel: $orderModel");
//                               print("orderModel.service: ${orderModel.service}");
//                               print("orderModel.service.kmCharge: ${orderModel.service?.kmCharge}");
//                               print("orderModel.distance: ${orderModel.distance}");
//                               print("Constant.currencyModel: ${Constant.currencyModel}");
//                               print("Constant.currencyModel.decimalDigits: ${Constant.currencyModel?.decimalDigits}");
//                               // final amount = Constant.amountCalculate(
//                               //   kmCharge.toString(),
//                               //   distance.toString(),
//                               // ).toStringAsFixed(decimals);
//
//                                 // amount = Constant.amountCalculate(
//                                 //         orderModel.service!.kmCharge.toString(),
//                                 //         orderModel.distance.toString())
//                                 //     .toStringAsFixed(
//                                 //         Constant.currencyModel!.decimalDigits!);
//                               // } else {
//                               //   amount = Constant.amountCalculate(
//                               //           orderModel.service!.kmCharge.toString(),
//                               //           orderModel.distance.toString())
//                               //       .toStringAsFixed(
//                               //           Constant.currencyModel!.decimalDigits!);
//                               // }
//
//                               return Column(
//                                 children: [
//
//                                   InkWell(
//                                     onTap: () {
//                                       Get.to(const OrderMapScreen(), arguments: {
//                                         "orderModel": orderModel.id.toString()
//                                       })!
//                                           .then((value) {
//                                         if (value != null && value == true) {
//                                           controller.selectedIndex.value = 1;
//                                         }
//                                       });
//                                     },
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: themeChange.getThem()
//                                               ? AppColors.darkContainerBackground
//                                               : AppColors.containerBackground,
//                                           borderRadius:
//                                               const BorderRadius.all(Radius.circular(10)),
//                                           border: Border.all(
//                                               color: themeChange.getThem()
//                                                   ? AppColors.darkContainerBorder
//                                                   : AppColors.containerBorder,
//                                               width: 0.5),
//                                           boxShadow: themeChange.getThem()
//                                               ? null
//                                               : [
//                                                   BoxShadow(
//                                                     color: Colors.grey.withOpacity(0.5),
//                                                     blurRadius: 8,
//                                                     offset: const Offset(
//                                                         0, 2), // changes position of shadow
//                                                   ),
//                                                 ],
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 10),
//                                           child: Column(
//                                             children: [
//
//
//                                               UserView(
//
//                                                 userId: orderModel.userId,
//                                                 amount: orderModel.offerRate,
//                                                 // distance: orderModel.distance,
//                                                 // distanceType: orderModel.distanceType,
//                                               ),
//                                               const Padding(
//                                                 padding: EdgeInsets.symmetric(vertical: 5),
//                                                 child: Divider(),
//                                               ),
//                                               LocationView(
//                                                 sourceLocation:
//                                                     orderModel.sourceLocationName.toString(),
//                                                 // destinationLocation: orderModel
//                                                 //     .destinationLocationName
//                                                 //     .toString(),
//                                               ),
//
//
//
//
//
//                                               Column(
//                                                 children: [
//                                                   const SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Text(
//                                                     orderModel.titleList != null && orderModel.titleList!.isNotEmpty
//                                                         ? (orderModel.titleList!
//                                                         .firstWhere(
//                                                           (e) => e.type == 'en',
//                                                       orElse: () => TitleItem(title: 'No title', type: 'en'),
//                                                     )
//                                                         .title ??
//                                                         '')
//                                                         : 'No title',
//                                                     style: const TextStyle(fontSize: 14, color: Colors.black),
//                                                   ),
//                                                   Text("${orderModel.description}",style: TextStyle(fontSize: 12,color:Colors.black),),
//
//                               //                     Padding(
//                               //                       padding: const EdgeInsets.symmetric(
//                               //                           horizontal: 10, vertical: 5),
//                               //                       child: Container(
//                               //                         width: Responsive.width(100, context),
//                               //                         decoration: BoxDecoration(
//                               //                             color: themeChange.getThem()
//                               //                                 ? AppColors.darkGray
//                               //                                 : AppColors.gray,
//                               //                             borderRadius: BorderRadius.all(
//                               //                                 Radius.circular(10))),
//                               //                         child: Padding(
//                               //                           padding: const EdgeInsets.symmetric(
//                               //                               horizontal: 10, vertical: 10),
//                               //                           child: Center(
//                               //                             child: Text(
//                               //                               'Recommended Price is ${Constant.amountShow(amount: amount)}. Approx distance ${((orderModel.distance.toString()))}',
//                               //
//                               //
//                               // // 'Recommended Price is ${Constant.amountShow(amount: amount)}. Approx distance ${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}',
//                               //                               style: GoogleFonts.poppins(
//                               //                                   fontWeight: FontWeight.w500,
//                               //                                   color: Colors.black),
//                               //                             ),
//                               //                           ),
//                               //                         ),
//                               //                       ),
//                               //                     ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         }
//                       });
//         });
//   }
// }
