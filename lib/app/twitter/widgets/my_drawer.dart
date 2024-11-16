import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/models/chat.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/chat/pages/chats_page.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';

import 'package:gap/gap.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';

import 'package:twitter/app/twitter/pages/follow/follow_page.dart';

import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/pages/search/search_page.dart';
import 'package:twitter/app/twitter/pages/settings/settings_page.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final _auth = AuthService();
  TextEditingController usernameController = TextEditingController();
  late final userProvider = Provider.of<UserProvider>(context, listen: false);

  final _db = DatabaseService();

  void updateUserName() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.drawerBackground,
          title: TextField(
            controller: usernameController,
            maxLength: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Digite o novo username',
              hintStyle: TextStyle(
                color: AppColors.lightGrey,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.background,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.background,
                ),
              ),
            ),
            style: const TextStyle(
              color: AppColors.white,
            ),
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            MyButton(
              onTap: () {
                usernameController.clear();
                Navigator.of(context).pop();
              },
              buttonColor: AppColors.background,
              textColor: AppColors.white,
              text: 'Cancelar',
              width: 100,
            ),
            MyButton(
              onTap: () async {
                if (usernameController.text.isEmpty) {
                  Navigator.of(context).pop();
                  return;
                }

                await userProvider.updateUserName(usernameController.text);
                usernameController.clear();
                context.mounted ? Navigator.of(context).pop() : null;
              },
              buttonColor: AppColors.background,
              textColor: AppColors.white,
              text: 'Salvar',
              width: 100,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _auth.getCurrentUserUid();
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Drawer(
          backgroundColor: AppColors.drawerBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(
                      50,
                    ),
                  ),
                  child: userProvider.loggedUserInfo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            width: 45,
                            height: 45,
                            userProvider.loggedUserInfo!.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: AppColors.white,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.white,
                        ),
                ),
                const Gap(30),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    userProvider.loggedUserInfo != null
                        ? userProvider.loggedUserInfo!.name
                        : 'User',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    userProvider.loggedUserInfo != null
                        ? '@${userProvider.loggedUserInfo!.username}'
                        : 'User',
                    style: const TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: updateUserName,
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ),
                const MyDivider(),
                StreamBuilder<List<UserProfile>>(
                    stream: _db.getUserFollowingStream(currentUserUid),
                    builder: (context, followingSnapshot) {
                      return StreamBuilder<List<UserProfile>>(
                          stream: _db.getUserFollowersStream(currentUserUid),
                          builder: (context, followersSnapshot) {
                            final followingUsers = followingSnapshot.data ?? [];
                            final followersUsers = followersSnapshot.data ?? [];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            FollowPage(
                                      followersUsers: followersUsers,
                                      followingUsers: followingUsers,
                                    ),
                                    transitionDuration:
                                        Duration.zero, // Duração da animação
                                    reverseTransitionDuration: Duration
                                        .zero, // Duração da animação ao voltar
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    userProvider.loggedUserInfo != null
                                        ? '${followingUsers.length} Seguindo'
                                        : '0 Seguindo',
                                    style: const TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Gap(20),
                                  Text(
                                    userProvider.loggedUserInfo != null
                                        ? '${followersUsers.length} Seguidores'
                                        : '0 Seguidores',
                                    style: const TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    }),
                const MyDivider(),
                DrawerItem(
                  text: 'Home',
                  icon: Icons.home_rounded,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const MyDivider(),
                DrawerItem(
                  text: 'Perfil',
                  icon: Icons.person,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            Profile(
                          user: userProvider.loggedUserInfo!,
                        ),
                        transitionDuration:
                            Duration.zero, // Duração da animação
                        reverseTransitionDuration:
                            Duration.zero, // Duração da animação ao voltar
                      ),
                    );
                  },
                ),
                const MyDivider(),
                StreamBuilder<List<Chat>>(
                    stream: _db.getUserChats(),
                    builder: (context, snapshot) {
                      final chats = snapshot.data ?? [];
                      final int unreadChats = chats
                          .where((chat) =>
                              chat.lastMessage != null &&
                              !chat.lastMessage!.isRead &&
                              chat.lastMessage!.senderId !=
                                  userProvider.loggedUserInfo!.uid)
                          .length;

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DrawerItem(
                            text: 'Chats',
                            icon: Icons.chat_rounded,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          ChatsPage(),
                                  transitionDuration:
                                      Duration.zero, // Duração da animação
                                  reverseTransitionDuration: Duration
                                      .zero, // Duração da animação ao voltar
                                ),
                              );
                            },
                          ),
                          unreadChats > 0
                              ? const Gap(20)
                              : const SizedBox.shrink(),
                          unreadChats > 0
                              ? Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.twitterBlue,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    '$unreadChats',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      );
                    }),
                const MyDivider(),
                DrawerItem(
                  text: 'Configurações',
                  icon: Icons.settings,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const SettingsPage(),
                        transitionDuration:
                            Duration.zero, // Duração da animação
                        reverseTransitionDuration:
                            Duration.zero, // Duração da animação ao voltar
                      ),
                    );
                  },
                ),
                const MyDivider(),
                DrawerItem(
                  text: 'Procurar',
                  icon: Icons.search,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const SearchPage(),
                        transitionDuration:
                            Duration.zero, // Duração da animação
                        reverseTransitionDuration:
                            Duration.zero, // Duração da animação ao voltar
                      ),
                    );
                  },
                ),
                const MyDivider(),
                DrawerItem(
                  text: 'Sair',
                  icon: Icons.logout,
                  onTap: () async {
                    await _auth.logout(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.lightGrey,
      thickness: 0.5,
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });
  final String text;
  final IconData icon;

  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 30,
            ),
            const Gap(10),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
