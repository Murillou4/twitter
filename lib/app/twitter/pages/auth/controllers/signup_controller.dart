import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class SignupController {
  static final SignupController _instance = SignupController._();
  SignupController._();

  static SignupController get instance => _instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> signup(BuildContext context) async {
    final _auth = AuthService();
    final _db = DatabaseService();
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas precisam ser iguais'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!context.mounted) return;
    showLoadingCircle(context);
    try {
      await _auth.signup(emailController.text, passwordController.text);
      await _db.saveUserInfoInFirebase(
          name: nameController.text, email: emailController.text);
      await _auth.logout();
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
