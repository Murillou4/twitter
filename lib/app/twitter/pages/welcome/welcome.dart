import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_gate.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/core/shared_keys.dart';
import 'package:twitter/app/twitter/pages/auth/login/login.dart';
import 'package:twitter/app/twitter/pages/auth/signup/signup.dart';
import 'package:twitter/app/twitter/services/shared_pf_service.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dontShowWelcome();
  }

  void dontShowWelcome() async {
    await SharedPfService.prefs.setBool(SharedKeys.showWelcome, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background,
              Colors.white.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/images/blue_bird.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const Gap(30),
              const Text(
                'Bem vindo ao\nTwitter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(10),
              const Text(
                'Veja oque esta acontecendo no mundo agora mesmo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyButton(
                    buttonColor: Colors.white,
                    textColor: AppColors.background,
                    text: 'Log in',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const AuthGate(
                            showLoginPage: true,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const Gap(10),
                  MyButton(
                    buttonColor: Colors.transparent,
                    textColor: Colors.white,
                    text: 'Sign up',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              const AuthGate(
                            showLoginPage: false,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
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
