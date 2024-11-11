import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/app/twitter/pages/auth/services/login_or_signup.dart';
import 'package:twitter/app/twitter/pages/home/pages/home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.showLoginPage,
  });
  final bool showLoginPage;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Home();
          } else {
            return LoginOrSignup(
              showLoginPage: widget.showLoginPage,
            );
          }
        },
      ),
    );
  }
}
