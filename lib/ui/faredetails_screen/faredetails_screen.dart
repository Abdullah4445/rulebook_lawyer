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
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    fetchFareDetails();
  }

  Future<void> fetchFareDetails() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderId)
          .collection("acceptedDriver")
          .doc(widget.acceptedDriverId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;

      if (data['fareDetails']?['type'] == "case_total" &&
          data['fareDetails']?['steps'] == null) {
        await docRef.update({
          "fareDetails.steps": [
            {
              'title': data['fareDetails']?['title'] ?? "Case Total",
              'price': data['fareDetails']?['total'] ?? 0,
              'lawyerStatus': data['fareDetails']?['lawyerStatus'] ?? "pending",
              'customerStatus': data['fareDetails']?['customerStatus'] ?? "pending",
              'driverConfirmed': data['fareDetails']?['driverConfirmed'] ?? false,
            }
          ]
        });

        final updatedSnapshot = await docRef.get();
        final updatedData = updatedSnapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            fareDetails = updatedData['fareDetails'] ?? {};
            loading = false;
            refreshing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            fareDetails = data['fareDetails'] ?? {};
            loading = false;
            refreshing = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching fare details: $e");
      if (mounted) {
        setState(() {
          loading = false;
          refreshing = false;
        });
      }
    }
  }

  // Refresh function
  Future<void> refreshData() async {
    if (!mounted) return;
    setState(() {
      refreshing = true;
    });
    await fetchFareDetails();
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
      if (fareDetails['steps'] != null && (fareDetails['steps'] as List).isNotEmpty) {
        steps = fareDetails['steps'];
      } else {
        steps = [
          {
            'title': fareDetails['title'] ?? "Case Total",
            'price': fareDetails['total'] ?? 0,
            'lawyerStatus': fareDetails['lawyerStatus'] ?? "pending",
            'customerStatus': fareDetails['customerStatus'] ?? "pending",
            'driverConfirmed': fareDetails['driverConfirmed'] ?? false,
          }
        ];
      }
    }
    return steps;
  }

  Future<void> updateLawyerStatus(int stepIndex) async {
    setState(() => loading = true);
    final docRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .collection("acceptedDriver")
        .doc(widget.acceptedDriverId);

    try {
      final snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      final fare = data['fareDetails'];

      if (fare['type'] == "case_total") {
        Map<String, dynamic> updates = {"fareDetails.lawyerStatus": "done"};
        if (fare['steps'] != null) {
          List steps = List.from(fare['steps']);
          steps[0]['lawyerStatus'] = "done";
          updates["fareDetails.steps"] = steps;
        }
        await docRef.update(updates);
      } else {
        List steps = List<Map<String, dynamic>>.from(fare['steps'] ?? []);
        steps[stepIndex]['lawyerStatus'] = "done";
        await docRef.update({"fareDetails.steps": steps});
      }

      await fetchFareDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lawyer status updated to Done')),
      );
    } catch (e) {
      debugPrint("Error updating lawyer status: $e");
      setState(() => loading = false);
    }
  }

  Future<void> confirmPayment(int stepIndex) async {
    setState(() => loading = true);
    final docRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .collection("acceptedDriver")
        .doc(widget.acceptedDriverId);

    try {
      final snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      final fare = data['fareDetails'];

      if (fare['type'] == 'case_total') {
        Map<String, dynamic> updates = {
          'fareDetails.customerStatus': 'done',
          'fareDetails.lawyerStatus': 'done',
          'fareDetails.driverConfirmed': true,
        };
        if (fare['steps'] != null) {
          List steps = List.from(fare['steps']);
          steps[0]['customerStatus'] = 'done';
          steps[0]['lawyerStatus'] = 'done';
          steps[0]['driverConfirmed'] = true;
          updates["fareDetails.steps"] = steps;
        }
        await docRef.update(updates);
      } else {
        List steps = List<Map<String, dynamic>>.from(fare['steps'] ?? []);
        steps[stepIndex]['customerStatus'] = 'done';
        steps[stepIndex]['lawyerStatus'] = 'done';
        steps[stepIndex]['driverConfirmed'] = true;
        await docRef.update({'fareDetails.steps': steps});
      }

      await fetchFareDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment & Lawyer Step Confirmed')),
      );
    } catch (e) {
      debugPrint("Error confirming payment: $e");
      setState(() => loading = false);
    }
  }

  Future<void> cancelCustomerDone(int stepIndex) async {
    setState(() => loading = true);
    final docRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderId)
        .collection("acceptedDriver")
        .doc(widget.acceptedDriverId);

    try {
      final snapshot = await docRef.get();
      final data = snapshot.data() as Map<String, dynamic>;
      final fare = data['fareDetails'];

      if (fare['type'] == "case_total") {
        Map<String, dynamic> updates = {"fareDetails.customerStatus": "pending"};
        if (fare['steps'] != null) {
          List steps = List.from(fare['steps']);
          steps[0]['customerStatus'] = 'pending';
          steps[0].remove('driverConfirmed');
          updates["fareDetails.steps"] = steps;
        }
        await docRef.update(updates);
      } else {
        List steps = List<Map<String, dynamic>>.from(fare['steps'] ?? []);
        steps[stepIndex]['customerStatus'] = 'pending';
        steps[stepIndex].remove('driverConfirmed');
        await docRef.update({"fareDetails.steps": steps});
      }
      await fetchFareDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer status set to Pending')),
      );
    } catch (e) {
      debugPrint("Error canceling customer done: $e");
      setState(() => loading = false);
    }
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
          // Refresh Button
          IconButton(
            onPressed: refreshing ? null : refreshData,
            icon: refreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
        onRefresh: refreshData,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with manual refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Summary",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Small refresh button
                  // IconButton(
                  //   onPressed: refreshing ? null : refreshData,
                  //   icon: refreshing
                  //       ? const SizedBox(
                  //     width: 20,
                  //     height: 20,
                  //     child: CircularProgressIndicator(
                  //       strokeWidth: 2,
                  //       color: Colors.black,
                  //     ),
                  //   )
                  //       : const Icon(
                  //     Icons.refresh,
                  //     size: 24,
                  //   ),
                  //   tooltip: 'Refresh',
                  // ),
                ],
              ),
              const SizedBox(height: 16),
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
                      driverConfirmed: (step['driverConfirmed'] == true),
                      onMarkDone: () => updateLawyerStatus(index),
                    );
                  },
                ),
              ),
              _buildTotalSection(),
            ],
          ),
        ),
      ),
      // Floating Action Button for refresh
      // floatingActionButton: FloatingActionButton(
      //   onPressed: refreshing ? null : refreshData,
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
      //   child: refreshing
      //       ? const CircularProgressIndicator(
      //     color: Colors.white,
      //     strokeWidth: 2,
      //   )
      //       : const Icon(Icons.refresh),
      //   tooltip: 'Refresh Data',
      // ),
    );
  }

  Widget stepCard({
    required int index,
    required String title,
    required dynamic price,
    required String lawyerStatus,
    required String customerStatus,
    required bool driverConfirmed,
    required VoidCallback onMarkDone,
  }) {
    bool isLawyerDone = lawyerStatus.toLowerCase() == "done";
    bool isCustomerDone = customerStatus.toLowerCase() == "done";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "STEP ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              _statusBadge(lawyerStatus, "Lawyer"),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fee",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Rs $price",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Customer",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  _statusBadge(customerStatus, "Client"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (driverConfirmed)
            _completedBanner("✔ Step Fully Completed & Paid")
          else if (isCustomerDone && !driverConfirmed)
            _buildDriverConfirmationRow(index)
          else if (!isLawyerDone)
              _buildLawyerActionBtn(onMarkDone)
            else
              _completedBanner("Waiting for Customer Payment..."),
        ],
      ),
    );
  }

  Widget _buildLawyerActionBtn(VoidCallback onMarkDone) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onMarkDone,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text("Mark Step Done"),
      ),
    );
  }

  Widget _buildDriverConfirmationRow(int index) {
    return Column(
      children: [
        const Text(
          "Customer claims payment is done. Confirm?",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => confirmPayment(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirm"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => cancelCustomerDone(index),
                child: const Text("No/Reject"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _completedBanner(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _statusBadge(String status, String prefix) {
    Color color = status.toLowerCase() == "done" ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        "$prefix: ${status.toUpperCase()}",
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Grand Total",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "Rs ${fareDetails['total'] ?? 0}",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}