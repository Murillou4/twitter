import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/pages/blocked%20users/blocked_users_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'C O N F I G U R A Ç Õ E S',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Gap(15),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            color: AppColors.drawerBackground,
            child: ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const BlockedUsersPage(),
                    transitionDuration: Duration.zero, // Duração da animação
                    reverseTransitionDuration:
                        Duration.zero, // Duração da animação ao voltar
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.white,
              ),
              title: const Text(
                'Usuários bloqueados',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
