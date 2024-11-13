import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/twitter/pages/auth/controllers/signup_controller.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/pages/auth/widgets/my_textfield.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class Signup extends StatefulWidget {
  const Signup({
    super.key,
    this.togglePages,
    required this.signup,
  });
  final Function()? togglePages;
  final VoidCallback signup;
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final SignupController _signupController = SignupController.instance;

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
                'Criar uma conta',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(30),
              MyTextfield(
                controller: _signupController.nameController,
                hintText: 'Nome',
                icon: Icons.person_outline,
                maxLength: 25,
              ),
              const Gap(20),
              MyTextfield(
                controller: _signupController.emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
              const Gap(20),
              MyTextfield(
                controller: _signupController.passwordController,
                hintText: 'Senha',
                icon: Icons.lock_outline,
                isPassword: true,
                maxLength: 25,
              ),
              const Gap(20),
              MyTextfield(
                controller: _signupController.confirmPasswordController,
                hintText: 'Confirmar senha',
                icon: Icons.lock_outline,
                isPassword: true,
                maxLength: 25,
              ),
              const Gap(40),
              MyButton(
                buttonColor: AppColors.white,
                textColor: AppColors.background,
                text: 'Sign up',
                onTap: widget.signup,
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem uma conta?',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(5),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: const Text(
                      'Entre aqui',
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
