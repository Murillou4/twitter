import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/pages/post/post_page.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/src/date_service.dart';
import 'package:twitter/app/twitter/widgets/audio_player_widget.dart';
import 'package:twitter/app/twitter/widgets/confirmation_box.dart';
import 'package:twitter/app/twitter/widgets/input_dialog.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.isClickble = true,
    this.isOnPage = false,
    required this.user,
  });
  final Post post;
  final bool isClickble;
  final bool isOnPage;
  final UserProfile user;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final userProvider = Provider.of<UserProvider>(context, listen: false);
  final _db = DatabaseService();
  final _auth = AuthService();
  final TextEditingController newCommentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Post post = widget.post;
    final currentUserUid = _auth.getCurrentUserUid();
    return Container(
      color: AppColors.background,
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CircleAvatar(
                    backgroundColor: AppColors.grey,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.user.photoUrl,
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
                          pageBuilder: (context, animation1, animation2) =>
                              PostPage(
                            post: widget.post,
                            user: widget.user,
                          ),
                          transitionDuration:
                              Duration.zero, // Duração da animação
                          reverseTransitionDuration:
                              Duration.zero, // Duração da animação ao voltar
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
                              pageBuilder: (context, animation1, animation2) =>
                                  Profile(
                                user: widget.user,
                              ),
                              transitionDuration:
                                  Duration.zero, // Duração da animação
                              reverseTransitionDuration: Duration
                                  .zero, // Duração da animação ao voltar
                            ),
                          );
                        },
                        child: Text(
                          widget.user.name,
                          style: const TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        '@${widget.user.username}',
                        style: const TextStyle(
                          color: AppColors.lightGrey,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        DateService.timestampToDate(widget.post.timestamp),
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
                              url: widget.post.postAudio,
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
                                        backgroundColor: Colors.transparent,
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
                                          imageUrl: widget.post.postImage,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
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
                                    imageUrl: widget.post.postImage,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
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
                                        if (newCommentController.text.isEmpty) {
                                          if (kDebugMode) {
                                            print('Comentário vazio');
                                          }
                                          return;
                                        }

                                        await _db.addCommentInFirebase(
                                          widget.post.id,
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
                              Text(
                                post.comments.length.toString(),
                                style: const TextStyle(
                                  color: AppColors.lightGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                color:
                                    isLiked ? Colors.red : AppColors.lightGrey,
                              );
                            },
                            onTap: (bool isLiked) async {
                              await _db.likePostInFirebase(
                                widget.post.id,
                              );

                              return !isLiked;
                            },
                            isLiked: post.likedBy.contains(currentUserUid),
                            likeCount: post.likeCount,
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
              widget.post.uid == currentUserUid
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
                                  await _db.deletePostInFirebase(
                                    widget.post.id,
                                  );
                                } else {
                                  await _db.deletePostInFirebase(
                                    widget.post.id,
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
                                      widget.post.id,
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
                                          behavior: SnackBarBehavior.floating,
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
                                    final blockUser =
                                        await _db.getUserInfoFromFirebase(
                                            widget.post.uid);
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
          ),
        ],
      ),
    );
  }
}
