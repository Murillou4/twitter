import 'package:flutter/material.dart';
import 'package:twitter/app/pages/auth/login/login.dart';
import 'package:twitter/app/pages/auth/signup/signup.dart';

class LoginOrSignup extends StatefulWidget {
  LoginOrSignup({
    super.key,
    this.showLoginPage = true,
  });
  bool showLoginPage;
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
      return Login(togglePages: togglePages);
    } else {
      return Signup(togglePages: togglePages);
    }
  }
}
