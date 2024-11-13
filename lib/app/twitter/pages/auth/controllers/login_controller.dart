import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class LoginController {
  static final LoginController _instance = LoginController._();
  LoginController._();

  static LoginController get instance => _instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login(BuildContext context) async {
    final _auth = AuthService();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    if (!context.mounted) return;
    showLoadingCircle(context);

    try {
      await _auth.login(emailController.text, passwordController.text);
      if (!context.mounted) return;
      hideLoadingCircle(context);
      clearControllers();
    } catch (e) {
      if (!context.mounted) return;
      hideLoadingCircle(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
