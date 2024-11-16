import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/auth/controllers/login_controller.dart';
import 'package:twitter/app/twitter/pages/auth/controllers/signup_controller.dart';
import 'package:twitter/app/twitter/pages/auth/services/login_or_signup.dart';
import 'package:twitter/app/twitter/pages/home/pages/home.dart';
import 'package:twitter/app/twitter/providers/posts_provider.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

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
  final LoginController _loginController = LoginController.instance;
  final SignupController _signupController = SignupController.instance;
  late final userProvider = Provider.of<UserProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Home();
        } else {
          return LoginOrSignup(
            showLoginPage: widget.showLoginPage,
            login: () async {
              await _loginController.login(context);
            },
            signup: () async {
              await _signupController.signup(context);
            },
          );
        }
      },
    );
  }
}
