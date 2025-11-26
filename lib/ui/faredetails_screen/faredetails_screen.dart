import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class FareDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? fareDetails;

  const FareDetailsScreen({super.key, this.fareDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        title: const Text("Billing Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Billing Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            const SizedBox(height: 10),

            if (fareDetails?['steps'] != null)
              ...List<Map<String, dynamic>>.from(fareDetails!['steps'])
                  .map(
                    (step) => fareRow(
                  step['title'] ?? "",
                  step['price'].toString(),
                ),
              )
                  .toList(),

            const Divider(),

            fareRow(
              "Total",
              fareDetails?['total'].toString() ?? "0",
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}


Widget fareRow(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TITLE with 3 Dots
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

        // PRICE
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
