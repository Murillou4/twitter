import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/auth/controllers/login_controller.dart';
import 'package:twitter/app/twitter/pages/auth/controllers/signup_controller.dart';
import 'package:twitter/app/twitter/pages/auth/services/login_or_signup.dart';
import 'package:twitter/app/twitter/pages/home/pages/home.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
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
  late final databaseProvider = Provider.of<DatabaseProvider>(context);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<UserProfile>(
              future: databaseProvider.initLoggedUserInfo(),
              builder: (context, initSnapshot) {
                // Verifica se houve erro
                if (initSnapshot.hasError) {
                  return Scaffold(
                    backgroundColor: AppColors.background,
                    appBar: AppBar(
                      backgroundColor: AppColors.background,
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.logout,
                            color: AppColors.white,
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Erro ao carregar dados',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                            ),
                          ),
                          MyButton(
                            onTap: () {
                              setState(() {});
                            },
                            buttonColor: AppColors.white,
                            textColor: AppColors.background,
                            text: 'Tentar novamente',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Estado de carregamento
                if (initSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: AppColors.background,
                      actions: [
                        IconButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: Icon(
                            Icons.logout,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.background,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                          const Gap(20),
                          Text(
                            'Carregando informações do usuário...',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Verifica se os dados foram inicializados com sucesso
                if (initSnapshot.hasData) {
                  return const Home();
                }

                // Fallback para qualquer outro estado
                return Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(
                    child: Text(
                      'Estado inesperado',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                );
              });
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
