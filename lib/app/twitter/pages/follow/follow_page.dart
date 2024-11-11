import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/widgets/user_card.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({
    super.key,
    required this.followersUserUids,
    required this.followingUserUids,
  });
  final List<String> followersUserUids;
  final List<String> followingUserUids;

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
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
              widget.followingUserUids,
              'Você não seguiu ninguém',
              context,
            ),
            buildUserList(
              widget.followersUserUids,
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
    List<String> usersUids, String emptyText, BuildContext context) {
  final databaseProvider = Provider.of<DatabaseProvider>(context, listen: true);
  return usersUids.isEmpty
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
          itemCount: usersUids.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: databaseProvider.userProfile(
                usersUids[index],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return UserCard(
                    user: snapshot.data!,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Profile(
                            user: snapshot.data!,
                          ),
                          transitionDuration:
                              Duration.zero, // Duração da animação
                          reverseTransitionDuration:
                              Duration.zero, // Duração da animação ao voltar
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        );
}
