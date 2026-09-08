// customer_activity_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerActivityList extends StatefulWidget {
  final String searchText;
  final String partyName;

  const CustomerActivityList({
    super.key,
    required this.searchText,
    required this.partyName,
  });

  @override
  State<CustomerActivityList> createState() => _CustomerActivityListState();
}

class _CustomerActivityListState extends State<CustomerActivityList> {
  Stream<QuerySnapshot>? _customersStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    final trimmedPartyName = widget.partyName.trim();  // ✅ TRIM HERE

    if (trimmedPartyName.isNotEmpty && trimmedPartyName != 'Loading...') {
      print('🔍 Querying for partyName: "$trimmedPartyName"');
      _customersStream = FirebaseFirestore.instance
          .collection("customer_requests")
          .where("partyName", isEqualTo: trimmedPartyName)  // ✅ Use trimmed value
          .snapshots();
    } else {
      _customersStream = null;
    }
  }

  @override
  void didUpdateWidget(covariant CustomerActivityList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partyName != widget.partyName) {
      _setupStream();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'hot':
        return Colors.red;
      case 'paid':
        return Colors.blue;
      case 'cold':
        return Colors.blueGrey;
      case 'hold':
        return Colors.orange;
      case 'cancel':
        return Colors.grey;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customersStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _customersStream,
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
                const Text("Error loading forms"),
                const SizedBox(height: 8),
                Text(
                  "${snapshot.error}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No jobs submitted yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final search = widget.searchText.trim().toLowerCase();

        var docs = snapshot.data!.docs.toList();

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });

        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final partyName = (data['partyName'] ?? "").toString().toLowerCase();
          final orderBy = (data['orderBy'] ?? "").toString().toLowerCase();
          final deliveryAt = (data['deliveryAt'] ?? "").toString().toLowerCase();

          if (search.isEmpty) return true;
          return partyName.contains(search) ||
              orderBy.contains(search) ||
              deliveryAt.contains(search);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text("No matching entries"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final orderBy = data['orderBy'] ?? "N/A";
            final particularJobName = data['particularJobName'] ?? "N/A";
            final phone = data['phone'] ?? "";

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        orderBy.isNotEmpty ? orderBy[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + Job
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderBy,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            particularJobName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Call Icon
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF1A73E8),
                        child: Icon(Icons.call, color: Colors.white, size: 16),
                      ),
                      onPressed: () => _launchPhone(phone),
                    ),

                    const SizedBox(width: 6),

                    // WhatsApp Icon
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF25D366),
                        child: Icon(Icons.chat, color: Colors.white, size: 16),
                      ),
                      onPressed: () => _launchWhatsApp(phone),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}