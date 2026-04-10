import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as maths;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/show_toast_dialog.dart';
import 'package:lawyer/model/bank_details_model.dart';
import 'package:lawyer/model/driver_user_model.dart';
import 'package:lawyer/model/payment_model.dart';
import 'package:lawyer/model/stripe_failed_model.dart';
import 'package:lawyer/model/wallet_transaction_model.dart';
import 'package:lawyer/payment/MercadoPagoScreen.dart';
import 'package:lawyer/payment/getPaytmTxtToken.dart';
import 'package:lawyer/payment/midtrans_screen.dart';
import 'package:lawyer/payment/orangePayScreen.dart';
import 'package:lawyer/payment/payfast_checkout_helper.dart';
import 'package:lawyer/payment/paystack/pay_stack_screen.dart';
import 'package:lawyer/payment/paystack/pay_stack_url_model.dart';
import 'package:lawyer/payment/paystack/paystack_url_genrater.dart';
import 'package:lawyer/payment/xenditModel.dart';
import 'package:lawyer/payment/xenditScreen.dart';
import 'package:lawyer/themes/app_colors.dart';
import 'package:lawyer/utils/fire_store_utils.dart';
import 'package:epayco_dart/data/models/api_responses/tc_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:payfast_flutter/payfast_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../payment/epaycoController.dart';

class WalletController extends GetxController {
  Rx<TextEditingController> withdrawalAmountController = TextEditingController().obs;
  Rx<TextEditingController> noteController = TextEditingController().obs;

  Rx<TextEditingController> amountController = TextEditingController().obs;
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<BankDetailsModel> bankDetailsModel = BankDetailsModel().obs;
  RxString selectedPaymentMethod = "".obs;

  RxBool isLoading = true.obs;
  RxList transactionList = <WalletTransactionModel>[].obs;

  List<WalletTransactionModel> get topUpTransactions => transactionList
      .whereType<WalletTransactionModel>()
      .where((transaction) => _isTopUpTransaction(transaction))
      .toList();

