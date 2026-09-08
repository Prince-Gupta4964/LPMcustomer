import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';

import '../widgets/sidebar_logo.dart';
import 'history_screen.dart';

// Screens
import '../../adminAccess/screens/user_rights_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  Widget buildMenuItem(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const SidebarLogo(),

            // ---------------------------------------------------------
            // DASHBOARD
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'All Staffs Dashboard',
              Icons.dashboard,
                  () {},
            ),

            // ---------------------------------------------------------
            // PROJECTS
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Projects',
              Icons.work_outline,
                  () {},
            ),

            // ---------------------------------------------------------
            // REACH DASHBOARD
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Reach Dashboard',
              Icons.people_outline,
                  () {},
            ),

            // ---------------------------------------------------------
            // TURNOVER
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Turnover',
              Icons.bar_chart,
                  () {},
            ),

            // ---------------------------------------------------------
            // PACKAGES
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Packages',
              Icons.card_giftcard,
                  () {},
            ),

            // ---------------------------------------------------------
            // PRODUCTIVITY
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Productivity',
              Icons.show_chart,
                  () {},
            ),

            // ---------------------------------------------------------
            // HISTORY
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'History',
              Icons.history,
                  () {
                Navigator.pop(context);

                // Get currently logged-in customer's session
                final session = SessionManager.getSession();

                final partyName = session?['partyName'] ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(
                      partyName: partyName,
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            // ---------------------------------------------------------
            // ABOUT
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'About',
              Icons.info_outline,
                  () {},
            ),

            // ---------------------------------------------------------
            // FEEDBACK
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Feedback',
              Icons.feedback_outlined,
                  () {},
            ),

            // ---------------------------------------------------------
            // SHARE
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Share',
              Icons.share_outlined,
                  () {
                Navigator.pop(context);
                context.go('/intro/splash');
              },
            ),

            const Divider(),

            // ---------------------------------------------------------
            // APP GALLERY
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'App Gallery',
              Icons.apps,
                  () {
                Navigator.pop(context);
              },
            ),

            // ---------------------------------------------------------
            // ADD SHORTCUT
            // ---------------------------------------------------------
            buildMenuItem(
              context,
              'Add Shortcut',
              Icons.add_box_outlined,
                  () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserRightsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}