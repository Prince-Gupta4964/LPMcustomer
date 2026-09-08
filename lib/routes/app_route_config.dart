import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Features/Intro/screens/intro_wrapper.dart';

import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/core/session/session_manager.dart';

// Intro
import 'package:lightatech/Features/Intro/screens/splash_screen.dart';
import 'package:lightatech/Features/Intro/screens/intro_screen.dart';
import 'package:lightatech/Features/Intro/screens/biometric_screen.dart';
import 'package:lightatech/Features/Intro/screens/fill_profile_screen.dart';
import 'package:lightatech/Features/Intro/screens/create_pin_screen.dart';
import 'package:lightatech/Features/Intro/auth/screens/lets_you_in_screen.dart';
import 'package:lightatech/customer/intro/screens/customer_profile_screen.dart';

// Login / Admin
import 'package:lightatech/Login/LoginScreen.dart';
import 'package:lightatech/Login/Admin/Admin.dart';

// Dashboard
import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/home.dart';
import 'package:lightatech/Features/Dashboard/screens/job_summary_screen.dart';

// Order
import '../Features/Intro/screens/register_screen.dart';
import '../customer/forms/customer_form6.dart';
import '../customer/forms/new_customer_form.dart';
import '../customer/forms/new_customer_form_scope.dart';
import '../customer/intro/viewmodel/order_detail_view.dart';

// Job Forms
import 'package:lightatech/Production/JobCreation/screens/forms/new_form.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_1.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_2.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_3.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_4.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_5.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_6.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/auto_bending/auto_bending_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/manual_bending/manual_bending_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/laser_cut/laser_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/emboss/emboss_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/rubber/rubber_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/delivery/delivery_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/account/account_page1.dart';

// Map
import 'package:lightatech/Features/MapScreen/screens/map_screen.dart';
import 'package:lightatech/Features/MapScreen/screens/task_detail_page.dart';
import 'package:lightatech/Features/MapScreen/models/task.dart';

// Graph
import 'package:lightatech/Features/Graph/screens/graph_page.dart';
import 'package:lightatech/Features/Graph/widgets/graph_form.dart';
import 'package:lightatech/Features/Graph/screens/graph_tasks_page.dart';

// Target
import 'package:lightatech/Features/Target/screens/profile_screen.dart';

// Notifications
import 'package:lightatech/Features/Notifications/screens/notifications_screen.dart';
import 'package:lightatech/Features/Notifications/screens/job_summary_page.dart';

// Payment
import 'package:lightatech/Features/Payment/screens/paid_screen.dart';

// Customer forms
import 'package:lightatech/customer/forms/customer_form.dart';
import 'package:lightatech/customer/forms/customer_form2.dart';
import 'package:lightatech/customer/forms/customer_form3.dart';
import 'package:lightatech/customer/forms/customer_form4.dart';
import 'package:lightatech/customer/forms/customer_form5.dart';

// Detail view
import 'package:provider/provider.dart';
import '../customer/intro/viewmodel/order_detail_viewmodel.dart';

// ─── Navigator Keys ────────────────────────────────────────────────────────────
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>();

/// Single shared customer form instance
final NewCustomerForm _customerForm = NewCustomerForm();
final NewCustomerForm sharedCustomerForm = NewCustomerForm();

