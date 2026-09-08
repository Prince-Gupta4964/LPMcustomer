import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';

class NotificationsScreen extends StatefulWidget {
  final String partyName;
  final String email;

  const NotificationsScreen({
    super.key,
    required this.partyName,
    required this.email,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _partyName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _partyName = widget.partyName;
    if (_partyName.isEmpty ||
        _partyName == 'No Name' ||
        _partyName == 'Loading...') {
      _fetchPartyName();
    }
  }

  Future<void> _fetchPartyName() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('customers')
          .where('Email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final username = doc['Username'];
        if (username != null && username.toString().isNotEmpty) {
          setState(() => _partyName = username.toString());
          debugPrint('Fetched partyName from Firestore: $_partyName');
        }
      }
    } catch (e) {
      debugPrint('Error fetching partyName: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'NotificationsScreen partyName: $_partyName, email: ${widget.email}',
    );
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8D94B),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Approved'),
            Tab(text: 'Changes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificationList(
            partyName: _partyName,
            status: 'pending',
            emptyMessage: 'No new notifications',
            emptyIcon: Icons.notifications_off_outlined,
          ),
          _NotificationList(
            partyName: _partyName,
            status: 'approved',
            emptyMessage: 'No approved forms',
            emptyIcon: Icons.check_circle_outline,
          ),
          _NotificationList(
            partyName: _partyName,
            status: 'changes',
            emptyMessage: 'No changes',
            emptyIcon: Icons.update,
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final String partyName;
  final String status;
  final String emptyMessage;
  final IconData emptyIcon;

  const _NotificationList({
    required this.partyName,
    required this.status,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (partyName.isEmpty || partyName == 'Loading...') {
      return const Center(child: CircularProgressIndicator());
    }

    debugPrint('Notification Query - partyName: $partyName, status: $status');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .where("designer.data.PartyName", isEqualTo: partyName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text("Error: ${snapshot.error}"),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final allDocs = snapshot.data!.docs;

        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final approvalStatus = data['customerApprovalStatus'] as String?;

          if (status == 'pending') {
            return approvalStatus == 'pending';
          } else if (status == 'approved') {
            return approvalStatus == 'approved';
          } else if (status == 'changes') {
            return approvalStatus == 'changes';
          }
          return false;
        }).toList();

        // Sort newest first
        filteredDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['designer']?['submittedAt'] as Timestamp?;
          final bTime = bData['designer']?['submittedAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime); // descending = newest first
        });

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(emptyIcon, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final designerData = (data['designer'] ?? {})['data'] ?? {};

            final lpm = doc.id;
            final partyName = designerData['PartyName'] ?? 'N/A';
            final jobName =
                designerData['particularJobName'] ??
                    designerData['ParticularJobName'] ??
                    'N/A';
            final submittedBy = designerData['DesignerCreatedBy'] ?? 'Unknown';
            final submittedAt = data['designer']?['submittedAt'];

            return _NotificationCard(
              lpm: lpm,
              partyName: partyName,
              jobName: jobName,
              submittedBy: submittedBy,
              submittedAt: submittedAt,
              status: status,
            );
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String lpm;
  final String partyName;
  final String jobName;
  final String submittedBy;
  final Timestamp? submittedAt;
  final String status;

  const _NotificationCard({
    required this.lpm,
    required this.partyName,
    required this.jobName,
    required this.submittedBy,
    required this.submittedAt,
    required this.status,
  });

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'approved';
    final isChanges = status == 'changes';

    Color statusColor;
    IconData statusIcon;
    String displayStatus;

    if (isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      displayStatus = 'APPROVED';
    } else if (isChanges) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      displayStatus = 'CHANGES REQUESTED';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      displayStatus = 'PENDING APPROVAL';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'LPM: $lpm',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Party', value: partyName),
                _InfoRow(label: 'Submitted By', value: submittedBy),
                _InfoRow(label: 'Date', value: _formatDate(submittedAt)),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/notification-job-summary',
                        extra: {
                          'lpm': lpm,
                          'status': status,
                          'partyName': partyName,
                          'jobName': jobName,
                          'submittedBy': submittedBy,
                          'submittedAt': submittedAt,
                        },
                      );
                    },
                    child: const Text("View Job"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}