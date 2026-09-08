import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'job_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  final String partyName;

  const HistoryScreen({
    Key? key,
    required this.partyName,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where(
          'delivery.data.DeliveryStatus',
          isEqualTo: 'Done',
        )
            .where(
          'designer.data.PartyName',
          isEqualTo: partyName,
        )
            .snapshots(),
        builder: (context, snapshot) {
          // ----------------------------------------------------------
          // LOADING
          // ----------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------------------
          // ERROR
          // ----------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading history',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ----------------------------------------------------------
          // NO DATA
          // ----------------------------------------------------------

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No history found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ----------------------------------------------------------
          // JOBS
          // ----------------------------------------------------------

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final document = jobs[index];

              final data =
              document.data() as Map<String, dynamic>;

              return _JobCard(
                documentId: document.id,
                data: data,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(
                        documentId: document.id,
                        jobData: data,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================================
// JOB CARD
// =====================================================================

class _JobCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _JobCard({
    required this.documentId,
    required this.data,
    required this.onTap,
  });

  String _getValue(List<String> path) {
    dynamic current = data;

    for (final key in path) {
      if (current is Map) {
        current = current[key];
      } else {
        return '';
      }
    }

    return current?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final jobNumber = _getValue([
      'designer',
      'data',
      'LpmAutoIncrement',
    ]);

    final partyName = _getValue([
      'designer',
      'data',
      'PartyName',
    ]);

    final jobName = _getValue([
      'designer',
      'data',
      'particularJobName',
    ]);

    final designer = _getValue([
      'designer',
      'data',
      'DesignedBy',
    ]);

    final priority = _getValue([
      'designer',
      'data',
      'Priority',
    ]);

    final deliveryStatus = _getValue([
      'delivery',
      'data',
      'DeliveryStatus',
    ]);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------------
              // TOP ROW
              // ------------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.work_history,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobNumber.isEmpty
                              ? documentId
                              : jobNumber,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (partyName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            partyName,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // STATUS
                  // ------------------------------------------------

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      deliveryStatus.isEmpty
                          ? 'Done'
                          : deliveryStatus,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------------
              // JOB NAME
              // ------------------------------------------------------

              if (jobName.isNotEmpty)
                _InfoRow(
                  icon: Icons.description_outlined,
                  label: 'Job',
                  value: jobName,
                ),

              // ------------------------------------------------------
              // DESIGNER
              // ------------------------------------------------------

              if (designer.isNotEmpty)
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Designer',
                  value: designer,
                ),

              // ------------------------------------------------------
              // PRIORITY
              // ------------------------------------------------------

              if (priority.isNotEmpty)
                _InfoRow(
                  icon: Icons.priority_high,
                  label: 'Priority',
                  value: priority,
                ),

              const SizedBox(height: 5),

              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// INFO ROW
// =====================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}