import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/comment.dart';
import 'package:twitter/app/models/post.dart';
import 'package:twitter/app/models/user.dart';
import 'package:twitter/app/pages/auth/services/auth_service.dart';
import 'package:twitter/app/pages/post/post_page.dart';
import 'package:twitter/app/pages/profile/profile.dart';
import 'package:twitter/app/src/date_service.dart';
import 'package:twitter/app/widgets/confirmation_box.dart';
import 'package:twitter/app/widgets/input_dialog.dart';

UserProfile skeletonUserProfile = UserProfile(
  uid: '',
  name: 'Name',
  username: 'Username',
  photoUrl: '',
  email: 'email@email.com',
  bio: 'Bio',
  timestamp: Timestamp.now(),
  deviceToken: 'deviceToken',
);

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.isClickble = true,
    this.isOnPage = false,
  });
  final Post post;
  final bool isClickble;
  final bool isOnPage;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _auth = AuthService();

  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);

  final TextEditingController newCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool likedByCurrentUser =
        databaseController.isPostLikedByCurrentUser(widget.post.id);
    int likes = databaseController.getPostsLikeCount(widget.post.id);

    return Container(
      color: AppColors.background,
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: databaseController.userProfile(widget.post.uid),
            initialData: skeletonUserProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CircleAvatar(
                          backgroundColor: AppColors.grey,
                          backgroundImage: NetworkImage(
                            snapshot.data!.photoUrl,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Flexible(
                      flex: 6,
                      child: ListTile(
                        onTap: () {
                          if (widget.isClickble) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        PostPage(
                                  post: widget.post,
                                ),
                                transitionDuration:
                                    Duration.zero, // Duração da animação
                                reverseTransitionDuration: Duration
                                    .zero, // Duração da animação ao voltar
                              ),
                            );
                          } else {
                            return;
                          }
                        },
                        contentPadding: const EdgeInsets.all(0),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            Profile(
                                      user: snapshot.data!,
                                    ),
                                    transitionDuration:
                                        Duration.zero, // Duração da animação
                                    reverseTransitionDuration: Duration
                                        .zero, // Duração da animação ao voltar
                                  ),
                                );
                              },
                              child: Text(
                                snapshot.data!.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            Text(
                              '@${snapshot.data!.username}',
                              style: const TextStyle(
                                color: AppColors.lightGrey,
                              ),
                            ),
                            const Gap(5),
                            Text(
                              DateService.timestampToDate(
                                  widget.post.timestamp),
                              style: const TextStyle(
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.message,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
                            ),
                            widget.post.postImage.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          useSafeArea: true,
                                          builder: (context) {
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.zero,
                                              backgroundColor:
                                                  Colors.transparent,
                                              content: Image.network(
                                                widget.post.postImage,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 155,
                                          maxWidth: 180,
                                        ),
                                        child: Image.network(
                                          widget.post.postImage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            const Gap(10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) => InputDialog(
                                            controller: newCommentController,
                                            hintText: 'Seu comentário aqui',
                                            onTapText: 'Comentar',
                                            onTap: () async {
                                              if (newCommentController
                                                  .text.isEmpty) {
                                                print('Comentário vazio');
                                                return;
                                              }

                                              await databaseController
                                                  .addNewComment(
                                                      postId: widget.post.id,
                                                      text: newCommentController
                                                          .text);
                                              newCommentController.clear();
                                              context.mounted
                                                  ? Navigator.pop(context)
                                                  : null;
                                              if (widget.isClickble) {
                                                context.mounted
                                                    ? Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                                  animation1,
                                                                  animation2) =>
                                                              PostPage(
                                                            post: widget.post,
                                                          ),
                                                          transitionDuration:
                                                              Duration
                                                                  .zero, // Duração da animação
                                                          reverseTransitionDuration:
                                                              Duration
                                                                  .zero, // Duração da animação ao voltar
                                                        ),
                                                      )
                                                    : null;
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.comment,
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                    const Gap(5),
                                    Consumer<DatabaseController>(builder:
                                        (context, databaseController, _) {
                                      return Text(
                                        widget.post.comments.length.toString(),
                                        style: const TextStyle(
                                          color: AppColors.lightGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                const Gap(20),
                                //Likes
                                LikeButton(
                                  size: 20,
                                  circleColor: const CircleColor(
                                    start: AppColors.lightGrey,
                                    end: AppColors.lightGrey,
                                  ),
                                  bubblesColor: const BubblesColor(
                                    dotPrimaryColor: AppColors.lightGrey,
                                    dotSecondaryColor: AppColors.lightGrey,
                                  ),
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isLiked
                                          ? Colors.red
                                          : AppColors.lightGrey,
                                    );
                                  },
                                  onTap: (bool isLiked) async {
                                    await databaseController.likePost(
                                      widget.post.id,
                                    );

                                    return !isLiked;
                                  },
                                  isLiked: likedByCurrentUser,
                                  likeCount: likes,
                                  likeCountPadding: const EdgeInsets.only(
                                    left: 10,
                                    top: 5,
                                  ),
                                  countPostion: CountPostion.right,
                                  padding: const EdgeInsets.only(
                                    bottom: 5,
                                  ),
                                  countBuilder:
                                      (int? count, bool isLiked, String text) {
                                    return Text(
                                      text,
                                      style: const TextStyle(
                                        color: AppColors.lightGrey,
                                        fontWeight: FontWeight.w500,
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
                    widget.post.uid == databaseController.loggedUserInfo?.uid
                        ? Flexible(
                            flex: 1,
                            child: PopupMenuButton(
                              color: AppColors.drawerBackground,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: const ListTile(
                                      title: Text(
                                        'Deletar',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                    onTap: () async {
                                      if (widget.isOnPage) {
                                        Navigator.pop(context);
                                        await databaseController
                                            .deletePost(widget.post.id);
                                      } else {
                                        await databaseController
                                            .deletePost(widget.post.id);
                                      }
                                    },
                                  ),
                                ];
                              },
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.lightGrey,
                              ),
                            ),
                          )
                        : Flexible(
                            flex: 1,
                            child: PopupMenuButton(
                              color: AppColors.drawerBackground,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: const ListTile(
                                      title: Text(
                                        'Reportar',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.report,
                                        color: Colors.amberAccent,
                                      ),
                                    ),
                                    onTap: () async {
                                      bool confirmation =
                                          await showConfirmationBox(
                                        context: context,
                                        title: 'Prosseguir com o report?',
                                        confirmationText: 'Reportar',
                                      );
                                      if (confirmation) {
                                        await databaseController.reportUserPost(
                                          widget.post.id,
                                          widget.post.uid,
                                        );
                                        context.mounted
                                            ? ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Usário reportado',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              )
                                            : null;
                                      }
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const ListTile(
                                      title: Text(
                                        'Bloquear usuário',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                    ),
                                    onTap: () async {
                                      bool confirmation =
                                          await showConfirmationBox(
                                        context: context,
                                        title: 'Prosseguir com o bloqueio?',
                                        confirmationText: 'Bloquear',
                                      );
                                      if (confirmation) {
                                        await databaseController
                                            .blockUser(widget.post.uid);
                                        context.mounted
                                            ? ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Usário bloqueado',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              )
                                            : null;
                                      }
                                    },
                                  ),
                                ];
                              },
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
