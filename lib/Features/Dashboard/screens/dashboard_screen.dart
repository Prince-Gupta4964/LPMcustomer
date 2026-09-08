import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/sidebar_menu.dart';
import '../widgets/customer_activity_list.dart';
import '../widgets/dashboard_appbar.dart';
import '../widgets/activity_list_firestore.dart';

class DashboardScreen extends StatefulWidget {
  final String email;
  final String partyName;

  const DashboardScreen({
    super.key,
    required this.email,
    required this.partyName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final searchController = TextEditingController();
  String userName = 'Loading...';
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('📧 Email from session: "${widget.email}"');
    debugPrint('👤 PartyName from session: "${widget.partyName}"');
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('customers')
          .where('Email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        setState(() {
          userName = doc['Username'] ?? widget.partyName;
        });
      } else {
        // ✅ Fall back to partyName from session rather than hardcoded 'No Name'
        setState(() => userName = widget.partyName.isNotEmpty
            ? widget.partyName
            : 'No Name');
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() => userName = widget.partyName.isNotEmpty
          ? widget.partyName
          : 'Error');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SidebarMenu(),
      appBar: DashboardAppBar(
        showBack: false,
        username: userName,
        searchController: searchController,
        onSearchChanged: (val) => setState(() {}),
      ),
      body: Column(
        children: [
          // ── Tab Bar ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0
                                ? const Color(0xFFF8D94B)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'My Forms',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedTabIndex == 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedTabIndex == 0
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1
                                ? const Color(0xFFF8D94B)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Designer Forms',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedTabIndex == 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedTabIndex == 1
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Tab Content ──────────────────────────────────────────────
          Expanded(
            child: _selectedTabIndex == 0
                ? CustomerActivityList(
              searchText: searchController.text,
              partyName: userName,
            )
                : ActivityListFirestore(
              searchText: searchController.text,
              partyName: userName,
            ),
          ),
        ],
      ),

      // ── FAB: pass customerName as query param — survives refresh ────
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF8D94B),
        onPressed: () {
          // ✅ Use query parameter instead of extra.
          // extra is lost on browser refresh; query params are not.
          final name = Uri.encodeComponent(userName);
          context.push('/customer-form?name=$name');
        },
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}