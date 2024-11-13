import 'package:flutter/material.dart';
import 'package:twitter/app/twitter/pages/auth/login/login.dart';
import 'package:twitter/app/twitter/pages/auth/signup/signup.dart';

class LoginOrSignup extends StatefulWidget {
  LoginOrSignup({
    super.key,
    this.showLoginPage = true,
    required this.signup,
    required this.login,
  });
  bool showLoginPage;
  final VoidCallback signup;
  final VoidCallback login;
  @override
  State<LoginOrSignup> createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {
  // inicialmente motrar a tela de login

  // função para alternar entre as telas de login e signup
  void togglePages() {
    setState(() {
      widget.showLoginPage = !widget.showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLoginPage) {
      return Login(togglePages: togglePages, login: widget.login);
    } else {
      return Signup(togglePages: togglePages, signup: widget.signup);
    }
  }
}
