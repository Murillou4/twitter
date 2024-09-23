import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/pages/welcome/welcome.dart';
import 'package:twitter/app/services/shared_pf_service.dart';
import 'package:twitter/app/core/shared_keys.dart';
import 'package:twitter/app/pages/auth/services/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init SharedPfService
  await SharedPfService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DatabaseController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'SF Pro'),
      home: SharedPfService.prefs.getBool(SharedKeys.showWelcome) == null
          ? const Welcome()
          : const AuthGate(showLoginPage: true),
    );
  }
}
