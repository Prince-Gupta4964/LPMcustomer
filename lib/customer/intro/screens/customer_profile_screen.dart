import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends State<CustomerProfileScreen> {

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  /// 🔥 FETCH USER FROM SESSION
  Future<void> fetchUser() async {
    final session = SessionManager.getSession();


    if (session == null) return;

    final email = session['email'];

    final query = await FirebaseFirestore.instance
        .collection('customers')
        .where('Email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
    setState(() {
    userData = query.docs.first.data();
    });
    }


  }

  /// 🔥 LOGOUT
  Future<void> logout() async {
    await SessionManager.clearSession();


    context.go('/'); // back to login


  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    final name =
        userData!['Username'] ??
            userData!['PartyName'] ??
            userData!['Name'] ??
            "User";
    final email = userData!['Email'] ?? "";

    return Scaffold(
    backgroundColor: const Color(0xFFEEF2FF),

    appBar: AppBar(
    backgroundColor: const Color(0xFFEEF2FF),
    elevation: 0,
    title: const Text("Profile",
    style: TextStyle(color: Colors.black)),
    iconTheme: const IconThemeData(color: Colors.black),
    ),

      body: Column(
        children: [


      /// 🔹 TOP PROFILE CARD (FULL WIDTH)
      Container(
      width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [

            /// Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFF8D94B),
              child: Text(
                name.isNotEmpty
                    ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase()
                    : "U",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            /// Badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Customer"),
            ),
          ],
        ),
      ),

      /// 🔹 EMAIL + INFO CARD (FULL WIDTH)
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [

            Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text("Customer"),
              ],
            ),
          ],
        ),
      ),

      const Spacer(),

      /// 🔴 LOGOUT BUTTON (FULL WIDTH LIKE EMPLOYEE)
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: InkWell(
            onTap: logout,
            child: const Center(
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),


      ],
    ),

    );

  }
}
