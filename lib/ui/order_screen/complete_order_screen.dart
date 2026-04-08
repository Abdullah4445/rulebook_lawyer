import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/complete_order_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/case_duration_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompleteOrderScreen extends StatelessWidget {
  const CompleteOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CompleteOrderController>(
        init: CompleteOrderController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: Text("Case Details".tr),
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
            backgroundColor: AppColors.primary,
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.width(10, context),
                  width: Responsive.width(100, context),
                ),
                Expanded(
                  child: controller.isLoading.value
                      ? Constant.loader(context)
                      : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Case ID Card
                                Container(
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
                                      width: 0.5,
                                    ),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                      BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.10),
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Case ID".tr,
                                                style:
                                                GoogleFonts.poppins(
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                FlutterClipboard.copy(
                                                    controller
                                                        .orderModel
                                                        .value
                                                        .id
                                                        .toString())
                                                    .then((value) {
                                                  ShowToastDialog.showToast(
                                                      "OrderId copied".tr);
                                                });
                                              },
                                              child: DottedBorder(
                                                options:
                                                RectDottedBorderOptions(
                                                  dashPattern: const [
                                                    6,
                                                    6,
                                                    6,
                                                    6
                                                  ],
                                                  color: AppColors
                                                      .textFieldBorder,
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    "Copy".tr,
                                                    style: GoogleFonts
                                                        .poppins(
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "#${controller.orderModel.value.id!.toUpperCase()}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // User/Driver View
                                UserDriverView(
                                  userId: controller
                                      .orderModel.value.userId
                                      .toString(),
                                  amount: controller
                                      .orderModel.value.finalRate
                                      .toString(),
                                ),
                                const Padding(
                                  padding:
                                  EdgeInsets.symmetric(vertical: 5),
                                  child: Divider(thickness: 1),
                                ),

                                // Case Locations
                                Text(
                                  "Case locations".tr,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
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
                                      width: 0.5,
                                    ),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                      BoxShadow(
                                        color: Color.fromRGBO(
                                            128, 128, 128, 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0,
                                            2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LocationView(
                                      sourceLocation: controller
                                          .orderModel
                                          .value
                                          .sourceLocationName
                                          .toString(),
                                      destinationLocation: controller
                                          .orderModel
                                          .value
                                          .destinationLocationName
                                          .toString(),
                                    ),
                                  ),
                                ),

                                // Status and Date
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem()
                                          ? AppColors.darkGray
                                          : AppColors.gray,
                                      borderRadius: const BorderRadius
                                          .all(Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10, vertical: 12),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                controller.orderModel
                                                    .value.status
                                                    .toString(),
                                                style:
                                                GoogleFonts.poppins(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant().formatTimestamp(
                                                  controller.orderModel
                                                      .value.createdDate),
                                              style:
                                              GoogleFonts.poppins(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // BILLING SUMMARY SECTION
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem()
                                        ? AppColors.darkContainerBackground
                                        : Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text(
                                            "Billing summary".tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                              amount: controller
                                                  .calculateAmount()
                                                  .toString(),
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 1,
                                      ),

                                      // Case Amount
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Case Amount".tr,
                                                style:
                                                GoogleFonts.poppins(
                                                  color: AppColors
                                                      .subTitleColor,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                amount: controller
                                                    .orderModel
                                                    .value
                                                    .finalRate
                                                    .toString(),
                                              ),
                                              style:
                                              GoogleFonts.poppins(
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Taxes
                                      controller.orderModel.value
                                          .taxList ==
                                          null
                                          ? const SizedBox()
                                          : Column(
                                        children: controller
                                            .orderModel
                                            .value
                                            .taxList!
                                            .map((taxModel) {
                                          final taxAmount =
                                          Constant()
                                              .calculateTax(
                                            amount: (double.parse(controller
                                                .orderModel
                                                .value
                                                .finalRate
                                                .toString()) -
                                                double.parse(
                                                    controller
                                                        .couponAmount
                                                        .value
                                                        .toString()))
                                                .toString(),
                                            taxModel: taxModel,
                                          );
                                          return Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                vertical: 6.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${taxModel.title} ${taxModel.type == 'fix' ? '(${Constant.amountShow(amount: taxModel.tax)})' : '(${taxModel.tax}%)'}",
                                                    style: GoogleFonts
                                                        .poppins(
                                                      color: AppColors
                                                          .subTitleColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  Constant
                                                      .amountShow(
                                                    amount:
                                                    taxAmount
                                                        .toString(),
                                                  ),
                                                  style: GoogleFonts
                                                      .poppins(
                                                    fontWeight:
                                                    FontWeight
                                                        .w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 1,
                                      ),

                                      // Discount
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Discount".tr,
                                              style:
                                              GoogleFonts.poppins(
                                                color: AppColors
                                                    .subTitleColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "(-${controller.couponAmount.value == "0.0" ? Constant.amountShow(amount: "0.0") : Constant.amountShow(amount: controller.couponAmount.value)})",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Payable Amount
                                      Container(
                                        width: double.infinity,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Payable amount".tr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                amount: controller
                                                    .calculateAmount()
                                                    .toString(),
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.w800,
                                                color: Colors.blue[900],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // STEPS HISTORY SECTION (NEW)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem()
                                        ? AppColors.darkContainerBackground
                                        : Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Obx(() {
                                    if (controller.loadingSteps.value) {
                                      return Padding(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 20),
                                        child: Center(
                                          child:
                                          CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    }

                                    if (controller
                                        .stepsHistory.isEmpty) {
                                      return Column(
                                        children: [
                                          Text(
                                            "Case Steps History".tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding:
                                            const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "No step history available"
                                                    .tr,
                                                style:
                                                GoogleFonts.poppins(
                                                  color: Colors
                                                      .grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Case Steps History".tr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.w700,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: controller
                                                  .fetchStepsHistory,
                                              icon: Icon(
                                                Icons.refresh,
                                                size: 20,
                                                color: AppColors.primary,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                              const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "All steps completed in this case"
                                              .tr,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.subTitleColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 15),

                                        ListView.separated(
                                          itemCount: controller
                                              .stepsHistory.length,
                                          shrinkWrap: true,
                                          physics:
                                          const NeverScrollableScrollPhysics(),
                                          separatorBuilder:
                                              (context, index) =>
                                          const SizedBox(
                                              height: 12),
                                          itemBuilder: (context, index) {
                                            final step = controller
                                                .stepsHistory[index];
                                            final title = step[
                                            'title'] ??
                                                "Step ${step['stepNumber'] ?? index + 1}";
                                            final price =
                                                step['price'] ?? 0;
                                            final lawyerStatus =
                                                step['lawyerStatus'] ??
                                                    "pending";
                                            final customerStatus =
                                                step['customerStatus'] ??
                                                    "pending";
                                            final driverConfirmed =
                                            (step['driverConfirmed'] ==
                                                true);
                                            final durationText =
                                            CaseDurationUtils.formatDuration(
                                                step['duration']);
                                            final timestamp =
                                            step['timestamp'] != null
                                                ? controller
                                                .formatTimestamp(
                                                step[
                                                'timestamp'])
                                                : "";

                                            Color getStatusColor(
                                                String status) {
                                              switch (status
                                                  .toLowerCase()) {
                                                case 'done':
                                                  return Colors.green;
                                                case 'pending':
                                                  return Colors.orange;
                                                default:
                                                  return Colors.grey;
                                              }
                                            }

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: themeChange.getThem()
                                                    ? Colors.grey.shade900
                                                    : Colors.grey.shade50,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                                border: Border.all(
                                                  color: Colors
                                                      .grey.shade300,
                                                  width: 0.5,
                                                ),
                                              ),
                                              padding:
                                              const EdgeInsets.all(
                                                  14),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: AppColors
                                                              .primary
                                                              .withAlpha(26),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              6),
                                                        ),
                                                        child: Text(
                                                          "Step ${step['stepNumber'] ?? index + 1}",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 11,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                      if (timestamp
                                                          .isNotEmpty)
                                                        Text(
                                                          timestamp,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 10,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                      height: 10),

                                                  Text(
                                                    title,
                                                    style: GoogleFonts
                                                        .poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),
                                                   if (durationText.isNotEmpty)
                                                     Padding(
                                                       padding:
                                                       const EdgeInsets.only(
                                                           top: 8),
                                                       child: Container(
                                                         padding:
                                                         const EdgeInsets
                                                             .symmetric(
                                                           horizontal: 10,
                                                           vertical: 6,
                                                         ),
                                                         decoration:
                                                         BoxDecoration(
                                                           color: AppColors
                                                               .primary
                                                               .withAlpha(20),
                                                           borderRadius:
                                                           BorderRadius
                                                               .circular(
                                                               20),
                                                         ),
                                                         child: Text(
                                                           durationText,
                                                           style:
                                                           GoogleFonts
                                                               .poppins(
                                                             fontSize: 12,
                                                             fontWeight:
                                                             FontWeight.w500,
                                                             color: AppColors
                                                                 .primary,
                                                           ),
                                                         ),
                                                       ),
                                                     ),
                                                  const SizedBox(
                                                      height: 12),

                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            "Fee".tr,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize:
                                                              12,
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                          Text(
                                                            Constant.amountShow(
                                                                amount:
                                                                price
                                                                    .toString()),
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize:
                                                              15,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w700,
                                                              color: Colors
                                                                  .green
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .end,
                                                        children: [
                                                          // Lawyer Status
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 6,
                                                                height:
                                                                6,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: getStatusColor(
                                                                      lawyerStatus),
                                                                  shape:
                                                                  BoxShape.circle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width:
                                                                  6),
                                                              Text(
                                                                "Lawyer: ${lawyerStatus.toUpperCase()}",
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                  fontSize:
                                                                  11,
                                                                  color: getStatusColor(
                                                                      lawyerStatus),
                                                                  fontWeight:
                                                                  FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 4),

                                                          // Customer Status
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 6,
                                                                height:
                                                                6,
                                                                decoration:
                                                                BoxDecoration(
                                                                  color: getStatusColor(
                                                                      customerStatus),
                                                                  shape:
                                                                  BoxShape.circle,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width:
                                                                  6),
                                                              Text(
                                                                "Client: ${customerStatus.toUpperCase()}",
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                  fontSize:
                                                                  11,
                                                                  color: getStatusColor(
                                                                      customerStatus),
                                                                  fontWeight:
                                                                  FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(
                                                      height: 10),

                                                  // Status Bar
                                                  Container(
                                                    height: 6,
                                                    decoration:
                                                    BoxDecoration(
                                                      color: Colors.grey
                                                          .shade300,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          3),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Lawyer Status Progress
                                                        Expanded(
                                                          flex:
                                                          lawyerStatus
                                                              .toLowerCase() ==
                                                              "done"
                                                              ? 1
                                                              : 0,
                                                          child:
                                                          Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              color: lawyerStatus.toLowerCase() ==
                                                                  "done"
                                                                  ? Colors
                                                                  .green
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                topLeft:
                                                                Radius.circular(
                                                                    3),
                                                                bottomLeft:
                                                                Radius.circular(
                                                                    3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        // Customer Status Progress
                                                        Expanded(
                                                          flex:
                                                          customerStatus
                                                              .toLowerCase() ==
                                                              "done"
                                                              ? 1
                                                              : 0,
                                                          child:
                                                          Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              color: customerStatus.toLowerCase() ==
                                                                  "done"
                                                                  ? Colors
                                                                  .blue
                                                                  : Colors
                                                                  .transparent,
                                                              borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                topRight:
                                                                Radius.circular(
                                                                    3),
                                                                bottomRight:
                                                                Radius.circular(
                                                                    3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  if (driverConfirmed)
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .only(
                                                          top: 8),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .check_circle,
                                                            color: Colors
                                                                .green,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            "Payment Confirmed"
                                                                .tr,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize:
                                                              12,
                                                              color: Colors
                                                                  .green
                                                                  .shade700,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }),
                                ),

                                const SizedBox(height: 20),

                                // ADMIN COMMISSION SECTION
                                Container(
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
                                      width: 0.5,
                                    ),
                                    boxShadow: themeChange.getThem()
                                        ? null
                                        : [
                                      BoxShadow(
                                        color: Color.fromRGBO(
                                            0, 0, 0, 0.10),
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 4), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Admin Commission".tr,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Admin commission".tr,
                                                style:
                                                GoogleFonts.poppins(
                                                  color: AppColors
                                                      .subTitleColor,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "(-${Constant.amountShow(amount: Constant.calculateAdminCommission(amount: (double.parse(controller.orderModel.value.finalRate.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), adminCommission: controller.orderModel.value.adminCommission).toString())})",
                                                  style:
                                                  GoogleFonts.poppins(
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Note : Admin commission will be debited from your wallet balance. \n Admin commission will apply on Case Amount minus Discount(if applicable)."
                                              .tr,
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
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