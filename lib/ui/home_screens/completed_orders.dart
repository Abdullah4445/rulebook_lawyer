import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/order_screen/complete_order_screen.dart';
import 'package:driver/ui/review/review_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompletedOrders extends StatelessWidget {
  const CompletedOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
            .where('status', isEqualTo: Constant.caseComplete)
            .orderBy("createdDate", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Center(child: Text('Something went wrong'.tr));
          if (snapshot.connectionState == ConnectionState.waiting) return Constant.loader(context);

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No Case found'.tr));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              OrderModel orderModel = OrderModel.fromJson(docs[index].data() as Map<String, dynamic>);

              return InkWell(
                onTap: () {
                  Get.to(const CompleteOrderScreen(), arguments: {"orderModel": orderModel});
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserView(
                            userId: orderModel.userId.toString(),
                            amount: orderModel.finalRate,
                            distance: orderModel.distance,
                            distanceType: orderModel.distanceType,
                          ),
                          const SizedBox(height: 10),
                          LocationView(
                            sourceLocation: orderModel.sourceLocationName.toString(),
                            destinationLocation: orderModel.destinationLocationName.toString(),
                          ),
                          const SizedBox(height: 10),

                          // status + date
                          Container(
                            decoration: BoxDecoration(
                                color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray,
                                borderRadius: const BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(orderModel.status.toString().tr, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
                                  ),
                                  Text(Constant().formatTimestamp(orderModel.createdDate), style: GoogleFonts.poppins(color: Colors.black)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Case details: show case number, court name, judge, and optional description
                          if ((orderModel.caseNumber ?? '').isNotEmpty || (orderModel.courtName ?? '').isNotEmpty || (orderModel.judgeName ?? '').isNotEmpty || (orderModel.description ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((orderModel.caseNumber ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "Case No: ${orderModel.caseNumber}".tr,
                                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ),
                                  if ((orderModel.courtName ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "Court: ${orderModel.courtName}".tr,
                                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                                      ),
                                    ),
                                  if ((orderModel.judgeName ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        "Judge: ${orderModel.judgeName}".tr,
                                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                                      ),
                                    ),
                                  if ((orderModel.description ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                        orderModel.description.toString(),
                                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // action buttons area: Review + Chat/Call
                           Row(
                             children: [
                               Expanded(
                                 child: ButtonThem.buildBorderButton(
                                   context,
                                   title: "Review".tr,
                                   btnHeight: 44,
                                   iconVisibility: false,
                                   onPress: () async {
                                     Get.to(const ReviewScreen(), arguments: {"type": "orderModel", "orderModel": orderModel});
                                   },
                                 ),
                               ),
                               const SizedBox(width: 10),
                               Row(
                                 children: [
                                   InkWell(
                                     onTap: () async {
                                       UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                       DriverUserModel? driver = await FireStoreUtils.getDriverProfile(orderModel.driverId.toString());
                                       Get.to(ChatScreens(
                                         driverId: driver!.id,
                                         customerId: customer!.id,
                                         customerName: customer.fullName,
                                         customerProfileImage: customer.profilePic,
                                         driverName: driver.fullName,
                                         driverProfileImage: driver.profilePic,
                                         orderId: orderModel.id,
                                         token: customer.fcmToken,
                                       ));
                                     },
                                     child: Container(
                                       height: 44,
                                       width: 44,
                                       decoration: BoxDecoration(
                                           color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                           borderRadius: BorderRadius.circular(5)),
                                       child: Icon(Icons.chat, color: themeChange.getThem() ? Colors.black : Colors.white),
                                     ),
                                   ),
                                   const SizedBox(width: 10),
                                   InkWell(
                                     onTap: () async {
                                       UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                       Constant.makePhoneCall("${customer!.countryCode}${customer.phoneNumber}");
                                     },
                                     child: Container(
                                       height: 44,
                                       width: 44,
                                       decoration: BoxDecoration(
                                           color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                           borderRadius: BorderRadius.circular(5)),
                                       child: Icon(Icons.call, color: themeChange.getThem() ? Colors.black : Colors.white),
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),

                           const SizedBox(height: 10),

                           // Payment buttons removed per request

                         ],
                       ),
                     ),
                   ),
                ));
               },
             ); // end ListView.builder
           }, // end StreamBuilder.builder
         ), // end StreamBuilder
      ); // end Scaffold
    }
  }
