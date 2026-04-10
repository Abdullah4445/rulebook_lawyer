import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/controller/wallet_controller.dart';
import 'package:lawyer/model/intercity_order_model.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:lawyer/model/wallet_transaction_model.dart';
import 'package:lawyer/model/withdraw_model.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/themes/button_them.dart';
import 'package:lawyer/themes/responsive.dart';
import 'package:lawyer/themes/text_field_them.dart';
import 'package:lawyer/ui/order_intercity_screen/complete_intecity_order_screen.dart';
import 'package:lawyer/ui/order_screen/complete_order_screen.dart';
import 'package:lawyer/ui/withdraw_history/withdraw_history_screen.dart';
import 'package:lawyer/utils/DarkThemeProvider.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<WalletController>(
        init: WalletController(),
        builder: (controller) {
          final topUpTransactions = controller.topUpTransactions;
          final otherTransactions = controller.otherWalletTransactions;

          return Scaffold(
            backgroundColor: AppColors.primary,
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Column(
                    children: [
                      Container(
                        height: Responsive.width(24, context),
                        width: Responsive.width(100, context),
                        color: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Balance".tr,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      Constant.amountShow(
                                          amount: controller
                                              .driverUserModel.value.walletAmount
                                              .toString()),
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -22),
                                child: MaterialButton(
                                  onPressed: () {
                                    paymentMethodDialog(context, controller);
                                  },
                                  height: 40,
                                  elevation: 0.5,
                                  minWidth: 0.40,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  color: themeChange.getThem()
                                      ? AppColors.darkModePrimary
                                      : Colors.white,
                                  child: Text(
                                    "Topup Wallet".tr.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                            child: ListView(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem()
                                              ? AppColors.darkContainerBackground
                                              : const Color(0xFFFFF8EA),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.brandGold.withValues(alpha: 0.26),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Secure wallet top-up'.tr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Wallet top-ups are available only through secure online payment methods. Cash is disabled for wallet balance.'.tr,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: themeChange.getThem()
                                                    ? Colors.white70
                                                    : AppColors.grey600,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Text(
                                                'Currency: PKR'.tr,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (topUpTransactions.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          title: 'Top-up History'.tr,
                                          subtitle:
                                              'Your latest wallet additions appear here right after every successful top-up.'.tr,
                                        ),
                                        const SizedBox(height: 10),
                                        ...topUpTransactions.map(
                                          (walletTransactionModel) => _buildTransactionCard(
                                            context: context,
                                            themeChange: themeChange,
                                            walletTransactionModel: walletTransactionModel,
                                            highlightTopUp: true,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                      if (otherTransactions.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          title: 'Wallet Activity'.tr,
                                          subtitle:
                                              'Withdrawals and other balance movements are listed below.'.tr,
                                        ),
                                        const SizedBox(height: 10),
                                        ...otherTransactions.map(
                                          (walletTransactionModel) => _buildTransactionCard(
                                            context: context,
                                            themeChange: themeChange,
                                            walletTransactionModel: walletTransactionModel,
                                          ),
                                        ),
                                      ],
                                      if (topUpTransactions.isEmpty &&
                                          otherTransactions.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 30),
                                          child: Center(
                                            child: Text("No transaction found".tr),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonThem.buildBorderButton(
                      context,
                      title: "withdraw".tr,
                      onPress: () async {
                        if (double.parse(controller.driverUserModel.value.walletAmount
                                .toString()) <=
                            0) {
                          ShowToastDialog.showToast("Insufficient balance".tr);
                        } else {
                          ShowToastDialog.showLoader("Please wait".tr);
                          await FireStoreUtils.bankDetailsIsAvailable().then((value) {
                            ShowToastDialog.closeLoader();
                            if (value == true) {
                              withdrawAmountBottomSheet(context, controller);
                            } else {
                              ShowToastDialog.showToast(
                                  "Your bank details is not available.Please add bank details"
                                      .tr);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ButtonThem.buildButton(
                      context,
                      title: "Withdrawal history".tr,
                      onPress: () {
                        Get.to(const WithDrawHistoryScreen());
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.grey500,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required BuildContext context,
    required DarkThemeProvider themeChange,
    required WalletTransactionModel walletTransactionModel,
    bool highlightTopUp = false,
  }) {
    final bool isNegative =
        Constant.IsNegative(double.tryParse(walletTransactionModel.amount.toString()) ?? 0);

    return InkWell(
      onTap: () => _handleTransactionTap(
        context: context,
        walletTransactionModel: walletTransactionModel,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: highlightTopUp
                ? (themeChange.getThem()
                    ? AppColors.darkContainerBackground
                    : const Color(0xFFFFFBF2))
                : (themeChange.getThem()
                    ? AppColors.darkContainerBackground
                    : AppColors.containerBackground),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: Border.all(
              color: highlightTopUp
                  ? AppColors.brandGold.withValues(alpha: 0.30)
                  : (themeChange.getThem()
                      ? AppColors.darkContainerBorder
                      : AppColors.containerBorder),
              width: 0.8,
            ),
            boxShadow: themeChange.getThem()
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: highlightTopUp
                        ? AppColors.brandGold.withValues(alpha: 0.14)
                        : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/ic_wallet.svg',
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        highlightTopUp ? AppColors.brandGold : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              Constant.dateFormatTimestamp(walletTransactionModel.createdDate),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            "${isNegative ? '(-' : '+'}${Constant.amountShow(amount: walletTransactionModel.amount.toString().replaceAll('-', ''))}${isNegative ? ')' : ''}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: isNegative ? Colors.red : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        walletTransactionModel.note.toString().tr,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment method: ${walletTransactionModel.paymentType?.isNotEmpty == true ? walletTransactionModel.paymentType : 'Online Payment'}'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTransactionTap({
    required BuildContext context,
    required WalletTransactionModel walletTransactionModel,
  }) async {
    if (walletTransactionModel.orderType == "city") {
      await FireStoreUtils.getOrder(walletTransactionModel.transactionId.toString())
          .then((value) {
        if (value != null) {
          OrderModel orderModel = value;
          Get.to(const CompleteOrderScreen(), arguments: {
            "orderModel": orderModel,
          });
        }
      });
    } else if (walletTransactionModel.orderType == "intercity") {
      await FireStoreUtils.getInterCityOrder(
              walletTransactionModel.transactionId.toString())
          .then((value) {
        if (value != null) {
          InterCityOrderModel orderModel = value;
          Get.to(const CompleteIntercityOrderScreen(), arguments: {
            "orderModel": orderModel,
          });
        }
      });
    } else {
      showTransactionDetails(
        context: context,
        walletTransactionModel: walletTransactionModel,
      );
    }
  }

  paymentMethodDialog(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.arrow_back_ios)),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Topup Wallet".tr,
                              style: GoogleFonts.poppins(),
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Topup Amount".tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFieldThem.buildTextFiled(
                                  context,
                                  hintText: 'Enter Amount'.tr,
                                  controller: controller.amountController.value,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9*]')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8EA),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.brandGold.withValues(alpha: 0.22),
                                    ),
                                  ),
                                  child: Text(
                                    'All wallet top-ups are processed in PKR and cash payment is not available.'.tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.grey700,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                Text(
                                  "Select Payment Option".tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                controller.paymentModel.value.payfast?.enable == true
                                    ? InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value =
                                              controller.paymentModel.value.payfast?.name
                                                      ?.trim() ??
                                                  'PayFast';
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod
                                                            .value ==
                                                        (controller.paymentModel.value
                                                                .payfast?.name
                                                                ?.trim()
                                                            ??
                                                            'PayFast')
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                      color: AppColors.lightGray,
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset(
                                                        'assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payfast
                                                            ?.name
                                                            ?.trim()
                                                            .isNotEmpty ==
                                                        true
                                                        ? controller.paymentModel.value
                                                            .payfast!.name!
                                                            .trim()
                                                        : 'PayFast',
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Icon(
                                                  controller.selectedPaymentMethod.value ==
                                                          (controller.paymentModel.value.payfast
                                                                      ?.name
                                                                      ?.trim()
                                                                      .isNotEmpty ==
                                                                  true
                                                              ? controller.paymentModel.value
                                                                  .payfast!.name!
                                                                  .trim()
                                                              : 'PayFast')
                                                      ? Icons.radio_button_checked
                                                      : Icons.radio_button_off,
                                                  color: controller.selectedPaymentMethod.value ==
                                                          (controller.paymentModel.value.payfast
                                                                      ?.name
                                                                      ?.trim()
                                                                      .isNotEmpty ==
                                                                  true
                                                              ? controller.paymentModel.value
                                                                  .payfast!.name!
                                                                  .trim()
                                                              : 'PayFast')
                                                      ? (themeChange.getThem()
                                                          ? AppColors.darkModePrimary
                                                          : AppColors.primary)
                                                      : AppColors.textFieldBorder,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          border: Border.all(
                                              color: AppColors.textFieldBorder, width: 1),
                                        ),
                                        child: Text(
                                          'PayFast is not enabled in admin payment settings.'
                                              .tr,
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(context, title: "Topup".tr, onPress: () {
                        final String? amountError = controller.validateTopUpAmount();
                        if (amountError != null) {
                          ShowToastDialog.showToast(amountError);
                          return;
                        }

                        final payFastName =
                            controller.paymentModel.value.payfast?.name?.trim() ??
                                'PayFast';

                        if (controller.paymentModel.value.payfast?.enable != true) {
                          ShowToastDialog.showToast(
                              'PayFast is not enabled in admin payment settings.'.tr);
                          return;
                        }

                        controller.selectedPaymentMethod.value = payFastName;
                        controller.payFastPayment(
                            context: context,
                            amount: controller.amountController.value.text);
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  showTransactionDetails(
      {required BuildContext context,
      required WalletTransactionModel walletTransactionModel}) {
    return showModalBottomSheet(
        elevation: 5,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            final themeChange = Provider.of<DarkThemeProvider>(context);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Transaction Details".tr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
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
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 5,
                                  offset:
                                      const Offset(0, 4), // changes position of shadow
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID".tr,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "#${walletTransactionModel.transactionId!.toUpperCase()}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
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
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 5,
                                  offset:
                                      const Offset(0, 4), // changes position of shadow
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Details".tr,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            "Pay Via".tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " ${walletTransactionModel.paymentType}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date in UTC Format".tr,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          DateFormat('KK:mm:ss a, dd MMM yyyy')
                                              .format(walletTransactionModel.createdDate!
                                                  .toDate())
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  withdrawAmountBottomSheet(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);

          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        "Withdraw".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
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
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.bankDetailsModel.value.bankName.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.account_balance,
                                    size: 40,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                controller.bankDetailsModel.value.accountNumber
                                    .toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                controller.bankDetailsModel.value.holderName.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                controller.bankDetailsModel.value.branchName.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                controller.bankDetailsModel.value.otherInformation
                                    .toString(),
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Amount to Withdraw".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldThem.buildTextFiled(context,
                        hintText: 'Enter Amount'.tr,
                        controller: controller.withdrawalAmountController.value),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldThem.buildTextFiled(context,
                        hintText: 'Notes'.tr,
                        maxLine: 3,
                        controller: controller.noteController.value),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonThem.buildButton(
                          context,
                          title: "Withdrawal".tr,
                          onPress: () async {
                            if (double.parse(controller.driverUserModel.value.walletAmount
                                    .toString()) <
                                double.parse(
                                    controller.withdrawalAmountController.value.text)) {
                              ShowToastDialog.showToast("Insufficient balance".tr);
                            } else if (double.parse(Constant.minimumAmountToWithdrawal) >
                                double.parse(
                                    controller.withdrawalAmountController.value.text)) {
                              ShowToastDialog.showToast(
                                  "Withdraw amount must be greater or equal to ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal.toString())}"
                                      .tr);
                            } else {
                              ShowToastDialog.showLoader("Please wait".tr);
                              WithdrawModel withdrawModel = WithdrawModel();
                              withdrawModel.id = Constant.getUuid();
                              withdrawModel.userId = FireStoreUtils.getCurrentUid();
                              withdrawModel.paymentStatus = "pending";
                              withdrawModel.amount =
                                  controller.withdrawalAmountController.value.text;
                              withdrawModel.note = controller.noteController.value.text;
                              withdrawModel.createdDate = Timestamp.now();

                              await FireStoreUtils.updatedDriverWallet(
                                  amount:
                                      "-${controller.withdrawalAmountController.value.text}");

                              await FireStoreUtils.setWithdrawRequest(withdrawModel)
                                  .then((value) {
                                controller.getUser();
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Request sent to admin".tr);
                                Get.back();
                              });
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}

class CardPaymentBottomSheet extends StatefulWidget {
  final WalletController controller;

  const CardPaymentBottomSheet({required this.controller});

  @override
  State<CardPaymentBottomSheet> createState() => _CardPaymentBottomSheetState();
}

class _CardPaymentBottomSheetState extends State<CardPaymentBottomSheet> {
  String cardNumber = "4575623182290326";
  String expiryDate = '1225';
  String cardHolderName = 'Bilal Saeed';
  String cvvCode = '123';

  bool isCvvFocused = false;
  bool _isLoading = false; // New state variable for loading indicator

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // These lines likely set default values for demonstration purposes,
    // ensure they don't interfere with user input in a real scenario.
    widget.controller.cardNumberController.text = cardNumber;
    widget.controller.cardExpMonthController.text = 12.toString();
    widget.controller.cardExpYearController.text = 2025.toString();
    widget.controller.cardCvcController.text = cvvCode;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (CreditCardBrand brand) {},
              ),
              CreditCardForm(
                formKey: formKey,
                obscureCvv: true,
                obscureNumber: false,
                cardNumber: cardNumber,
                cvvCode: cvvCode,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                onCreditCardModelChange: (CreditCardModel data) {
                  setState(() {
                    cardNumber = data.cardNumber;
                    expiryDate = data.expiryDate;
                    cardHolderName = data.cardHolderName;
                    cvvCode = data.cvvCode;
                    isCvvFocused = data.isCvvFocused;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null // Disable button when loading
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() {
                            _isLoading = true; // Start loading
                          });

                          final parts = expiryDate.split('/');

                          if (parts.length == 2) {
                            widget.controller.cardNumberController.text = cardNumber;
                            widget.controller.cardExpMonthController.text =
                                parts[0].trim();
                            widget.controller.cardExpYearController.text =
                                parts[1].trim();
                            widget.controller.cardCvcController.text = cvvCode;
                          }

                          await widget.controller.cardPayment(context);

                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          // Only pop if payment was successful or if you want to close it regardless
                          // You might want to add a check for payment success here before popping.
                          if (mounted) {
                            // Check if the widget is still in the tree
                            Navigator.pop(context);
                          }
                        } else {
                          ShowToastDialog.showToast("Card Details are not valid");
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        width: 24, // Adjust size as needed
                        height: 24, // Adjust size as needed
                        child: CircularProgressIndicator(
                          strokeWidth: 3, // Adjust thickness as needed
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black), // Set color
                        ),
                      )
                    : const Text("Pay Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
