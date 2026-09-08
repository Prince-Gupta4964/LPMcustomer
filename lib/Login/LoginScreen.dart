import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:lightatech/routes/app_route_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool showPassword = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      /// ✅ CHECK USER (ONBOARDING)
      final onboardingSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .where('Email', isEqualTo: email)
          .where('Password', isEqualTo: password)
          .get();

      if (onboardingSnapshot.docs.isNotEmpty) {
        final doc = onboardingSnapshot.docs.first;
        final userData = doc.data();
        final uid = doc.id;

        final partyName =
        (userData["PartyName"] ?? userData["Name"] ?? "Customer").toString();

        await saveLoginLog(email: email, department: 'User');

        await SessionManager.saveSession(
          email: email,
          department: 'User',
          uid: uid,
          partyName: partyName,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);

        sharedCustomerForm.reset();

        context.go(
          '/dashboard',
          extra: {
            'department': 'User',
            'email': email,
            'uid': uid,
            'partyName': partyName,
          },
        );
        return;
      }

      /// 👷 CHECK EMPLOYEE
      final employeeSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .where('Email', isEqualTo: email)
          .where('Password', isEqualTo: password)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        final doc = employeeSnapshot.docs.first;
        final uid = doc.id;

        await saveLoginLog(email: email, department: 'Employee');

        await SessionManager.saveSession(
          email: email,
          department: 'Employee',
          uid: uid,
          partyName: 'Employee',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);

        context.go(
          '/dashboard',
          extra: {
            'department': 'Employee',
            'email': email,
            'uid': uid,
          },
        );
        return;
      }

      /// ❌ NO USER FOUND
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveLoginLog({
    required String email,
    required String department,
  }) async {
    await FirebaseFirestore.instance.collection('LoginLogs').add({
      'Email': email,
      'Department': department,
      'LoginTime': FieldValue.serverTimestamp(),
    });
  }

  Widget safeIcon(IconData icon) =>
      Icon(icon, size: 18, color: Colors.grey);

  Future<void> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final email = userCredential.user!.email!;

      /// CHECK CUSTOMER
      final onboardingSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .where('Email', isEqualTo: email)
          .get();

      DocumentSnapshot doc;

      if (onboardingSnapshot.docs.isNotEmpty) {
        doc = onboardingSnapshot.docs.first;
      } else {
        final newDoc = await FirebaseFirestore.instance
            .collection('clients')
            .add({
          "Email": email,
          "Password": "google_user",
          "Username": userCredential.user!.displayName ?? "Customer",
          "Party Names": userCredential.user!.displayName ?? "Customer",
          "LoginType": "Google",
          "department": "Customer",
          "CreatedAt": FieldValue.serverTimestamp(),
        });

        doc = await newDoc.get();
      }

      final userData = doc.data() as Map<String, dynamic>;
      final uid = doc.id;

      final partyName =
      (userData["PartyName"] ?? userData["Name"] ?? "Customer").toString();

      await saveLoginLog(email: email, department: 'User');

      await SessionManager.saveSession(
        email: email,
        department: 'User',
        uid: uid,
        partyName: partyName,
      );

      context.go(
        '/dashboard',
        extra: {
          'department': 'User',
          'email': email,
          'uid': uid,
          'partyName': partyName,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google login error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  padding: const EdgeInsets.all(8), // smaller padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/LPM.jpg',
                      fit: BoxFit.cover, // important: fills space
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Let’s Sign In!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202244),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Login to your account to continue",
                style: TextStyle(fontSize: 14, color: Color(0xFF545454)),
              ),
              const SizedBox(height: 40),
              inputBox(
                icon: safeIcon(Icons.email),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              inputBox(
                icon: safeIcon(Icons.lock),
                child: TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () =>
                      setState(() => showPassword = !showPassword),
                  child: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CheckboxListTile(
                value: rememberMe,
                onChanged: (v) => setState(() => rememberMe = v!),
                title: const Text("Remember Me"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 35),
              primaryButton("Sign In", login),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: signInWithGoogle,
                icon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                  height: 20,
                ),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text(
                    "New user? Register",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202244),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputBox({
    required Widget icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
        color: Colors.white,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget primaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF8D94B),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 26,
        width: 26,
        child: CircularProgressIndicator(
          color: Color(0xff46000A),
          strokeWidth: 3,
        ),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xff46000A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