class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/intro/splash',

    redirect: (context, state) {
      final isLoggedIn = SessionManager.hasSession();
      final location = state.uri.toString();

      const publicPrefixes = [
        '/login',
        '/intro',
        '/auth',
        '/register',
        '/admin',
      ];
      final isPublic = publicPrefixes.any((p) => location.startsWith(p));

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && location == '/intro/splash') return '/dashboard';

      return null;
    },

    routes: [
      // ── Login (outside every shell) ────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // ── Outer shell: NewForm context for job form pages ────────────
      ShellRoute(
        builder: (context, state, child) {
          final extra = state.extra as Map<String, dynamic>?;
          return NewForm(
            department: extra?['department'] ?? 'Designer',
            lpm: extra?['lpm'],
            child: child,
          );
        },
        routes: [
          // ── Intro / auth ───────────────────────────────────────────
          GoRoute(
            path: '/intro/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/intro',
            builder: (context, state) => const IntroWrapper(),
          ),
          GoRoute(
            path: '/intro/biometric',
            builder: (context, state) => const BiometricScreen(),
          ),
          GoRoute(
            path: '/intro/fill-profile',
            builder: (context, state) => const FillProfileScreen(),
          ),
          GoRoute(
            path: '/intro/create-pin',
            builder: (context, state) => const CreatePinScreen(),
          ),
          GoRoute(
            path: '/auth/entry',
            builder: (context, state) => const LetsYouInScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/admin',
            name: AppRoutesName.Adminroutename,
            builder: (context, state) => const Admin(),
          ),
          GoRoute(
            path: '/order-details',
            name: 'orderDetails',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => OrderDetailViewModel(),
              child: OrderDetailScreen(),
            ),
          ),

          // ── Job form pages ─────────────────────────────────────────
          GoRoute(path: '/jobform', redirect: (_, __) => '/jobform/designer-1'),
          GoRoute(path: '/jobform/designer-1', builder: (_, __) => const DesignerPage1()),
          GoRoute(path: '/jobform/designer-2', builder: (_, __) => const DesignerPage2()),
          GoRoute(path: '/jobform/designer-3', builder: (_, __) => const DesignerPage3()),
          GoRoute(path: '/jobform/designer-4', builder: (_, __) => const DesignerPage4()),
          GoRoute(path: '/jobform/designer-5', builder: (_, __) => const DesignerPage5()),
          GoRoute(path: '/jobform/designer-6', builder: (_, __) => const DesignerPage6()),
          GoRoute(path: '/jobform/auto-bending', builder: (_, __) => const AutoBendingPage()),
          GoRoute(path: '/jobform/manual-bending', builder: (_, __) => const ManualBendingPage()),
          GoRoute(path: '/jobform/laser', builder: (_, __) => const LaserPage()),
          GoRoute(path: '/jobform/rubber', builder: (_, __) => const RubberPage()),
          GoRoute(path: '/jobform/emboss', builder: (_, __) => const EmbossPage()),
          GoRoute(path: '/jobform/account1', builder: (_, __) => const AccountPage()),
          GoRoute(path: '/jobform/delivery', builder: (_, __) => const DeliveryPage()),

          // ── Misc routes ────────────────────────────────────────────
          GoRoute(
            path: '/task',
            name: AppRoutesName.TaskDetail,
            builder: (context, state) {
              final task = state.extra as Task;
              return TaskDetailPage(task: task, onChanged: () {}, onDelete: () {});
            },
          ),
          GoRoute(
            path: '/graphform',
            builder: (context, state) => const GraphFormPage(),
          ),
          GoRoute(
            path: '/graphtasks',
            builder: (context, state) => const GraphTasksPage(),
          ),

          // ── Customer form flow ─────────────────────────────────────
          // Uses query param instead of extra so it survives page refresh.
          ShellRoute(
            builder: (context, state, child) {
              return NewCustomerFormScope(form: sharedCustomerForm, child: child);
            },
            routes: [
              GoRoute(
                // customerName passed as query param: /customer-form?name=Foo
                path: '/customer-form',
                builder: (context, state) {
                  // ✅ Read from queryParams — survives hot-restart & refresh.
                  // Falls back to extra map for callers that still use extra.
                  final fromQuery = state.uri.queryParameters['name'];
                  final fromExtra = (state.extra as Map<String, dynamic>?)?['customerName'] as String?;
                  final customerName = fromQuery ?? fromExtra ?? '';
                  return CustomerForm(customerName: customerName);
                },
              ),
              GoRoute(
                path: '/customer-form-2',
                builder: (context, state) => const CustomerForm2(),
              ),
              GoRoute(
                path: '/customer-form-3',
                builder: (context, state) => const CustomerForm3(),
              ),
              GoRoute(
                path: '/customer-form-4',
                builder: (context, state) => const CustomerForm4(),
              ),
              GoRoute(
                path: '/customer-form-5',
                builder: (context, state) => const CustomerForm5(),
              ),
              GoRoute(
                path: '/customer-form-6',
                builder: (context, state) => const CustomerForm6(),
              ),
            ],
          ),

          // ── Dashboard shell (Home + bottom nav) ────────────────────
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) {
              return Home(child: child, location: state.uri.toString());
            },
            routes: [
              GoRoute(
                path: '/dashboard',
                name: AppRoutesName.DashboardScreen,
                builder: (context, state) {
                  final session = SessionManager.getSession();
                  return DashboardScreen(
                    email: session?['email'] ?? '',
                    partyName: session?['partyName'] ?? '',
                  );
                },
              ),
              GoRoute(
                path: '/customer-profile',
                builder: (context, state) => const CustomerProfileScreen(),
              ),
              GoRoute(
                path: '/job-summary',
                builder: (context, state) {
                  final lpm = (state.extra as Map)['lpm'] as String;
                  return JobSummaryScreen(lpm: lpm);
                },
              ),
              GoRoute(
                path: '/map',
                name: AppRoutesName.MapScreen,
                builder: (context, state) => const MapScreen(title: 'Maps'),
              ),
              GoRoute(
                path: '/payment',
                name: AppRoutesName.PaymentScreen,
                builder: (context, state) => const PaidScreen(),
              ),
              GoRoute(
                path: '/graph',
                builder: (context, state) => const GraphPage(),
              ),
              GoRoute(
                path: '/target',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/notifications',
                builder: (context, state) {
                  final session = SessionManager.getSession();
                  final extra = state.extra as Map<String, dynamic>?;
                  return NotificationsScreen(
                    partyName:
                    extra?['partyName'] ?? session?['partyName'] ?? '',
                    email: extra?['email'] ?? session?['email'] ?? '',
                  );
                },
              ),
              GoRoute(
                path: '/notification-job-summary',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final lpm = extra?['lpm'] ?? '';
                  final status = extra?['status'] ?? 'pending';
                  return NotificationJobSummaryPage(lpm: lpm,status:status);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}