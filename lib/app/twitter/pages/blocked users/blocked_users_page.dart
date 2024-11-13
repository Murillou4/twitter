import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/blocked%20users/widgets/blocked_user_card.dart';
import 'package:twitter/app/twitter/services/database_service.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = DatabaseService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'B L O C K E D   U S E R S',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: _db.getBlockedUsersStream(),
        builder: (context, blockedUsersSnapshot) {
          final blockedUsers = blockedUsersSnapshot.data ?? [];
          if (blockedUsers.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum usuário bloqueado',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 18,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: ListView.separated(
              itemBuilder: (context, index) {
                return BlockedUserCard(
                  user: blockedUsers[index],
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.drawerBackground,
                height: 1,
                thickness: 1,
              ),
              itemCount: blockedUsers.length,
            ),
          );
        },
      ),
    );
  }
}
