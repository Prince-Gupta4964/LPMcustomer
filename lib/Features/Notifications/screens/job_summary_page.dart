import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class NotificationJobSummaryPage extends StatefulWidget {
  final String lpm;
  final String status;

  const NotificationJobSummaryPage({
    super.key,
    required this.lpm,
    required this.status,
  });

  @override
  State<NotificationJobSummaryPage> createState() =>
      _NotificationJobSummaryPageState();
}

class _NotificationJobSummaryPageState
    extends State<NotificationJobSummaryPage> {
  bool _showChangesBox = false;
  final TextEditingController _changesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _changesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Summary"),
        backgroundColor: const Color(0xFFF8D94B),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.lpm)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final designerData = (data['designer'] ?? {})['data'] ?? {};

          final partyName = designerData['PartyName'] ?? 'N/A';
          final jobName =
              designerData['particularJobName'] ??
                  designerData['ParticularJobName'] ??
                  'N/A';

          final approvalStatus = data['customerApprovalStatus'];
          final customerChangesNote =
              data['customerChangesNote'] as String? ?? '';

          return Column(
            children: [
              /// APPROVE / CHANGES BUTTONS
              if (approvalStatus == 'pending')
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showChangesBox = !_showChangesBox;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                          child: const Text("Changes"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleApproval(context, 'approved', null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Approve"),
                        ),
                      ),
                    ],
                  ),
                ),

              /// CHANGES TEXT BOX
              if (_showChangesBox && approvalStatus == 'pending')
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _changesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe what changes are needed...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitChanges(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          disabledBackgroundColor:
                          Colors.orange.withOpacity(0.5),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Submit Changes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              /// DISPLAY REQUESTED CHANGES - ONLY in Changes section
              if (customerChangesNote.isNotEmpty && widget.status == 'changes')
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Requested Changes',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customerChangesNote,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// JOB DETAILS
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _row("LPM", widget.lpm),
                    _row("Party Name", partyName),
                    _row("Job Name", jobName),

                    const SizedBox(height: 20),

                    const Text(
                      "All Form Data",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),

                    ...designerData.entries.map((e) {
                      return _row(e.key, e.value.toString());
                    }).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _submitChanges(BuildContext context) async {
    final text = _changesController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the changes needed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await _handleApproval(context, 'changes', text);

    setState(() => _isSubmitting = false);
  }

  Future<void> _handleApproval(
      BuildContext context,
      String status,
      String? changesNote,
      ) async {
    final updateData = <String, dynamic>{
      'customerApprovalStatus': status,
      'customerApprovalAt': FieldValue.serverTimestamp(),
    };

    if (changesNote != null && changesNote.isNotEmpty) {
      updateData['customerChangesNote'] = changesNote;
    }

    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.lpm)
        .update(updateData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Approved successfully'
                : 'Changes submitted successfully',
          ),
          backgroundColor:
          status == 'approved' ? Colors.green : Colors.orange,
        ),
      );

      context.pop();
    }
  }
}