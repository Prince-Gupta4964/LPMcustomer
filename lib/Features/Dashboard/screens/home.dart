// ignore_for_file: unused_element, unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';
class Home extends StatelessWidget {
  final Widget child;
  final String location;
  final List<dynamic>? departments;
  const Home({
    super.key,
    required this.child,
    required this.location,
    this.departments,
  });
  @override
  Widget build(BuildContext context) {
    // Bottom navigation bar hidden from UI
    return Scaffold(
      body: child,
    );
  }
  // ------------------ ROUTE → INDEX ------------------
  int _calculateIndex(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/payment')) return 2;
    if (location.startsWith('/graph')) return 3;
    if (location.startsWith('/target')) return 4;
    // These are overlay-style routes — keep bottom nav on dashboard (0)
    // so the nav bar doesn't jump when visiting profile or notifications
    if (location.startsWith('/notifications')) return 0;
    if (location.startsWith('/customer-profile')) return 0;
    if (location.startsWith('/job-summary')) return 0;
    return 0; // dashboard default
  }
  // ------------------ INDEX → ROUTE ------------------
  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/payment');
        break;
      case 3:
        context.go('/graph');
        break;
      case 4:
        context.go('/target');
        break;
    }
  }
}