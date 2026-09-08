import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
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
      // 🔎 Check if username already exists
      final usernameCheck = await FirebaseFirestore.instance
          .collection("Onboarding")
          .where("Username", isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username already exists, try a different one")),
        );
        return;
      }

      // 🔎 Check if email already exists
      final emailCheck = await FirebaseFirestore.instance
          .collection("Onboarding")
          .where("Email", isEqualTo: email)
          .get();

      if (emailCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already registered")),
        );
        return;
      }

      // 🧾 Save user to Firestore (Username + Email + Password)
      await FirebaseFirestore.instance.collection("Onboarding").add({
        "Username": username,
        "Email": email,
        "Password": password,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful.")),
      );

      context.go('/intro/fill-profile'); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget safeIcon(IconData icon) {
    return Icon(icon, size: 18, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              /// 🔵 Icon Header
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFF8D94B),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 48,
                    color: Color(0xff46000A),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Let’s Get Started!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202244),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Create your account to continue",
                style: TextStyle(fontSize: 14, color: Color(0xFF545454)),
              ),

              const SizedBox(height: 40),

              // Username
              inputBox(
                icon: safeIcon(Icons.person),
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: InputBorder.none,
                    hintText: "Full Name",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📧 Email
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

              /// 🔒 Password
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

              const SizedBox(height: 40),

              /// ✅ Register Button
              primaryButton("Create Account", registerUser),

              const SizedBox(height: 30),

              /// 🔁 Back to Login
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text(
                    "Already have an account? Sign In",
                    style: TextStyle(
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
          BoxShadow(color: Colors.black12, blurRadius: 8),
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
          strokeWidth: 3,
          color: Color(0xff46000A),
        ),
      )
          : const Text(
        "Create Account",
        style: TextStyle(
          fontSize: 20,
          color: Color(0xff46000A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
