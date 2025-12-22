import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/complete_order_controller.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
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
                title:  Text("Case Details".tr),
                leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                    )),
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
                      decoration:
                      BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 5,
                                          offset: const Offset(0, 4), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Case ID".tr,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FlutterClipboard.copy(controller.orderModel.value.id.toString()).then((value) {
                                                    ShowToastDialog.showToast("OrderId copied".tr);
                                                  });
                                                },
                                                child: DottedBorder(
                                                  options: RectDottedBorderOptions(

                                                    dashPattern: const [6, 6, 6, 6],
                                                    color: AppColors.textFieldBorder,

                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      "Copy".tr,
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
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
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  UserDriverView(userId: controller.orderModel.value.userId.toString(), amount: controller.orderModel.value.finalRate.toString()),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(thickness: 1),
                                  ),
                                  Text(
                                    "Case locations".tr,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: LocationView(
                                        sourceLocation: controller.orderModel.value.sourceLocationName.toString(),
                                        destinationLocation: controller.orderModel.value.destinationLocationName.toString(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                Expanded(child: Text(controller.orderModel.value.status.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
                                                Text(Constant().formatTimestamp(controller.orderModel.value.createdDate), style: GoogleFonts.poppins()),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                  // Billing summary section - redesigned as card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 6))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Billing summary".tr, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                            Text(Constant.amountShow(amount: controller.calculateAmount().toString()), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.green[800])),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Divider(color: Colors.grey.shade200, thickness: 1),
                                        // Case Amount
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text("Case Amount".tr, style: GoogleFonts.poppins(color: AppColors.subTitleColor))),
                                              Text(Constant.amountShow(amount: controller.orderModel.value.finalRate.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        // Taxes
                                        controller.orderModel.value.taxList == null
                                            ? const SizedBox()
                                            : Column(
                                            children: controller.orderModel.value.taxList!.map((taxModel) {
                                              final taxAmount = Constant().calculateTax(
                                                amount: (double.parse(controller.orderModel.value.finalRate.toString()) - double.parse(controller.couponAmount.value.toString())).toString(),
                                                taxModel: taxModel,
                                              );
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text("${taxModel.title} ${taxModel.type == 'fix' ? '(${Constant.amountShow(amount: taxModel.tax)})' : '(${taxModel.tax}%)'}", style: GoogleFonts.poppins(color: AppColors.subTitleColor, fontSize: 13))),
                                                    Text(Constant.amountShow(amount: taxAmount.toString()), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        const SizedBox(height: 8),
                                        Divider(color: Colors.grey.shade200, thickness: 1),
                                        // Discount
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(child: Text("Discount".tr, style: GoogleFonts.poppins(color: AppColors.subTitleColor))),
                                            Text("(-${controller.couponAmount.value == "0.0" ? Constant.amountShow(amount: "0.0") : Constant.amountShow(amount: controller.couponAmount.value)})", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Payable amount".tr, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                              Text(Constant.amountShow(amount: controller.calculateAmount().toString()), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blue[900])),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                      boxShadow: themeChange.getThem()
                                          ? null
                                          : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 5,
                                          offset: const Offset(0, 4), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Admin Commission".tr,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Admin commission".tr,
                                                  style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "(-${Constant.amountShow(amount: Constant.calculateAdminCommission(amount: (double.parse(controller.orderModel.value.finalRate.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), adminCommission: controller.orderModel.value.adminCommission).toString())})",
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Note : Admin commission will be debited from your wallet balance. \n Admin commission will apply on Case Amount minus Discount(if applicable).".tr,
                                            style: GoogleFonts.poppins(color: Colors.red),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // --- START: Case Steps + Confirm/Cancel buttons (real-time using StreamBuilder)
                                  const SizedBox(height: 8),
                                  const Divider(thickness: 1),
                                  Text(
                                    "Case Steps".tr,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),

                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection(CollectionName.orders)
                                        .doc(controller.orderModel.value.id)
                                        .snapshots(),
                                    builder: (context, snap) {
                                      if (!snap.hasData || snap.data?.data() == null) {
                                        return const SizedBox();
                                      }

                                      final liveData = snap.data!.data()!;
                                      final liveOrder = OrderModel.fromJson(liveData);

                                      // map status to step index
                                      int statusIndex = 0;
                                      if (liveOrder.status == Constant.casePlaced) statusIndex = 0;
                                      if (liveOrder.status == Constant.caseActive) statusIndex = 1;
                                      if (liveOrder.status == Constant.caseInProgress) statusIndex = 2;
                                      if (liveOrder.status == Constant.caseComplete) statusIndex = 3;

                                      // helper to check if step completed
                                      bool isStepCompleted(int stepIndex) {
                                        if (stepIndex < 3) {
                                          return statusIndex >= stepIndex;
                                        } else {
                                          // final lawyer step: show completed only when paymentStatus true and status completed
                                          return (liveOrder.paymentStatus ?? false) && liveOrder.status == Constant.caseComplete;
                                        }
                                      }

                                      final steps = [
                                        Constant.casePlaced,
                                        Constant.caseActive,
                                        Constant.caseInProgress,
                                        Constant.caseComplete,
                                      ];

                                      // Case header: show case name, current step and payable amount
                                      final caseName = (liveOrder.caseNumber != null && liveOrder.caseNumber!.isNotEmpty)
                                          ? liveOrder.caseNumber
                                          : (liveOrder.courtName != null && liveOrder.courtName!.isNotEmpty)
                                              ? liveOrder.courtName
                                              : controller.orderModel.value.id;
                                      final currentStep = liveOrder.status ?? "";
                                      final payableAmount = Constant.amountShow(amount: (liveOrder.finalRate ?? controller.orderModel.value.finalRate ?? "0").toString());

                                      final header = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Case: ${caseName}".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text("Current Step: ".tr, style: GoogleFonts.poppins(color: AppColors.subTitleColor, fontSize: 12)),
                                              Text(currentStep.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                                              const SizedBox(width: 8),
                                              Text("Payable: $payableAmount", style: GoogleFonts.poppins(color: AppColors.subTitleColor, fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      );

                                       return Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                          header,
                                           ListView.separated(
                                             itemCount: steps.length,
                                             shrinkWrap: true,
                                             physics: const NeverScrollableScrollPhysics(),
                                             separatorBuilder: (_, __) => const SizedBox(height: 6),
                                             itemBuilder: (context, idx) {
                                               final completed = isStepCompleted(idx);
                                               // For each step show step title and a small subtitle with payment info
                                               String amountText = "-";
                                               String paymentText = "-";
                                               if (idx == steps.length - 1) {
                                                 // final step -> show payable amount and payment status
                                                 final amt = (liveOrder.finalRate ?? controller.orderModel.value.finalRate ?? "0").toString();
                                                 amountText = Constant.amountShow(amount: amt);
                                                 paymentText = (liveOrder.paymentStatus ?? false) ? "Paid".tr : "Not Paid".tr;
                                               } else {
                                                 // other steps typically have no payment associated
                                                 amountText = "-";
                                                 paymentText = "No payment".tr;
                                               }

                                              // mark active step with a small badge
                                              final isActive = (liveOrder.status == steps[idx]);

                                              return Row(
                                                 children: [
                                                   Icon(
                                                     completed ? Icons.check_circle : Icons.radio_button_unchecked,
                                                     color: completed ? Colors.green : AppColors.subTitleColor,
                                                     size: 20,
                                                   ),
                                                   const SizedBox(width: 8),
                                                   Expanded(
                                                     child: Column(
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                       children: [
                                                         Row(
                                                           children: [
                                                             Expanded(
                                                               child: Text(
                                                                 steps[idx].toString(),
                                                                 style: GoogleFonts.poppins(
                                                                   fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
                                                                   color: completed ? Colors.black : AppColors.subTitleColor,
                                                                 ),
                                                               ),
                                                             ),
                                                             if (isActive)
                                                               Container(
                                                                 margin: const EdgeInsets.only(left: 6),
                                                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                 decoration: BoxDecoration(
                                                                   color: AppColors.primary,
                                                                   borderRadius: BorderRadius.circular(6),
                                                                 ),
                                                                 child: Text("Current".tr, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
                                                               ),
                                                           ],
                                                         ),
                                                         const SizedBox(height: 4),
                                                         Text(
                                                           "Amount: $amountText | Payment: $paymentText",
                                                           style: GoogleFonts.poppins(color: AppColors.subTitleColor, fontSize: 12),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                   if (idx == 3 && liveOrder.paymentStatus == true)
                                                     Padding(
                                                       padding: const EdgeInsets.only(left: 8.0),
                                                       child: Text(
                                                         "(Payment confirmed)".tr,
                                                         style: GoogleFonts.poppins(color: Colors.green, fontSize: 12),
                                                       ),
                                                     ),
                                                 ],
                                               );
                                             },
                                           ),
                                          const SizedBox(height: 10),

                                          // show Confirm/Cancel buttons only when customer marked case complete but payment not confirmed
                                          // Payment confirmation / rejection was previously available here.
                                          // Moved: The payment confirmation flow has been moved into the Fare Details screen
                                          // (lib/ui/faredetails_screen/faredetails_screen.dart) so drivers should open
                                          // Fare Details to confirm customer payments.
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Text(
                                              "Payment confirmation is now handled in Fare Details. Open Fare Details to confirm or reject a customer's payment.",
                                              style: GoogleFonts.poppins(color: AppColors.subTitleColor, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  // --- END: Case Steps

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        });
  }
}