  List<WalletTransactionModel> get otherWalletTransactions => transactionList
      .whereType<WalletTransactionModel>()
      .where((transaction) => !_isTopUpTransaction(transaction))
      .toList();

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentData();
    super.onInit();
  }

  getPaymentData() async {
    getTraction();
    getUser();
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        paymentModel.value.cash?.enable = false;
        paymentModel.value.cash?.name = 'Cash';
        paymentModel.value.payfast =
            PayFastCheckoutHelper.normalizePayfast(paymentModel.value.payfast);
        if (paymentModel.value.payfast?.enable == true) {
          selectedPaymentMethod.value =
              paymentModel.value.payfast?.name?.trim() ?? 'PayFast';
        } else {
          selectedPaymentMethod.value = '';
        }

        final strip = paymentModel.value.strip;
        if (strip?.clientpublishableKey?.trim().isNotEmpty == true) {
          Stripe.publishableKey = strip!.clientpublishableKey!.trim();
          Stripe.merchantIdentifier = 'GoRide';
          Stripe.instance.applySettings();
        }
        setRef();
        razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
        razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWaller);
        razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      }
    });

    isLoading.value = false;
    update();
  }

  getUser() async {
    await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        driverUserModel.value = value;
      }
    });

    await FireStoreUtils.getBankDetails().then((value) {
      if (value != null) {
        bankDetailsModel.value = value;
      }
    });
  }

  getTraction() async {
    await FireStoreUtils.getWalletTransaction().then((value) {
      if (value != null) {
        transactionList.value = value;
      }
    });
  }

  Future<void> walletTopUp({String? transactionId}) async {
    if (selectedPaymentMethod.value.trim().toLowerCase() == 'cash') {
      ShowToastDialog.showToast("Cash payment is not available for wallet top-up.".tr);
      return;
    }

    WalletTransactionModel transactionModel = WalletTransactionModel(
        id: Constant.getUuid(),
        amount: amountController.value.text,
        createdDate: Timestamp.now(),
        paymentType: selectedPaymentMethod.value,
        transactionId: (transactionId != null && transactionId.trim().isNotEmpty)
            ? transactionId.trim()
            : DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FireStoreUtils.getCurrentUid(),
        userType: "driver",
        note: "Wallet Topup");

    await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
      if (value == true) {
        await FireStoreUtils.updatedDriverWallet(amount: amountController.value.text)
            .then((value) {
          getUser();
          getTraction();
        });
      }
    });

    ShowToastDialog.showToast("Amount added in your wallet.".tr);
  }

  bool _isTopUpTransaction(WalletTransactionModel transaction) {
    final String note = transaction.note?.trim().toLowerCase() ?? '';
    return note == 'wallet topup' || note == 'wallet top-up';
  }

  String? validateTopUpAmount() {
    final String rawAmount = amountController.value.text.trim();
    if (rawAmount.isEmpty) {
      return "Please enter amount".tr;
    }

    final double? parsedAmount = double.tryParse(rawAmount);
    if (parsedAmount == null || parsedAmount <= 0) {
      return "Please enter valid amount".tr;
    }

    return null;
  }

  // Strip
  Future<void> stripeMakePayment({required String amount}) async {
    log(double.parse(amount).toStringAsFixed(0));
    try {
      Map<String, dynamic>? paymentIntentData = await createStripeIntent(amount: amount);
      if (paymentIntentData!.containsKey("error")) {
        // Get.back();
        ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      } else {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntentData['client_secret'],
                allowsDelayedPaymentMethods: false,
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  testEnv: true,
                  currencyCode: "USD",
                ),
                style: ThemeMode.system,
                appearance: const PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    primary: AppColors.primary,
                  ),
                ),
                merchantDisplayName: 'GoRide'));
        displayStripePaymentSheet(amount: amount);
      }
    } catch (e, s) {
      log("$e \n$s");
      ShowToastDialog.showToast("exception:$e \n$s");
    }
  }

  displayStripePaymentSheet({required String amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // Get.back();
        ShowToastDialog.showToast("Payment successfully".tr);
        walletTopUp();
      });
    } on StripeException catch (e) {
      var lo1 = jsonEncode(e);
      var lo2 = jsonDecode(lo1);
      StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
      ShowToastDialog.showToast(lom.error.message);
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "Strip Payment",
        "shipping[name]": driverUserModel.value.fullName,
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      log(paymentModel.value.strip!.stripeSecret.toString());
      var stripeSecret = paymentModel.value.strip!.stripeSecret;
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeSecret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  //mercadoo
  mercadoPagoMakePayment({required BuildContext context, required String amount}) async {
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.mercadoPago!.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "USD", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": driverUserModel.value.email},
      "back_urls": {
        "failure": "${Constant.globalUrl}payment/failure",
        "pending": "${Constant.globalUrl}payment/pending",
        "success": "${Constant.globalUrl}payment/success",
      },
      "auto_return": "approved" // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['init_point']))!.then((value) {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!".tr);
          walletTopUp();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!".tr);
        }
      });
    } else {
      ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  //paypal

  paypalPaymentSheet(String amount, context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: paymentModel.value.paypal!.isSandbox == true ? false : true,
            clientId: paymentModel.value.paypal!.paypalClient ?? '',
            secretKey: paymentModel.value.paypal!.paypalSecret ?? '',
            returnURL: "com.parkme://paypalpay",
            cancelURL: "com.parkme://paypalpay",
            transactions: [
              {
                "amount": {
                  "total": amount,
                  "currency": "USD",
                  "details": {"subtotal": amount}
                },
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              walletTopUp();
              ShowToastDialog.showToast("Payment Successful!".tr);
            },
            onError: (error) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!".tr);
            },
            onCancel: (params) {
              Get.back();
              ShowToastDialog.showToast("Payment UnSuccessful!".tr);
            }),
      ),
    );
  }

  ///PayStack Payment Method
  payStackPayment(String totalAmount) async {
    await PayStackURLGen.payStackURLGen(
        amount: (double.parse(totalAmount) * 100).toString(),
        currency: "NGN",
        secretKey: paymentModel.value.payStack!.secretKey.toString(),
        userModel: driverUserModel.value)
        .then((value) async {
      if (value != null && value.toString().isNotEmpty) {
        PayStackUrlModel payStackModel = value;
        Get.to(PayStackScreen(
          secretKey: paymentModel.value.payStack!.secretKey.toString(),
          callBackUrl: paymentModel.value.payStack!.callbackURL.toString(),
          initialURl: payStackModel.data.authorizationUrl,
          amount: totalAmount,
          reference: payStackModel.data.reference,
        ))!
            .then((value) {
          if (value) {
            ShowToastDialog.showToast("Payment Successful!".tr);
            walletTopUp();
          } else {
            ShowToastDialog.showToast("Payment UnSuccessful!".tr);
          }
        });
      } else {
        ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      }
    });
  }

  //flutter wave Payment Method
  flutterWaveInitiatePayment(
      {required BuildContext context, required String amount}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization': 'Bearer ${paymentModel.value.flutterWave!.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${Constant.globalUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": driverUserModel.value.email.toString(),
        "phonenumber": driverUserModel.value.phoneNumber, // Add a real phone number
        "name": driverUserModel.value.fullName!, // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!.then((value) {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!".tr);
          walletTopUp();
        } else {
          ShowToastDialog.showToast("Payment UnSuccessful!".tr);
        }
      });
    } else {
      ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  String? _ref;

  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  // payFast
  Future<void> payFastPayment({required BuildContext context, required String amount}) async {
    final String? amountError = validateTopUpAmount();
    if (amountError != null) {
      ShowToastDialog.showToast(amountError);
      return;
    }

    final payfast = paymentModel.value.payfast;
    final String? configError = PayFastCheckoutHelper.validateSettings(payfast);
    if (configError != null) {
      ShowToastDialog.showToast(configError.tr);
      return;
    }

    final String basketId = 'wallet-${DateTime.now().millisecondsSinceEpoch}';
    final normalizedPayfast = PayFastCheckoutHelper.normalizePayfast(payfast);
    final String? credentialError =
        await PayFastCheckoutHelper.validateGatewayCredentials(
      payfast: normalizedPayfast,
      basketId: basketId,
      amount: amount.trim(),
    );
    if (credentialError != null) {
      ShowToastDialog.showToast(credentialError.tr);
      debugPrint('PayFast wallet credential validation failed: $credentialError');
      return;
    }

    // Show loading
    ShowToastDialog.showLoader("Processing payment...".tr);

    try {
      await PayFast.pay(
        context: context,
        merchantId: PayFastCheckoutHelper.resolveMerchantId(normalizedPayfast),
        securedKey: PayFastCheckoutHelper.resolveSecuredKey(normalizedPayfast),
        basketId: basketId,
        amount: amount.trim(),
        callbackBaseUrl:
            PayFastCheckoutHelper.resolveCallbackBaseUrl(normalizedPayfast),
        currency: PayFastCheckoutHelper.resolveCurrencyCode(normalizedPayfast),
        txnDesc: 'Wallet Topup',
        environment: normalizedPayfast.isSandbox == true ? 'sandbox' : 'live',
        additionalDescription:
            'Wallet topup for ${driverUserModel.value.fullName ?? 'Driver'}',
        customerEmail:
            PayFastCheckoutHelper.resolveCustomerEmail(driverUserModel.value),
        customerMobile:
            PayFastCheckoutHelper.resolveCustomerMobile(driverUserModel.value),
        webTokenUrl: PayFastCheckoutHelper.resolveWebTokenUrl(normalizedPayfast),
        successPath: PayFastCheckoutHelper.resolveSuccessPath(normalizedPayfast),
        failurePath: PayFastCheckoutHelper.resolveFailurePath(normalizedPayfast),
        checkoutPath: PayFastCheckoutHelper.resolveCheckoutPath(normalizedPayfast),
        onResult: (result) {
          ShowToastDialog.closeLoader();
          _handlePayFastWalletResult(
            result: result,
            fallbackTransactionId: basketId,
            context: context,
            amount: amount,
          );
        },
      );
    } catch (e) {
      ShowToastDialog.closeLoader();
      
      // Show detailed error with retry option
      _showPaymentErrorDialog(
        context: context,
        error: e.toString(),
        amount: amount,
      );
      
      debugPrint('PayFast wallet payment error: $e');
    }
  }

  // New method to show error dialog with retry option
  void _showPaymentErrorDialog({
    required BuildContext context,
    required String error,
    required String amount,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Expanded(child: Text("Payment Failed".tr)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment process میں مسئلہ آیا:".tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.length > 100 ? '${error.substring(0, 100)}...' : error,
                  style: TextStyle(fontSize: 12, color: Colors.red[900]),
                ),
              ),
              SizedBox(height: 15),
              Text(
                "💡 کیا کریں:".tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text("1. Internet connection چیک کریں"),
              Text("2. JazzCash wallet میں balance چیک کریں"),
              Text("3. دوبارہ کوشش کریں"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel".tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Retry Payment".tr),
              onPressed: () {
                Navigator.of(context).pop();
                // Retry payment
                Future.delayed(Duration(milliseconds: 500), () {
                  payFastPayment(context: context, amount: amount);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePayFastWalletResult({
    required PayFastResult result,
    required String fallbackTransactionId,
    required BuildContext context,
    required String amount,
  }) async {
    if (result.success) {
      ShowToastDialog.showToast("Payment successfully! Your wallet has been updated.".tr);
      await walletTopUp(
        transactionId: result.transactionId ?? fallbackTransactionId,
      );
      // Close the payment dialog/modal
      Get.back();
      return;
    }

    // Enhanced error messaging with specific feedback
    String errorMessage = result.message.tr;
    String userFriendlyMessage = "";

    // JazzCash specific errors
    if (result.message.toLowerCase().contains('jazzcash')) {
      if (result.message.toLowerCase().contains('insufficient') || 
          result.message.toLowerCase().contains('balance')) {
        userFriendlyMessage = "❌ JazzCash wallet میں balance کم ہے\n\n💡 Solution:\n1. JazzCash app کھولیں\n2. Balance چیک کریں\n3. Load کریں اور دوبارہ کوشش کریں".tr;
      } else if (result.message.toLowerCase().contains('pin') || 
                 result.message.toLowerCase().contains('mpin')) {
        userFriendlyMessage = "❌ JazzCash PIN غلط ہے\n\n💡 Solution:\n1. صحیح 5 digit MPIN enter کریں\n2. اگر بھول گئے ہیں تو JazzCash app سے reset کریں".tr;
      } else if (result.message.toLowerCase().contains('blocked') || 
                 result.message.toLowerCase().contains('suspended')) {
        userFriendlyMessage = "❌ JazzCash account blocked ہے\n\n💡 Solution:\n1. JazzCash helpline پر رابطہ کریں: 111-124-124\n2. Account unblock کروائیں".tr;
      } else {
        userFriendlyMessage = "❌ JazzCash payment fail ہو گئی\n\n💡 Solutions:\n1. Internet connection چیک کریں\n2. JazzCash app update کریں\n3. دوبارہ کوشش کریں".tr;
      }
    }
    // General payment errors
    else if (result.message.toLowerCase().contains('cancel')) {
      userFriendlyMessage = "Payment cancelled by user".tr;
    } else if (result.message.toLowerCase().contains('timeout') ||
               result.message.toLowerCase().contains('expired')) {
      userFriendlyMessage = "⏱️ Payment session expire ہو گیا\n\n💡 Solution:\nدوبارہ کوشش کریں، اس بار جلدی PIN enter کریں".tr;
    } else if (result.message.toLowerCase().contains('insufficient')) {
      userFriendlyMessage = "Insufficient funds. Please check your account balance.".tr;
    } else if (result.message.toLowerCase().contains('pin') ||
               result.message.toLowerCase().contains('password')) {
      userFriendlyMessage = "🔑 PIN یا password غلط ہے\n\n💡 Solution:\n1. صحیح PIN enter کریں\n2. Caps Lock check کریں".tr;
    } else if (result.message.toLowerCase().contains('network') ||
               result.message.toLowerCase().contains('connection')) {
      userFriendlyMessage = "🌐 Network error\n\n💡 Solutions:\n1. WiFi/Mobile data چیک کریں\n2. Signal اچھا ہو\n3. دوبارہ کوشش کریں".tr;
    } else if (result.message.toLowerCase().contains('declined') || 
               result.message.toLowerCase().contains('failed')) {
      userFriendlyMessage = "❌ Payment declined\n\n💡 Possible reasons:\n1. Balance کم ہے\n2. Daily limit exceed ہو گئی\n3. Account issue ہے\n\nBank/JazzCash سے رابطہ کریں".tr;
    } else {
      userFriendlyMessage = "Payment failed: ${result.message}. Please try again or contact support.".tr;
    }
    
    // Show user-friendly message
    ShowToastDialog.showToast(userFriendlyMessage.isEmpty ? errorMessage : userFriendlyMessage);
    
    // Log for debugging
    debugPrint('═══════════════════════════════════════');
    debugPrint('PayFast Payment Failed');
    debugPrint('Transaction ID: $fallbackTransactionId');
    debugPrint('Error Message: ${result.message}');
    debugPrint('Timestamp: ${DateTime.now()}');
    debugPrint('═══════════════════════════════════════');
  }

  ///Paytm payment function
  getPaytmCheckSum(context, {required double amount}) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    String getChecksum = "${Constant.globalUrl}payments/getpaytmchecksum";

    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paymentModel.value.paytm!.paytmMID.toString(),
          "order_id": orderId,
          "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
        });

    final data = jsonDecode(response.body);
    await verifyCheckSum(checkSum: data["code"], amount: amount, orderId: orderId)
        .then((value) {
      initiatePayment(amount: amount, orderId: orderId).then((value) {
        String callback = "";
        if (paymentModel.value.paytm!.isSandbox == true) {
          callback =
          "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        } else {
          callback =
          "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
        }

        if (value.head.version.isEmpty) {
          ShowToastDialog.showToast("Payment Failed".tr);
        } else {
          GetPaymentTxtTokenModel result = value;
          startTransaction(context,
              txnTokenBy: result.body.txnToken,
              orderId: orderId,
              amount: amount,
              callBackURL: callback,
              isStaging: paymentModel.value.paytm!.isSandbox);
        }
      });
    });
  }

  Future<void> startTransaction(context,
      {required String txnTokenBy,
        required orderId,
        required double amount,
        required callBackURL,
        required isStaging}) async {
    // try {
    //   var response = AllInOneSdk.startTransaction(
    //     paymentModel.value.paytm!.paytmMID.toString(),
    //     orderId,
    //     amount.toString(),
    //     txnTokenBy,
    //     callBackURL,
    //     isStaging,
    //     true,
    //     true,
    //   );
    //
    //   response.then((value) {
    //     if (value!["RESPMSG"] == "Txn Success") {
    //       print("txt done!!");
    //       ShowToastDialog.showToast("Payment Successful!!");
    //       walletTopUp();
    //     }
    //   }).catchError((onError) {
    //     if (onError is PlatformException) {
    //       Get.back();
    //
    //       ShowToastDialog.showToast(onError.message.toString());
    //     } else {
    //       print("======>>2");
    //       Get.back();
    //       ShowToastDialog.showToast(onError.message.toString());
    //     }
    //   });
    // } catch (err) {
    //   Get.back();
    //   ShowToastDialog.showToast(err.toString());
    // }
  }

  Future verifyCheckSum(
      {required String checkSum, required double amount, required orderId}) async {
    String getChecksum = "${Constant.globalUrl}payments/validatechecksum";
    final response = await http.post(
        Uri.parse(
          getChecksum,
        ),
        headers: {},
        body: {
          "mid": paymentModel.value.paytm!.paytmMID.toString(),
          "order_id": orderId,
          "key_secret": paymentModel.value.paytm!.merchantKey.toString(),
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    return data['status'];
  }

  Future<GetPaymentTxtTokenModel> initiatePayment(
      {required double amount, required orderId}) async {
    String initiateURL = "${Constant.globalUrl}payments/initiatepaytmpayment";
    String callback = "";
    if (paymentModel.value.paytm!.isSandbox == true) {
      callback =
      "${callback}https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    } else {
      callback =
      "${callback}https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId";
    }
    final response = await http.post(Uri.parse(initiateURL), headers: {}, body: {
      "mid": paymentModel.value.paytm!.paytmMID,
      "order_id": orderId,
      "key_secret": paymentModel.value.paytm!.merchantKey,
      "amount": amount.toString(),
      "currency": "INR",
      "callback_url": callback,
      "custId": FireStoreUtils.getCurrentUid(),
      "issandbox": paymentModel.value.paytm!.isSandbox == true ? "1" : "2",
    });
    print(response.body);
    final data = jsonDecode(response.body);
    if (data["body"]["txnToken"] == null || data["body"]["txnToken"].toString().isEmpty) {
      // Get.back();
      ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
    }
    return GetPaymentTxtTokenModel.fromJson(data);
  }

  ///RazorPay payment function
  final Razorpay razorPay = Razorpay();

  void openCheckout({required amount, required orderId}) async {
    var options = {
      'key': paymentModel.value.razorpay!.razorpayKey,
      'amount': amount * 100,
      'name': 'GoRide',
      'order_id': orderId,
      "currency": "INR",
      'description': 'wallet Topup',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': driverUserModel.value.phoneNumber,
        'email': driverUserModel.value.email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    // Get.back();
    ShowToastDialog.showToast("Payment Successful!".tr);
    walletTopUp();
  }

  void handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    ShowToastDialog.showToast("Payment Processing! via".tr);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Get.back();
    // RazorPayFailedModel lom = RazorPayFailedModel.fromJson(jsonDecode(response.message!.toString()));
    ShowToastDialog.showToast("Payment Failed!".tr);
  }

  //XenditPayment
  xenditPayment(context, amount) async {
    await createXenditInvoice(amount: amount).then((model) {
      ShowToastDialog.closeLoader();
      if (model.id != null) {
        Get.to(() => XenditScreen(
          initialURl: model.invoiceUrl ?? '',
          transId: model.id ?? '',
          apiKey: paymentModel.value.xendit!.apiKey?.toString() ?? "",
        ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!".tr);
            walletTopUp();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Payment Unsuccessful!".tr),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice({required var amount}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
      generateBasicAuthHeader(paymentModel.value.xendit!.apiKey!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': Constant.getUuid(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        return model;
      } else {
        return XenditModel();
      }
    } catch (e) {
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

//Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment({required String amount, required BuildContext context}) async {
    reset();
    var id = Constant.getUuid();
    var paymentURL =
    await fetchToken(context: context, orderId: id, amount: amount, currency: 'USD');
    ShowToastDialog.closeLoader();
    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
        initialURl: paymentURL,
        accessToken: accessToken,
        amount: amount,
        orangePay: paymentModel.value.orangePay!,
        orderId: orderId,
        payToken: payToken,
      ))!
          .then((value) {
        if (value == true) {
          ShowToastDialog.showToast("Payment Successful!".tr);
          walletTopUp();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Payment Unsuccessful!! \n"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken(
      {required String orderId,
        required String currency,
        required BuildContext context,
        required String amount}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': "Basic ${paymentModel.value.orangePay!.auth!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
          context: context, amountData: amount, currency: currency, orderIdData: orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment(
      {required String orderIdData,
        required BuildContext context,
        required String currency,
        required String amountData}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl = paymentModel.value.orangePay!.isSandbox! == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key": paymentModel.value.orangePay!.merchantKey ?? '',
      "currency": paymentModel.value.orangePay!.isSandbox == true ? "OUV" : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url": paymentModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url": paymentModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url": paymentModel.value.orangePay!.notifUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(requestBody),
    );

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.",
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

  //Midtrans payment
  midtransMakePayment({required String amount, required BuildContext context}) async {
    await createPaymentLink(amount: amount).then((url) {
      ShowToastDialog.closeLoader();
      if (url != '') {
        Get.to(() => MidtransScreen(
          initialURl: url,
        ))!
            .then((value) {
          if (value == true) {
            ShowToastDialog.showToast("Payment Successful!".tr);
            walletTopUp();
          } else {
            ShowToastDialog.showToast("Payment Unsuccessful!".tr);
          }
        });
      }
    });
  }

  Future<String> createPaymentLink({required var amount}) async {
    var ordersId = Constant.getUuid();
    final url = Uri.parse(paymentModel.value.midtrans!.isSandbox == true
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': generateBasicAuthHeader(paymentModel.value.midtrans!.serverKey!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {"finish": "https://www.google.com?merchant_order_id=$ordersId"},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['payment_url'];
    } else {
      ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
      return '';
    }
  }

  final cardNumberController = TextEditingController();
  final cardExpMonthController = TextEditingController();
  final cardExpYearController = TextEditingController();
  final cardCvcController = TextEditingController();
  final RxString selectedBankCode = "1022".obs; // default bank code

  Future<void> cardPayment(BuildContext context) async {
    print(
        "Before processing epayco: APP keysa re: ${paymentModel.value.epayco?.publicKey}");
    print(
        "Before processing epayco: APP keysa re: ${paymentModel.value.epayco?.privateKey}");
    final epayco = EpaycoController(
      publicKey: paymentModel.value.epayco?.publicKey ?? "",
      privateKey: paymentModel.value.epayco?.privateKey ?? "",
    );
    await epayco.init();

    try {
      // await epayco.payByCreditCard(
      //
      //   value: "5000.0",  // Must not be empty!
      //   cardNumber: "4575623182290326",
      //   cardExpMonth: "12",
      //   cardExpYear: "2025",
      //   cardCvc: "123",
      //
      //   docType: "CC",
      //   docNumber:   '1234567890',
      //   name: "Bill",
      //   lastName: "TheCoder",
      //   email: "billthecoder046@gmail.com",
      //   cellPhone: "3001234567",
      //   phone:  "3001234567",// âœ… FIXED
      //   dues: "1",
      //   extra1: "wallet-${DateTime.now().millisecondsSinceEpoch}",
      //   extra2: "walletTopup",
      //   currency: "COP",
      //   methodConfirmation: "POST",
      //   testMode: paymentModel.value.epayco?.isSandbox ?? false,
      //     urlResponse: "https://www.test.com/epayco-response",     // âœ… Add this
      //     urlConfirmation: "https://www.test.com/epayco-confirm",
      // );

      final value = amountController.value.text.trim();
      if (value.isEmpty || double.tryParse(value) == null) {
        ShowToastDialog.showToast("Please enter a valid amount.".tr);
        return;
      }

      final fullName = driverUserModel.value.fullName?.trim() ?? "";
      final phone = driverUserModel.value.phoneNumber?.trim() ?? "";
      print("My phone Number: $phone");

      final email = driverUserModel.value.email?.trim() ?? "";

      if (fullName.isEmpty || phone.isEmpty || email.isEmpty) {
        ShowToastDialog.showToast("User details are incomplete.".tr);
        return;
      }
      TcTransactionResponse supp = await epayco.payByCreditCard(
        value: value,
        // already validated above
        cardNumber: cardNumberController.text.trim(),
        cardExpYear: cardExpYearController.text.trim(),
        cardExpMonth: cardExpMonthController.text.trim(),
        cardCvc: cardCvcController.text.trim(),

        docType: "CC",
        docNumber: phone,
        name: fullName,
        lastName: fullName,
        email: email,
        cellPhone: phone,
        phone: phone,

        dues: "1",
        extra1: "wallet-${DateTime.now().millisecondsSinceEpoch}",
        extra2: "walletTopup",
        currency: "COP",
        urlResponse: "https://www.test.com/epayco-response",
        urlConfirmation: "https://www.test.com/epayco-confirm",
        methodConfirmation: "POST",
        testMode: paymentModel.value.epayco?.isSandbox ?? false,
      );

      if (supp.success != null && supp.success == true) {
        ShowToastDialog.showToast("Card payment Successful.".tr);
        walletTopUp();
      } else {
        print("My suppData is: ${supp.data!.toJson()}");
        print(jsonEncode(supp.toJson()));
        // final errorMessage =
        //     supp.data?.error?.errors?.first.errorMessage ?? 'Unknown error';
        // ShowToastDialog.showToast(errorMessage);
      }
    } catch (e) {
      print("Card Error: $e");
      ShowToastDialog.showToast("Card payment failed.".tr);
    }
  }

  void showErrorDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

