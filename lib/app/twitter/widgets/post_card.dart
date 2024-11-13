import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/pages/post/post_page.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/src/date_service.dart';
import 'package:twitter/app/twitter/widgets/audio_player_widget.dart';
import 'package:twitter/app/twitter/widgets/confirmation_box.dart';
import 'package:twitter/app/twitter/widgets/input_dialog.dart';

class PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final _db = DatabaseService();
    final _auth = AuthService();
    final TextEditingController newCommentController = TextEditingController();
    return Container(
      color: AppColors.background,
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: _db.getUserInfoFromFirebase(post.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CircleAvatar(
                            backgroundColor: AppColors.grey,
                            backgroundImage: CachedNetworkImageProvider(
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
                            if (isClickble) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          PostPage(
                                    post: post,
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
                                DateService.timestampToDate(post.timestamp),
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
                                post.message,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const Gap(10),
                              post.postAudio.isNotEmpty
                                  ? AudioPlayerWidget(
                                      url: post.postAudio,
                                      isDeleteble: false,
                                    )
                                  : Container(),
                              post.postImage.isNotEmpty
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
                                                actions: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ],
                                                content: CachedNetworkImage(
                                                  imageUrl: post.postImage,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
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
                                          child: CachedNetworkImage(
                                            imageUrl: post.postImage,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              const Gap(10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                  if (kDebugMode) {
                                                    print('Comentário vazio');
                                                  }
                                                  return;
                                                }

                                                await _db.addCommentInFirebase(
                                                  post.id,
                                                  newCommentController.text,
                                                );
                                                newCommentController.clear();
                                                context.mounted
                                                    ? Navigator.pop(context)
                                                    : null;
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
                                      StreamBuilder<List<Post>>(
                                          stream: _db.getPostsStream(),
                                          builder: (context, postsSnapshot) {
                                            final postFromStream =
                                                postsSnapshot.data?.firstWhere(
                                                    (p) => p.id == post.id);

                                            return Text(
                                              postFromStream?.comments.length
                                                      .toString() ??
                                                  '0',
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
                                      await _db.likePostInFirebase(
                                        post.id,
                                      );

                                      return !isLiked;
                                    },
                                    isLiked: post.likedBy.contains(
                                      databaseProvider.loggedUserInfo!.uid,
                                    ),
                                    likeCount: post.likeCount,
                                    likeCountPadding: const EdgeInsets.only(
                                      left: 10,
                                      top: 5,
                                    ),
                                    countPostion: CountPostion.right,
                                    padding: const EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    countBuilder: (int? count, bool isLiked,
                                        String text) {
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
                      post.uid == _auth.getCurrentUserUid()
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
                                        if (isOnPage) {
                                          Navigator.pop(context);
                                          await _db.deletePostInFirebase(
                                            post.id,
                                          );
                                        } else {
                                          await _db.deletePostInFirebase(
                                            post.id,
                                          );
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
                                        await showConfirmationBox(
                                          context: context,
                                          title: 'Reportar post',
                                          content:
                                              'Tem certeza que deseja reportar este post?',
                                          confirmationText: 'Reportar',
                                          onConfirm: () async {
                                            await _db.reportUserPostInFirebase(
                                              post.id,
                                              _auth.getCurrentUserUid(),
                                            );
                                          },
                                        );
                                        context.mounted
                                            ? ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Post reportado com sucesso!',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              )
                                            : null;
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
                                        await showConfirmationBox(
                                          context: context,
                                          title: 'Bloquear usuário',
                                          content:
                                              'Tem certeza que deseja bloquear este usuário?',
                                          confirmationText: 'Bloquear',
                                          onConfirm: () async {
                                            final blockUser = await _db
                                                .getUserInfoFromFirebase(
                                                    post.uid);
                                            if (blockUser != null) {
                                              await _db.blockUserInFirebase(
                                                blockUser,
                                              );
                                            }
                                          },
                                        );
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
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
