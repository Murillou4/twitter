import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';

import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user.dart';
import 'package:twitter/app/twitter/pages/blocked%20users/widgets/blocked_user_card.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  @override
  Widget build(BuildContext context) {
    List<UserProfile> users = listeningProvider.blockedUsers;
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
      body: users.isEmpty
          ? const Center(
              child: Text(
                'Nenhum usuário bloqueado',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 18,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return BlockedUserCard(
                    user: users[index],
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.drawerBackground,
                  height: 1,
                  thickness: 1,
                ),
                itemCount: users.length,
              ),
            ),
    );
  }
}
