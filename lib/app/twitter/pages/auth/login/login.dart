import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/pages/auth/widgets/my_textfield.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.togglePages});
  final Function()? togglePages;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }
    showLoadingCircle(context);
    try {
      await _auth.login(
        emailController.text,
        passwordController.text,
      );
      
      context.mounted ? hideLoadingCircle(context) : null;
    } catch (e) {
      context.mounted ? hideLoadingCircle(context) : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(50),
              SvgPicture.asset(
                'assets/images/blue_bird.svg',
                height: 80,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
              Gap(
                MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                'Entrar no Twitter',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(30),
              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
              const Gap(20),
              MyTextfield(
                controller: passwordController,
                hintText: 'Senha',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const Gap(20),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: AppColors.twitterBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(20),
              MyButton(
                buttonColor: AppColors.white,
                textColor: AppColors.background,
                text: 'Entrar',
                onTap: login,
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem uma conta?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(5),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: AppColors.twitterBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
