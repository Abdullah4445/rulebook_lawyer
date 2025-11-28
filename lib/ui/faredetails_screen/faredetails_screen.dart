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
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      fareDetails = data['fareDetails'] ?? {};
      loading = false;
    });
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
      steps = [
        {
          'title': fare['title'] ?? "Case Total",
          'price': fare['total'] ?? 0,
          'lawyerStatus': "done",
          'customerStatus': fare['customerStatus'] ?? "pending",
        }
      ];

      await docRef.update({
        "fareDetails.steps": steps,
        "fareDetails.lawyerStatus": FieldValue.delete(), // remove old
      });

      await fetchFareDetails();
      return;
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFareDetails,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(
              "Billing Details",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(steps.length, (index) {
              final step = steps[index];
              return stepCard(
                index: index,
                title: step['title'] ?? "",
                price: step['price'] ?? 0,
                customerStatus: step['customerStatus'] ?? "",
                lawyerStatus: step['lawyerStatus'] ?? "",
                onMarkDone: () => updateLawyerStatus(index),
              );
            }),

            const Divider(),
            fareRow(
              "Total",
              fareDetails['total']?.toString() ?? "0",
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
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
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.shade100,
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fareRow(title, price.toString()),
        const SizedBox(height: 6),
        Text("Customer Status: $customerStatus",
            style: const TextStyle(color: Colors.black87)),
        Text("Lawyer Status: $lawyerStatus",
            style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 10),
        if (lawyerStatus != "done")
          ElevatedButton(
            onPressed: onMarkDone,
            child: const Text("Mark Lawyer Done"),
          )
        else
          const Text(
            "✔ Lawyer Completed",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    ),
  );
}

Widget fareRow(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Rs $value",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
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
