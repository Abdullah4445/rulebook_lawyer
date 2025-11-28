import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FareDetailsScreen extends StatefulWidget {
  final String orderId;
  final String acceptedDriverId;
  final Map<String, dynamic>? fareDetails;

  const FareDetailsScreen({
    super.key,
    required this.orderId,
    required this.acceptedDriverId,
    this.fareDetails,
  });

  @override
  State<FareDetailsScreen> createState() => _FareDetailsScreenState();
}

class _FareDetailsScreenState extends State<FareDetailsScreen> {
  Map<String, dynamic> fareDetails = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchFareDetails();
  }

  Future<void> fetchFareDetails() async {
    setState(() {
      loading = true;
    });

    final docRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .collection("acceptedDriver")
        .doc(widget.acceptedDriverId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      setState(() {
        loading = false;
      });
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;

    // Case total type ko normalize karo agar steps nahi hain to
    if (data['fareDetails']?['type'] == "case_total" &&
        data['fareDetails']?['steps'] == null) {
      await docRef.update({
        "fareDetails.steps": [
          {
            'title': data['fareDetails']?['title'] ?? "Case Total",
            'price': data['fareDetails']?['total'] ?? 0,
            'lawyerStatus': data['fareDetails']?['lawyerStatus'] ?? "pending",
            'customerStatus': data['fareDetails']?['customerStatus'] ?? "pending",
          }
        ]
      });

      // Dobara data fetch karo
      final updatedSnapshot = await docRef.get();
      final updatedData = updatedSnapshot.data() as Map<String, dynamic>;
      setState(() {
        fareDetails = updatedData['fareDetails'] ?? {};
        loading = false;
      });
    } else {
      setState(() {
        fareDetails = data['fareDetails'] ?? {};
        loading = false;
      });
    }
  }

  List getSteps() {
    List steps = [];

    if (fareDetails['type'] == "multi_steps") {
      if (fareDetails['steps'] is List) {
        steps = fareDetails['steps'];
      } else if (fareDetails['steps'] is Map) {
        steps = fareDetails['steps'].values.toList();
      }
    } else if (fareDetails['type'] == "case_total") {
      steps = [
        {
          'title': fareDetails['title'] ?? "Case Total",
          'price': fareDetails['total'] ?? 0,
          'lawyerStatus': fareDetails['lawyerStatus'] ?? "pending",
          'customerStatus': fareDetails['customerStatus'] ?? "pending",
        }
      ];
    }

    return steps;
  }

  Future<void> updateLawyerStatus(int stepIndex) async {
    final docRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .collection("acceptedDriver")
        .doc(widget.acceptedDriverId);

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final fare = data['fareDetails'];
    List steps = [];

    if (fare['type'] == "case_total") {
      // Case total type ke liye direct update karo
      await docRef.update({
        "fareDetails.lawyerStatus": "done",
      });

      await fetchFareDetails();
      return;
    }

    // Multi-steps type ke liye existing logic
    if (fare['steps'] is List) {
      steps = List<Map<String, dynamic>>.from(fare['steps']);
    } else if (fare['steps'] is Map) {
      steps = (fare['steps'] as Map).values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      return;
    }

    if (stepIndex >= steps.length) return;

    steps[stepIndex]['lawyerStatus'] = "done";

    await docRef.update({"fareDetails.steps": steps});
    await fetchFareDetails();
  }

  @override
  Widget build(BuildContext context) {
    final steps = getSteps();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFareDetails,
            tooltip: "Refresh",
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : steps.isEmpty
          ? const Center(
        child: Text(
          "No billing details available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Billing Details",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Steps List
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return stepCard(
                    index: index,
                    title: step['title'] ?? "Step ${index + 1}",
                    price: step['price'] ?? 0,
                    customerStatus: step['customerStatus'] ?? "pending",
                    lawyerStatus: step['lawyerStatus'] ?? "pending",
                    onMarkDone: () => updateLawyerStatus(index),
                  );
                },
              ),
            ),

            // Total Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                children: [
                  fareRow(
                    "Subtotal",
                    fareDetails['total']?.toString() ?? "0",
                    isBold: false,
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  fareRow(
                    "Total Amount",
                    fareDetails['total']?.toString() ?? "0",
                    isBold: true,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget stepCard({
    required int index,
    required String title,
    required dynamic price,
    required String lawyerStatus,
    required String customerStatus,
    required VoidCallback onMarkDone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(lawyerStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(lawyerStatus)),
                ),
                child: Text(
                  lawyerStatus.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _getStatusColor(lawyerStatus),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Price and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "Rs ${price.toString()}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Customer Status",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(customerStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      customerStatus.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _getStatusColor(customerStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Button
          if (lawyerStatus != "done")
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMarkDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Mark Lawyer Step Done",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Lawyer Step Completed",
                    style: GoogleFonts.poppins(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget fareRow(String title, String value, {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isTotal ? Colors.blue[700] : Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            "Rs $value",
            style: GoogleFonts.poppins(
              color: isTotal ? Colors.blue[700] : Colors.black87,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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
}






// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class FareDetailsScreen extends StatelessWidget {
//   final String orderId;
//   final String acceptedDriverId;
//   final Map<String, dynamic>? fareDetails;
//
//   const FareDetailsScreen({
//     super.key,
//     required this.orderId,
//     required this.acceptedDriverId,
//     this.fareDetails,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final fd = fareDetails ?? {};
//
//     List steps = [];
//
//     /// --- Multi Steps Handling ---
//     if (fd['type'] == "multi_steps") {
//       if (fd['steps'] is List) {
//         steps = fd['steps'];
//       } else if (fd['steps'] is Map) {
//         steps = fd['steps'].values.toList();
//       }
//     }
//
//     /// --- Case Total Handling ---
//     else if (fd['type'] == "case_total") {
//       steps = [
//         {
//           'title': fd['title'] ?? "",
//           'price': fd['total'] ?? 0,
//           'lawyerStatus': fd['lawyerStatus'] ?? "",
//           'customerStatus': fd['customerStatus'] ?? "",
//         }
//       ];
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Billing Details"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ListView(
//           children: [
//             Text(
//               "Billing Details",
//               style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             ...List.generate(steps.length, (index) {
//               final step = steps[index];
//
//               return stepCard(
//                 index: index,
//                 title: step['title'] ?? "",
//                 price: step['price'] ?? 0,
//                 customerStatus: step['customerStatus'] ?? "",
//                 lawyerStatus: step['lawyerStatus'] ?? "",
//                 onMarkDone: () {
//                   updateLawyerStatus(
//                     orderId,
//                     acceptedDriverId,
//                     index,
//                   );
//                 },
//               );
//             }),
//
//             const Divider(),
//
//             fareRow(
//               "Total",
//               fd['total']?.toString() ?? "0",
//               isBold: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ============================
//   ///     UPDATE LAWYER STATUS
//   /// ============================
//   Future<void> updateLawyerStatus(
//       String orderId,
//       String acceptedDriverId,
//       int stepIndex,
//       ) async {
//     final docRef = FirebaseFirestore.instance
//         .collection("orders")
//         .doc(orderId)
//         .collection("acceptedDriver")
//         .doc(acceptedDriverId);
//
//     final snapshot = await docRef.get();
//     if (!snapshot.exists) return;
//
//     final data = snapshot.data() as Map<String, dynamic>;
//     final fare = data['fareDetails'];
//
//     List steps = [];
//
//     // ------------------
//     // CASE TOTAL HANDLING
//     // ------------------
//     if (fare['type'] == "case_total") {
//       if (fare['steps'] is List) {
//         steps = List<Map<String, dynamic>>.from(fare['steps']);
//       } else if (fare['steps'] is Map) {
//         steps = (fare['steps'] as Map).values
//             .map((e) => Map<String, dynamic>.from(e))
//             .toList();
//       } else {
//         return;
//       }
//
//       // case_total mein sirf 1 step hota hai → index 0
//       steps[0]['lawyerStatus'] = "done";
//
//       await docRef.update({
//         "fareDetails.steps": steps,
//         "fareDetails.lawyerStatus": FieldValue.delete(), // Upar wali galat field remove
//       });
//
//       return;
//     }
//
//     // ------------------
//     // MULTI STEPS HANDLING
//     // ------------------
//     if (fare['steps'] is List) {
//       steps = List<Map<String, dynamic>>.from(fare['steps']);
//     } else if (fare['steps'] is Map) {
//       steps = (fare['steps'] as Map).values
//           .map((e) => Map<String, dynamic>.from(e))
//           .toList();
//     } else {
//       return;
//     }
//
//     if (stepIndex >= steps.length) return;
//
//     steps[stepIndex]['lawyerStatus'] = "done";
//
//     await docRef.update({
//       "fareDetails.steps": steps,
//     });
//   }
//
// }
//
// /// =========================
// ///       STEP CARD UI
// /// =========================
// Widget stepCard({
//   required int index,
//   required String title,
//   required dynamic price,
//   required String lawyerStatus,
//   required String customerStatus,
//   required VoidCallback onMarkDone,
// }) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 12),
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       color: Colors.grey.shade100,
//       border: Border.all(color: Colors.black12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         fareRow(title, price.toString()),
//
//         const SizedBox(height: 6),
//
//         Text("Customer Status: $customerStatus",
//             style: const TextStyle(color: Colors.black87)),
//         Text("Lawyer Status: $lawyerStatus",
//             style: const TextStyle(color: Colors.black87)),
//
//         const SizedBox(height: 10),
//
//         if (lawyerStatus != "done")
//           ElevatedButton(
//             onPressed: onMarkDone,
//             child: const Text("Mark Lawyer Done"),
//           )
//         else
//           const Text(
//             "✔ Lawyer Completed",
//             style: TextStyle(
//               color: Colors.green,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//       ],
//     ),
//   );
// }
//
// /// =========================
// ///       ROW UI
// /// =========================
// Widget fareRow(String title, String value, {bool isBold = false}) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: GoogleFonts.poppins(
//               color: Colors.black,
//               fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//         ),
//
//         const SizedBox(width: 10),
//
//         Text(
//           "Rs $value",
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
//
//
//
//
