import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/services/database_service.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/pages/auth/services/auth_service.dart';
import 'package:twitter/app/pages/auth/widgets/my_textfield.dart';
import 'package:twitter/app/widgets/my_button.dart';
import 'package:twitter/app/widgets/my_loading_circle.dart';

class Signup extends StatefulWidget {
  const Signup({super.key, this.togglePages});
  final Function()? togglePages;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _auth = AuthService();
  final _db = DatabaseService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  late final databaseController = Provider.of<DatabaseController>(context);

  void signup() async {
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
    context.mounted ? showLoadingCircle(context) : null;
    try {
      await _auth.signup(emailController.text, passwordController.text);

      context.mounted ? hideLoadingCircle(context) : null;

      await _db.saveUserInfoInFirebase(
          name: nameController.text, email: emailController.text);
    } catch (e) {
      hideLoadingCircle(context);
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
                'Criar uma conta',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(30),
              MyTextfield(
                controller: nameController,
                hintText: 'Nome',
                icon: Icons.person_outline,
                maxLength: 25,
              ),
              const Gap(20),
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
                maxLength: 25,
              ),
              const Gap(20),
              MyTextfield(
                controller: confirmPasswordController,
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
                onTap: signup,
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
