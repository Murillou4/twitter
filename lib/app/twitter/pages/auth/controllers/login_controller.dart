import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/providers/posts_provider.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class LoginController {
  static final LoginController _instance = LoginController._();
  LoginController._();

  static LoginController get instance => _instance;
  final _auth = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  Future<void> forgetPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite seu email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _auth.forgetPassword(emailController.text);
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Email de recuperação enviado com sucesso',
                  style: TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            )
          : null;
    } on FirebaseAuthException catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                behavior: SnackBarBehavior.floating,
              ),
            )
          : null;
    }
  }

  Future<void> login(BuildContext context) async {
    final _auth = AuthService();
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    if (!context.mounted) return;
    showLoadingCircle(context);

    try {
      await _auth.login(emailController.text, passwordController.text);
      await userProvider.initLoggedUserInfo();
      postsProvider.init();

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
