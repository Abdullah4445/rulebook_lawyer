// import 'package:lawyer/constant/constant.dart';
// import 'package:lawyer/model/order_model.dart';
// import 'package:get/get.dart';
//
// class CompleteOrderController extends GetxController {
//   RxBool isLoading = true.obs;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     getArgument();
//     super.onInit();
//   }
//
//   Rx<OrderModel> orderModel = OrderModel().obs;
//
//   RxString couponAmount = "0.0".obs;
//
//   double calculateAmount() {
//     RxString taxAmount = "0.0".obs;
//     if (orderModel.value.taxList != null) {
//       for (var element in orderModel.value.taxList!) {
//         taxAmount.value = (double.parse(taxAmount.value) +
//                 Constant().calculateTax(amount: (double.parse(orderModel.value.finalRate.toString()) - double.parse(couponAmount.value.toString())).toString(), taxModel: element))
//             .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
//       }
//     }
//     return (double.parse(orderModel.value.finalRate.toString()) - double.parse(couponAmount.value.toString())) + double.parse(taxAmount.value);
//   }
//
//   getArgument() async {
//     dynamic argumentData = Get.arguments;
//     if (argumentData != null) {
//       orderModel.value = argumentData['orderModel'];
//
//       if (orderModel.value.coupon != null) {
//         if (orderModel.value.coupon?.code != null) {
//           if (orderModel.value.coupon!.type == "fix") {
//             couponAmount.value = orderModel.value.coupon!.amount.toString();
//           } else {
//             couponAmount.value =
//                 ((double.parse(orderModel.value.finalRate.toString()) * double.parse(orderModel.value.coupon!.amount.toString())) / 100).toString();
//           }
//         }
//
//       }
//     }
//     isLoading.value = false;
//     update();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lawyer/constant/constant.dart';
import 'package:lawyer/constant/collection_name.dart';
import 'package:lawyer/model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompleteOrderController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool loadingSteps = false.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  RxString couponAmount = "0.0".obs;

  // Steps history Ú©Û’ Ù„Ø¦Û’
  RxList<Map<String, dynamic>> stepsHistory = <Map<String, dynamic>>[].obs;

  double calculateAmount() {
    RxString taxAmount = "0.0".obs;
    if (orderModel.value.taxList != null) {
      for (var element in orderModel.value.taxList!) {
        taxAmount.value = (double.parse(taxAmount.value) +
            Constant().calculateTax(
                amount: (double.parse(orderModel.value.finalRate.toString()) -
                    double.parse(couponAmount.value.toString())).toString(),
                taxModel: element))
            .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
      }
    }
    return (double.parse(orderModel.value.finalRate.toString()) -
        double.parse(couponAmount.value.toString())) +
        double.parse(taxAmount.value);
  }

  // Steps history fetch Ú©Ø±Ù†Û’ Ú©Ø§ function
  Future<void> fetchStepsHistory() async {
    try {
      loadingSteps.value = true;

      // Check if driverId exists
      if (orderModel.value.driverId == null || orderModel.value.driverId!.isEmpty) {
        print("Driver ID not found");
        loadingSteps.value = false;
        return;
      }

      // Check acceptedDriver collection Ù…ÛŒÚº fareDetails
      final acceptedDriverRef = FirebaseFirestore.instance
          .collection(CollectionName.orders)
          .doc(orderModel.value.id)
          .collection("acceptedDriver")
          .doc(orderModel.value.driverId);

      final snapshot = await acceptedDriverRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print("Fetched data from acceptedDriver: $data");

        if (data.containsKey('fareDetails') && data['fareDetails'] != null) {
          final fareDetails = data['fareDetails'];

          // Step 1: Check for case_total type
          if (fareDetails['type'] == "case_total") {
            if (fareDetails['steps'] != null &&
                fareDetails['steps'] is List &&
                (fareDetails['steps'] as List).isNotEmpty) {

              stepsHistory.value = List<Map<String, dynamic>>.from(fareDetails['steps']);

            } else {
              // Single step case - create step from fareDetails
              stepsHistory.value = [
                {
                  'title': fareDetails['title'] ?? "Case Total",
                  'price': fareDetails['total'] ?? fareDetails['price'] ?? 0,
                  'lawyerStatus': fareDetails['lawyerStatus'] ?? "pending",
                  'customerStatus': fareDetails['customerStatus'] ?? "pending",
                  'driverConfirmed': fareDetails['driverConfirmed'] ?? false,
                  'duration': fareDetails['caseDuration'] ?? fareDetails['duration'],
                  'timestamp': fareDetails['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                  'stepNumber': 1,
                }
              ];
            }

          }
          // Step 2: Check for multi_steps type
          else if (fareDetails['type'] == "multi_steps") {
            if (fareDetails['steps'] != null) {
              if (fareDetails['steps'] is List) {
                stepsHistory.value = List<Map<String, dynamic>>.from(fareDetails['steps']);
              } else if (fareDetails['steps'] is Map) {
                // Convert Map to List
                stepsHistory.value = List<Map<String, dynamic>>.from(
                    (fareDetails['steps'] as Map).values
                );
              }
            }
          }

          // Step 3: Ø§Ú¯Ø± Ú©Ú†Ú¾ Ù†ÛÛŒÚº Ù…Ù„Ø§ ØªÙˆ default steps Ø¨Ù†Ø§Ø¦ÛŒÚº
          if (stepsHistory.isEmpty) {
            stepsHistory.value = [
              {
                'title': 'Case Completion',
                'price': orderModel.value.finalRate ?? 0,
                'lawyerStatus': 'done',
                'customerStatus': 'done',
                'driverConfirmed': true,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'stepNumber': 1,
              }
            ];
          }

          // Add step numbers if not present
          for (int i = 0; i < stepsHistory.length; i++) {
            if (!stepsHistory[i].containsKey('stepNumber')) {
              stepsHistory[i]['stepNumber'] = i + 1;
            }
          }

          // Sort by stepNumber or timestamp
          stepsHistory.sort((a, b) {
            if (a.containsKey('stepNumber') && b.containsKey('stepNumber')) {
              return a['stepNumber'].compareTo(b['stepNumber']);
            } else if (a.containsKey('timestamp') && b.containsKey('timestamp')) {
              return a['timestamp'].compareTo(b['timestamp']);
            }
            return 0;
          });

        } else {
          // Ø§Ú¯Ø± fareDetails Ù†ÛÛŒÚº ÛÛ’ ØªÙˆ default steps Ø¨Ù†Ø§Ø¦ÛŒÚº
          stepsHistory.value = [
            {
              'title': 'Case Completion',
              'price': orderModel.value.finalRate ?? 0,
              'lawyerStatus': 'done',
              'customerStatus': 'done',
              'driverConfirmed': true,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'stepNumber': 1,
            }
          ];
        }
      } else {
        // Ø§Ú¯Ø± acceptedDriver document Ù†ÛÛŒÚº Ù…Ù„Ø§ ØªÙˆ direct order document Ø³Û’ check Ú©Ø±ÛŒÚº
        print("No acceptedDriver document found, checking order document...");

        // Order document Ø³Û’ fareDetails check Ú©Ø±ÛŒÚº
        final orderDoc = await FirebaseFirestore.instance
            .collection(CollectionName.orders)
            .doc(orderModel.value.id)
            .get();

        if (orderDoc.exists) {
          final orderData = orderDoc.data();
          if (orderData != null && orderData.containsKey('fareDetails')) {
            // ... same logic as above ...
          } else {
            // Default steps
            stepsHistory.value = [
              {
                'title': 'Case Completion',
                'price': orderModel.value.finalRate ?? 0,
                'lawyerStatus': 'done',
                'customerStatus': 'done',
                'driverConfirmed': true,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'stepNumber': 1,
              }
            ];
          }
        }
      }

      print("Steps history loaded: ${stepsHistory.length} steps");

    } catch (e) {
      print("Error fetching steps history: $e");
      // Error Ú©Û’ case Ù…ÛŒÚº default steps
      stepsHistory.value = [
        {
          'title': 'Case Completion',
          'price': orderModel.value.finalRate ?? 0,
          'lawyerStatus': 'done',
          'customerStatus': 'done',
          'driverConfirmed': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'stepNumber': 1,
        }
      ];
    } finally {
      loadingSteps.value = false;
      update();
    }
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];

      if (orderModel.value.coupon != null) {
        if (orderModel.value.coupon?.code != null) {
          if (orderModel.value.coupon!.type == "fix") {
            couponAmount.value = orderModel.value.coupon!.amount.toString();
          } else {
            couponAmount.value =
                ((double.parse(orderModel.value.finalRate.toString()) *
                    double.parse(orderModel.value.coupon!.amount.toString())) / 100).toString();
          }
        }
      }

      // Arguments load ÛÙˆÙ†Û’ Ú©Û’ Ø¨Ø¹Ø¯ steps history fetch Ú©Ø±ÛŒÚº
      await fetchStepsHistory();
    }
    isLoading.value = false;
    update();
  }

  // Helper function to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper function to format timestamp
  String formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
