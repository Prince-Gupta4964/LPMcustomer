// activity_list_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/customer/intro/widgets/job_progress_bar.dart';
import 'package:lightatech/customer/intro/widgets/order_status_card.dart';
import 'package:lightatech/customer/intro/models/order_status.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/customer/intro/viewmodel/order_detail_viewmodel.dart';


class ActivityListFirestore extends StatefulWidget {
  final String searchText;
  final String partyName;

  const ActivityListFirestore({
    super.key,
    required this.searchText,
    required this.partyName,

  });

  @override
  State<ActivityListFirestore> createState() => _ActivityListFirestoreState();
}

class _ActivityListFirestoreState extends State<ActivityListFirestore> {
  Stream<QuerySnapshot>? _jobsStream;
  int? _expandedIndex;


  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    if (widget.partyName.isNotEmpty && widget.partyName != 'Loading...') {
      _jobsStream = FirebaseFirestore.instance
          .collection("jobs")
          .where("designer.data.PartyName", isEqualTo: widget.partyName)
          .snapshots();
    } else {
      _jobsStream = null;
    }
  }

  @override
  void didUpdateWidget(covariant ActivityListFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partyName != widget.partyName) {
      _setupStream();
    }
  }
  Map<OrderStatus, bool> _getStepStatusFromStatus(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'designing':
      case 'inprogress':
        return {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: false,
          OrderStatus.autoBending: false,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
      case 'laser cutting':
      case 'laser':
        return {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: false,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
      case 'auto bending':
      case 'auto':
        return {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
      case 'manual bending':
      case 'manual':
        return {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: true,
          OrderStatus.delivered: false,
        };
      case 'delivery':
      case 'delivered':
        return {
          OrderStatus.designing: true,
          OrderStatus.laserCutting: true,
          OrderStatus.autoBending: true,
          OrderStatus.manualBending: true,
          OrderStatus.delivered: true,
        };
      default:
        return {
          OrderStatus.designing: false,
          OrderStatus.laserCutting: false,
          OrderStatus.autoBending: false,
          OrderStatus.manualBending: false,
          OrderStatus.delivered: false,
        };
    }
  }





  @override
  Widget build(BuildContext context) {
    if (_jobsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading activities"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No jobs assigned yet"));
        }

        final search = widget.searchText.trim().toLowerCase();

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designerData = (data['designer'] ?? {})['data'] ?? {};
          final lpm = (designerData['LpmAutoIncrement'] ?? "").toString().toLowerCase();
          final status = (data['status'] ?? "").toString().toLowerCase();

          if (search.isEmpty) return true;
          return lpm.contains(search) || status.contains(search);
        }).toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            // Try to use timestamp field first
            final aTimestamp = aData['timestamp'] as Timestamp?;
            final bTimestamp = bData['timestamp'] as Timestamp?;

            if (aTimestamp != null && bTimestamp != null) {
              return bTimestamp.compareTo(aTimestamp); // Latest first
            }

            // Fallback: use createdAt or any date field
            final aCreated = aData['createdAt'] as Timestamp?;
            final bCreated = bData['createdAt'] as Timestamp?;

            if (aCreated != null && bCreated != null) {
              return bCreated.compareTo(aCreated); // Latest first
            }

            return 0; // No timestamp available, keep original order
          });

        if (docs.isEmpty) {
          return const Center(child: Text("No matching entries"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final designerData = (data['designer'] ?? {})['data'] ?? {};

            final lpm = doc.id; // 👈
            final status = data['status'] ?? "No Status";

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                // onTap when expanding 👈 pass lpm too
                onTap: () {
                  setState(() {
                    if (_expandedIndex == index) {
                      _expandedIndex = null;
                    } else {

                      _expandedIndex = index;
                      context.read<OrderDetailViewModel>().listenToJob(lpm); // 👈 replaces updateFromStatus
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(
                                Icons.work_outline,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "LPM: $lpm",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Status: $status",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (_expandedIndex == index) ...[
                          const SizedBox(height: 12),

                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              context.go(
                                '/order-details',
                                extra: {
                                  'jobId': doc.id,
                                  'status': status,
                                  'lpm': lpm,
                                },
                              );
                            },
                            // Consumer reads per-LPM 👈
                            child: Consumer<OrderDetailViewModel>(
                              builder: (context, viewModel, _) {
                                return OrderStatusCard(
                                  stepStatus: viewModel.getStepStatus(lpm), // 👈 per-LPM
                                );
                              },
                            ),
                          ),
                        ],

                      ],
                    ),
                  ),


                ),
              ),
            );
          },
        );
      },
    );
  }
}