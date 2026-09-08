import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';                                    // 👈 added
import 'package:lightatech/routes/app_route_config.dart';
import 'core/session/session_manager.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'customer/intro/viewmodel/order_detail_viewmodel.dart';             // 👈 added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('sessionBox');

  runApp(                                                                    // 👈 wrapped
    ChangeNotifierProvider(
      create: (_) => OrderDetailViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Customer App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          background: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Color(0x33000000),
          selectionHandleColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8D94B),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        checkboxTheme: const CheckboxThemeData(
          fillColor: WidgetStatePropertyAll(Colors.black),
        ),
      ),

      routerConfig: AppRoutes.router,
    );
  }
}