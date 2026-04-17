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
          final cashTransactions = controller.cashTransactions;

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
                                      "Wallet Balance".tr,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      Constant.amountShow(
                                          amount: controller.calculatedWalletBalance.toString()),
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24),
                                    ),
                                    Text(
                                      "(Wallet & Topup only)".tr,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11),
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
                                              'Admin credits, withdrawals, commissions and wallet movements are listed here.'.tr,
                                        ),
                                        const SizedBox(height: 10),
                                        ...otherTransactions.map(
                                          (walletTransactionModel) => _buildTransactionCard(
                                            context: context,
                                            themeChange: themeChange,
                                            walletTransactionModel: walletTransactionModel,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                      if (cashTransactions.isNotEmpty) ...[
                                        _buildSectionHeader(
                                          title: 'Cash Payment History'.tr,
                                          subtitle:
                                              'Cash payments are shown here for reference only and are NOT included in your wallet balance.'.tr,
                                        ),
                                        const SizedBox(height: 10),
                                        ...cashTransactions.map(
                                          (walletTransactionModel) => _buildTransactionCard(
                                            context: context,
                                            themeChange: themeChange,
                                            walletTransactionModel: walletTransactionModel,
                                            isCashTransaction: true,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                      if (topUpTransactions.isEmpty &&
                                          otherTransactions.isEmpty &&
                                          cashTransactions.isEmpty)
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
                        if (controller.calculatedWalletBalance <= 0) {
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
    bool isCashTransaction = false,
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
            color: isCashTransaction
                ? (themeChange.getThem()
                    ? AppColors.darkContainerBackground.withValues(alpha: 0.5)
                    : const Color(0xFFF5F5F5))
                : (highlightTopUp
                    ? (themeChange.getThem()
                        ? AppColors.darkContainerBackground
                        : const Color(0xFFFFFBF2))
                    : (themeChange.getThem()
                        ? AppColors.darkContainerBackground
                        : AppColors.containerBackground)),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: Border.all(
              color: isCashTransaction
                  ? AppColors.grey500.withValues(alpha: 0.40)
                  : (highlightTopUp
                      ? AppColors.brandGold.withValues(alpha: 0.30)
                      : (themeChange.getThem()
                          ? AppColors.darkContainerBorder
                          : AppColors.containerBorder)),
              width: 0.8,
            ),
            boxShadow: themeChange.getThem()
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isCashTransaction ? 0.03 : 0.06),
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
                    color: isCashTransaction
                        ? AppColors.grey400.withValues(alpha: 0.20)
                        : (highlightTopUp
                            ? AppColors.brandGold.withValues(alpha: 0.14)
                            : AppColors.lightGray),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      isCashTransaction ? Icons.money_off : Icons.wallet,
                      size: 24,
                      color: isCashTransaction
                          ? AppColors.grey600
                          : (highlightTopUp ? AppColors.brandGold : Colors.black),
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
                                color: isCashTransaction ? AppColors.grey600 : null,
                              ),
                            ),
                          ),
                          Text(
                            "${isNegative ? '(-' : '+'}${Constant.amountShow(amount: walletTransactionModel.amount.toString().replaceAll('-', ''))}${isNegative ? ')' : ''}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: isCashTransaction
                                  ? AppColors.grey600
                                  : (isNegative ? Colors.red : AppColors.success),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isCashTransaction) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.grey500.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CASH'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              walletTransactionModel.note.toString().tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: isCashTransaction ? AppColors.grey600 : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment method: ${walletTransactionModel.paymentType?.isNotEmpty == true ? walletTransactionModel.paymentType : 'Online Payment'}'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                      if (isCashTransaction) ...[
                        const SizedBox(height: 4),
                        Text(
                          '* Not added to wallet balance'.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.grey500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
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
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Withdraw Funds".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Request sent to admin for approval".tr,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Available Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.80)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Available to Withdraw".tr,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Constant.amountShow(amount: controller.calculatedWalletBalance.toString()),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "(Wallet balance only - Cash excluded)".tr,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payout Method Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.brandGold.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.brandGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Withdrawal is processed via admin approval. Amount will be transferred to your registered bank/JazzCash account.'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.grey700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bank Account Details
                    Text(
                      "Payout Account".tr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppColors.darkContainerBackground
                            : AppColors.containerBackground,
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        border: Border.all(
                            color: themeChange.getThem()
                                ? AppColors.darkContainerBorder
                                : AppColors.containerBorder,
                            width: 0.5),
                        boxShadow: themeChange.getThem()
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.bankDetailsModel.value.bankName.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.account_balance, color: AppColors.primary, size: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _bankDetailRow(
                              icon: Icons.credit_card,
                              label: "Account No".tr,
                              value: controller.bankDetailsModel.value.accountNumber.toString(),
                            ),
                            const SizedBox(height: 6),
                            _bankDetailRow(
                              icon: Icons.person,
                              label: "Account Holder".tr,
                              value: controller.bankDetailsModel.value.holderName.toString(),
                            ),
                            if ((controller.bankDetailsModel.value.branchName ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _bankDetailRow(
                                icon: Icons.location_on,
                                label: "Branch".tr,
                                value: controller.bankDetailsModel.value.branchName.toString(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    Text(
                      "Amount to Withdraw".tr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFieldThem.buildTextFiled(context,
                        hintText: 'Enter Amount (PKR)'.tr,
                        controller: controller.withdrawalAmountController.value),
                    const SizedBox(height: 12),

                    // Notes Field
                    Text(
                      "Notes (Optional)".tr,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFieldThem.buildTextFiled(context,
                        hintText: 'Any note for admin...'.tr,
                        maxLine: 2,
                        controller: controller.noteController.value),
                    const SizedBox(height: 20),

                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      child: ButtonThem.buildButton(
                        context,
                        title: "Request Withdrawal".tr,
                        onPress: () async {
                          final String amountText = controller.withdrawalAmountController.value.text.trim();
                          if (amountText.isEmpty || double.tryParse(amountText) == null) {
                            ShowToastDialog.showToast("Please enter a valid amount".tr);
                            return;
                          }
                          final double enteredAmount = double.parse(amountText);
                          if (controller.calculatedWalletBalance < enteredAmount) {
                            ShowToastDialog.showToast("Insufficient wallet balance".tr);
                          } else if (double.parse(Constant.minimumAmountToWithdrawal) > enteredAmount) {
                            ShowToastDialog.showToast(
                                "Minimum withdrawal amount is ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal)}"
                                    .tr);
                          } else {
                            ShowToastDialog.showLoader("Submitting withdrawal request...".tr);
                            WithdrawModel withdrawModel = WithdrawModel();
                            withdrawModel.id = Constant.getUuid();
                            withdrawModel.userId = FireStoreUtils.getCurrentUid();
                            withdrawModel.paymentStatus = "pending";
                            withdrawModel.amount = amountText;
                            withdrawModel.note = controller.noteController.value.text;
                            withdrawModel.createdDate = Timestamp.now();

                            await FireStoreUtils.updatedDriverWallet(
                                amount: "-$amountText");

                            await FireStoreUtils.setWithdrawRequest(withdrawModel)
                                .then((value) {
                              controller.getUser();
                              controller.getTraction();
                              ShowToastDialog.closeLoader();
                              Get.back();
                              // Show success dialog
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 60),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Withdrawal Request Submitted!".tr,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Your request of ${Constant.amountShow(amount: amountText)} has been sent to admin. Amount will be transferred to your bank/JazzCash account after approval.".tr,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.grey600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text("OK".tr),
                                    ),
                                  ],
                                ),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _bankDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey500),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
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
