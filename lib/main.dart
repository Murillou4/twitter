import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/providers/audio_provider.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/twitter/pages/welcome/welcome.dart';

import 'package:twitter/app/core/shared_keys.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:twitter/app/twitter/services/shared_pf_service.dart';
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
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => DatabaseProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => AudioProvider(),
            ),
          ],
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro'),
      home: SharedPfService.prefs.getBool(SharedKeys.showWelcome) == null
          ? const Welcome()
          : const AuthGate(showLoginPage: true),
    );
  }
}
