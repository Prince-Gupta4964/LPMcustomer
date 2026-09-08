import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'intro_screen.dart';

class IntroWrapper extends StatefulWidget {
  const IntroWrapper({super.key});

  @override
  State<IntroWrapper> createState() => _IntroWrapperState();
}

class _IntroWrapperState extends State<IntroWrapper> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkIntro();
  }

  Future<void> checkIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('intro_completed') ?? false;

    if (!mounted) return;

    if (done) {
      /// ✅ If intro already done → go directly to Login
      context.go('/');
    } else {
      /// ✅ Show intro pages
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> finishIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_completed', true);

    if (!mounted) return;

    /// ✅ After intro → go to biometric
    context.go('/intro/biometric');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return IntroScreen(onFinished: finishIntro);
  }
}
