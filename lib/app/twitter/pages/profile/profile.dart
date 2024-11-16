import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/models/chat.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/pages/chat/pages/chat_page.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/pages/follow/follow_page.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/src/date_service.dart';
import 'package:twitter/app/twitter/src/download_gif.dart';
import 'package:twitter/app/twitter/widgets/confirmation_box.dart';
import 'package:twitter/app/twitter/widgets/gallery_or_camera_card.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';
import 'package:twitter/app/twitter/widgets/post_card.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.user,
  });
  final UserProfile user;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late UserProfile user = widget.user;
  final _auth = AuthService();
  late final userProvider = Provider.of<UserProvider>(context, listen: false);
  late final listeningProvider = Provider.of<UserProvider>(context);
  final _db = DatabaseService();
  final TextEditingController bioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Future<Chat> getChat() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final db = DatabaseService();
    final otherUserId = widget.user.uid;
    final chatId = [currentUserId, otherUserId]..sort();
    final String consistentChatId = '${chatId[0]}_${chatId[1]}';
    final chat = await db.getChat(consistentChatId);
    return chat;
  }

  Future<void> updateProfileImage(ImageSource source,
      [bool isGif = false]) async {
    showLoadingCircle(context);
    if (isGif) {
      final gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: 'LgLuuMlL3aaDQHRHL5gXsVtgHY9woHTU',
        appBarBuilder: (context, {actions, title}) {
          return AppBar(title: title, actions: actions);
        },
      );
      if (gif == null) {
        mounted ? hideLoadingCircle(context) : null;
        return;
      }
      // Baixa o GIF da URL e salva localmente
      final gifUrl = gif.images.original!.url;
      final gifFile = await downloadGif(gifUrl!);
      await _db.updateUserProfileImageInFirebase(gifFile);

      await listeningProvider.initLoggedUserInfo();
      mounted ? hideLoadingCircle(context) : null;
      return;
    }
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: source);
    if (image == null) {
      mounted ? hideLoadingCircle(context) : null;
      return;
    }
    File file = File(image.path);
    await _db.updateUserProfileImageInFirebase(file);
    await listeningProvider.reloadLoggedUserInfo();
    mounted ? hideLoadingCircle(context) : null;
    return;
  }

  Future<void> updateUserBio() async {
    bioController.text = widget.user.bio;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.drawerBackground,
          title: TextField(
            controller: bioController,
            maxLength: 100,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sua bio aqui',
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
                Navigator.of(context).pop();
              },
              buttonColor: AppColors.background,
              textColor: AppColors.white,
              text: 'Cancelar',
              width: 100,
            ),
            MyButton(
              onTap: () async {
                if (bioController.text.isEmpty) {
                  Navigator.of(context).pop();
                  return;
                }

                await userProvider.updateUserBio(bioController.text);
                setState(() {
                  user = UserProfile(
                    uid: widget.user.uid,
                    name: widget.user.name,
                    username: widget.user.username,
                    email: widget.user.email,
                    bio: bioController.text, // Define a nova bio aqui
                    photoUrl: widget.user.photoUrl,
                    timestamp: widget.user.timestamp,
                  );
                });
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
    String photoUrl = listeningProvider.loggedUserInfo?.photoUrl ?? '';
    return Consumer<UserProvider>(builder: (context, value, child) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'P E R F I L',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        body: StreamBuilder<List<UserProfile>>(
            stream: _db.getBlockedUsersStream(),
            builder: (context, blockedUsersSnapshot) {
              List<UserProfile> blockedUsers = blockedUsersSnapshot.data ?? [];
              bool isBlockedByCurrentUser =
                  blockedUsers.any((u) => u.uid == widget.user.uid);
              return StreamBuilder<List<UserProfile>>(
                  stream: _db.getUserFollowingStream(widget.user.uid),
                  builder: (context, followingSnapshot) {
                    return StreamBuilder<List<UserProfile>>(
                        stream: _db.getUserFollowersStream(widget.user.uid),
                        builder: (context, followersSnapshot) {
                          int followingCount =
                              followingSnapshot.data?.length ?? 0;
                          int followersCount =
                              followersSnapshot.data?.length ?? 0;
                          bool isCurrentUserFollowing = followersSnapshot.data
                                  ?.any((user) =>
                                      user.uid == _auth.getCurrentUserUid()) ??
                              false;
                          List<UserProfile> followingUsers =
                              followingSnapshot.data ?? [];
                          List<UserProfile> followersUsers =
                              followersSnapshot.data ?? [];

                          if (isBlockedByCurrentUser) {
                            return Scaffold(
                              backgroundColor: AppColors.background,
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Usuário bloqueado',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(20),
                                    MyButton(
                                      buttonColor: AppColors.white,
                                      textColor: AppColors.background,
                                      text: 'Desbloquear',
                                      onTap: () async {
                                        await showConfirmationBox(
                                          context: context,
                                          title:
                                              'Desbloquear usuário ${widget.user.name}',
                                          content:
                                              'Tem certeza que deseja desbloquear este usuário?',
                                          confirmationText: 'Desbloquear',
                                          onConfirm: () async {
                                            await _db.unblockUserInFirebase(
                                                widget.user.uid);
                                          },
                                        );

                                        context.mounted
                                            ? ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Usuário desbloqueado com sucesso!',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              )
                                            : null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.user.uid != _auth.getCurrentUserUid()
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () async {
                                            final chat = await getChat();
                                            if (!context.mounted) return;
                                            await Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    ChatPage(
                                                  otherUser: widget.user,
                                                  chat: chat,
                                                ),
                                                transitionDuration: Duration
                                                    .zero, // Duração da animação
                                                reverseTransitionDuration: Duration
                                                    .zero, // Duração da animação ao voltar
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.chat_rounded,
                                            color: AppColors.white,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                const Gap(20),
                                Center(
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                      color: AppColors.lightGrey,
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.network(
                                            width: 130,
                                            height: 130,
                                            widget.user.uid ==
                                                    _auth.getCurrentUserUid()
                                                ? photoUrl
                                                : user.photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                              );
                                            },
                                          ),
                                        ),
                                        widget.user.uid ==
                                                _auth.getCurrentUserUid()
                                            ? Positioned(
                                                bottom: 95,
                                                left: 95,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return GalleryOrCameraCard(
                                                            isGif: true,
                                                            onChoose: (source,
                                                                [isGif =
                                                                    false]) async {
                                                              await updateProfileImage(
                                                                  source,
                                                                  isGif);
                                                              context.mounted
                                                                  ? Navigator.of(
                                                                          context)
                                                                      .pop()
                                                                  : null;
                                                            });
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.grey,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(100),
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color: AppColors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                const Gap(15),
                                widget.user.uid != _auth.getCurrentUserUid()
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          !isCurrentUserFollowing
                                              ? MyButton(
                                                  buttonColor:
                                                      AppColors.twitterBlue,
                                                  textColor: AppColors.white,
                                                  text: 'Seguir',
                                                  onTap: () async {
                                                    await _db
                                                        .followUserInFirebase(
                                                            widget.user);
                                                  },
                                                  width: 100,
                                                )
                                              : MyButton(
                                                  buttonColor: AppColors.white,
                                                  textColor:
                                                      AppColors.background,
                                                  text: 'Deixar de seguir',
                                                  onTap: () async {
                                                    await _db
                                                        .unfollowUserInFirebase(
                                                            widget.user.uid);
                                                  },
                                                  width: 130,
                                                ),
                                          !isBlockedByCurrentUser
                                              ? MyButton(
                                                  buttonColor: AppColors.grey,
                                                  textColor: AppColors.white,
                                                  text: 'Bloquear',
                                                  onTap: () async {
                                                    await showConfirmationBox(
                                                        context: context,
                                                        title:
                                                            'Bloquear usuário ${widget.user.name}',
                                                        content:
                                                            'Tem certeza que deseja bloquear este usuário?',
                                                        confirmationText:
                                                            'Bloquear',
                                                        onConfirm: () async {
                                                          await _db
                                                              .blockUserInFirebase(
                                                                  widget.user);
                                                        });
                                                    context.mounted
                                                        ? ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Usuário bloqueado com sucesso!',
                                                              ),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          )
                                                        : null;
                                                    context.mounted
                                                        ? Navigator.of(context)
                                                            .pop()
                                                        : null;
                                                  },
                                                  width: 100,
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Container(),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '@${user.username}',
                                    style: const TextStyle(
                                      color: AppColors.lightGrey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  minVerticalPadding: 0,
                                  title: Text(
                                    user.bio.isEmpty
                                        ? user.uid == _auth.getCurrentUserUid()
                                            ? 'Adicione uma bio'
                                            : '${user.name} ainda não possui uma bio'
                                        : user.bio,
                                    style: TextStyle(
                                      color: user.bio.isEmpty
                                          ? AppColors.lightGrey
                                          : AppColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: widget.user.uid ==
                                          _auth.getCurrentUserUid()
                                      ? GestureDetector(
                                          onTap: updateUserBio,
                                          child: const Icon(
                                            Icons.edit,
                                            color: AppColors.lightGrey,
                                          ),
                                        )
                                      : null,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_sharp,
                                      color: AppColors.lightGrey,
                                    ),
                                    const Gap(5),
                                    const Text(
                                      'Entrou',
                                      style: TextStyle(
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                    const Gap(5),
                                    Text(
                                      DateService.monthAndYear(
                                        widget.user.timestamp,
                                      ),
                                      style: const TextStyle(
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                GestureDetector(
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
                                        transitionDuration: Duration
                                            .zero, // Duração da animação
                                        reverseTransitionDuration: Duration
                                            .zero, // Duração da animação ao voltar
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$followingCount Seguindo',
                                        style: const TextStyle(
                                          color: AppColors.lightGrey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Gap(20),
                                      Text(
                                        '$followersCount Seguidores',
                                        style: const TextStyle(
                                          color: AppColors.lightGrey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(20),
                                const Center(
                                  child: Text(
                                    'Tweets',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                if (!isBlockedByCurrentUser)
                                  StreamBuilder<List<Post>>(
                                    stream: _db.getPostsStream(),
                                    builder: (context, snapshot) {
                                      final posts = snapshot.data
                                              ?.where((p) =>
                                                  p.uid == widget.user.uid)
                                              .toList() ??
                                          [];

                                      if (posts.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'Nenhum post encontrado',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }

                                      return Expanded(
                                        child: RawScrollbar(
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          radius: const Radius.circular(10),
                                          thumbColor:
                                              AppColors.white.withOpacity(0.5),
                                          controller: _scrollController,
                                          thickness: 4,
                                          child: ListView.builder(
                                            controller: _scrollController,
                                            shrinkWrap: true,
                                            itemCount: posts.length,
                                            itemBuilder: (context, index) {
                                              return PostCard(
                                                post: posts[index],
                                                user: widget.user,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                if (isBlockedByCurrentUser)
                                  const Center(
                                    child: Text(
                                      'Você bloqueou este usuário',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        });
                  });
            }),
      );
    });
  }
}
