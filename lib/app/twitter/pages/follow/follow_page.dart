import 'package:flutter/material.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/widgets/user_card.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({
    super.key,
    required this.followersUsers,
    required this.followingUsers,
  });
  final List<UserProfile> followersUsers;
  final List<UserProfile> followingUsers;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'S T A T S',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.white),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.lightGrey,
            indicatorColor: AppColors.white,
            indicatorWeight: 2,
            dividerColor: AppColors.background,
            tabs: [
              Tab(
                text: 'Seguindo',
              ),
              Tab(
                text: 'Seguidores',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildUserList(
              followingUsers,
              'Você não seguiu ninguém',
              context,
            ),
            buildUserList(
              followersUsers,
              'Nenhum seguidor ):',
              context,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildUserList(
    List<UserProfile> users, String emptyText, BuildContext context) {
  return users.isEmpty
      ? Center(
          child: Text(
            emptyText,
            style: const TextStyle(
              color: AppColors.lightGrey,
              fontSize: 18,
            ),
          ),
        )
      : ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserCard(
              user: users[index],
              onTap: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => Profile(
                      user: users[index],
                    ),
                    transitionDuration: Duration.zero, // Duração da animação
                    reverseTransitionDuration:
                        Duration.zero, // Duração da animação ao voltar
                  ),
                );
              },
            );
          },
        );
}
