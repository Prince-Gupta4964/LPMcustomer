import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;

  const JobSummaryScreen({
    super.key,
    required this.lpm,
  });

  Widget _field(String label, dynamic value) {
    final textValue = (value ?? "").toString().trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "$label : ${textValue.isEmpty ? "-" : textValue}",
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection("jobs")
        .where("designer.data.LpmAutoIncrement", isEqualTo: lpm) // 🔥 Nested field query
        .limit(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Job Summary - $lpm"),
        backgroundColor: Colors.yellow,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: query.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading job summary"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No job found for LPM: $lpm"));
          }

          final docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // 🔹 Nested designer.data
          final designerData = (docData['designer'] as Map<String, dynamic>)['data'] as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  // 🔹 Top-level fields
                  _field("Status", docData["status"]),
                  _field("Current Department", docData["currentDepartment"]),

                  const Divider(height: 25),

                  // 🔹 Designer.data fields
                  _field("Particular Job Name", designerData["ParticularJobName"]),
                  _field("Created By", designerData["CreatedBy"]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
