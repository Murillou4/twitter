import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/user.dart';
import 'package:twitter/app/pages/auth/services/auth_service.dart';
import 'package:twitter/app/pages/follow/follow_page.dart';
import 'package:twitter/app/src/date_service.dart';
import 'package:twitter/app/widgets/confirmation_box.dart';
import 'package:twitter/app/widgets/gallery_or_camera_card.dart';
import 'package:twitter/app/widgets/my_button.dart';
import 'package:twitter/app/widgets/my_loading_circle.dart';
import 'package:twitter/app/widgets/post_card.dart';

class Profile extends StatefulWidget {
  Profile({
    super.key,
    required this.user,
  });
  UserProfile user;
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = AuthService();
  late final listeningController = Provider.of<DatabaseController>(context);
  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseController.initUserFollowers(widget.user.uid);
    databaseController.initUserFollowing(widget.user.uid);
  }

  void updateUserBio() async {
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

                await databaseController.updateUserBio(bioController.text);
                setState(() {
                  widget.user = UserProfile(
                    uid: widget.user.uid,
                    name: widget.user.name,
                    username: widget.user.username,
                    email: widget.user.email,
                    bio: bioController.text, // Define a nova bio aqui
                    photoUrl: widget.user.photoUrl,
                    timestamp: widget.user.timestamp,
                    deviceToken: widget.user.deviceToken,
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
    bool isCurrentUserFollowing =
        listeningController.isFollowing(widget.user.uid);
    int followersCount = listeningController.getFollowersCount(widget.user.uid);
    int followingCount = listeningController.getFollowingCount(widget.user.uid);
    bool isBlockedByCurrentUser =
        listeningController.isUserBlockedByCurrentUser(widget.user.uid);
    return Consumer<DatabaseController>(builder: (context, value, child) {
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            width: 130,
                            height: 130,
                            widget.user.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                              );
                            },
                          ),
                        ),
                        widget.user.uid == _auth.getCurrentUserUid()
                            ? Positioned(
                                bottom: 95,
                                left: 95,
                                child: GestureDetector(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return GalleryOrCameraCard(
                                          onChoose: databaseController
                                              .updateProfileImage,
                                        );
                                      },
                                    );

                                    widget.user = await databaseController
                                            .userProfile(widget.user.uid) ??
                                        widget.user;
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          !isCurrentUserFollowing
                              ? MyButton(
                                  buttonColor: AppColors.twitterBlue,
                                  textColor: AppColors.white,
                                  text: 'Seguir',
                                  onTap: () {
                                    databaseController
                                        .followUser(widget.user.uid);
                                  },
                                  width: 100,
                                )
                              : MyButton(
                                  buttonColor: AppColors.white,
                                  textColor: AppColors.background,
                                  text: 'Deixar de seguir',
                                  onTap: () {
                                    databaseController
                                        .unfollowUser(widget.user.uid);
                                  },
                                  width: 130,
                                ),
                          !isBlockedByCurrentUser
                              ? MyButton(
                                  buttonColor: AppColors.grey,
                                  textColor: AppColors.white,
                                  text: 'Bloquear',
                                  onTap: () async {
                                    bool confirmation =
                                        await showConfirmationBox(
                                      context: context,
                                      title:
                                          'Deseja bloquear ${widget.user.name}?',
                                      confirmationText: 'Bloquear',
                                    );

                                    if (confirmation) {
                                      await databaseController
                                          .blockUser(widget.user.uid);
                                      context.mounted
                                          ? ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Usuário bloqueado com sucesso!',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            )
                                          : null;
                                      context.mounted
                                          ? Navigator.of(context).pop()
                                          : null;
                                    }
                                  },
                                  width: 100,
                                )
                              : MyButton(
                                  buttonColor: AppColors.grey,
                                  textColor: AppColors.white,
                                  text: 'Desbloquear',
                                  onTap: () async {
                                    bool confirmation =
                                        await showConfirmationBox(
                                      context: context,
                                      title:
                                          'Deseja desbloquear ${widget.user.name}?',
                                      confirmationText: 'Desbloquear',
                                    );

                                    if (confirmation) {
                                      await databaseController
                                          .unblockUser(widget.user.uid);
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
                                    }
                                  },
                                ),
                        ],
                      )
                    : Container(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.user.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '@${widget.user.username}',
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
                    widget.user.bio,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                  trailing: widget.user.uid == _auth.getCurrentUserUid()
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
                        pageBuilder: (context, animation1, animation2) =>
                            FollowPage(
                          followersUserUids:
                              databaseController.followers[widget.user.uid] ??
                                  [],
                          followingUserUids:
                              databaseController.following[widget.user.uid] ??
                                  [],
                        ),
                        transitionDuration:
                            Duration.zero, // Duração da animação
                        reverseTransitionDuration:
                            Duration.zero, // Duração da animação ao voltar
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
                FutureBuilder(
                  future: databaseController.getUserPosts(widget.user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao carregar posts'),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum post encontrado',
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: snapshot.data![index],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
