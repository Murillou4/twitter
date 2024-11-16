import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/comment.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/src/date_service.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key, required this.comment});
  final Comment comment;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final _db = DatabaseService();
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    bool likedByCurrentUser =
        widget.comment.likedBy.contains(_auth.getCurrentUserUid());
    int likes = widget.comment.likeCount;
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<UserProfile?>(
            future: _db.getUserInfoFromFirebase(widget.comment.uid),
            builder: (context, snapshot) {
              UserProfile? user = snapshot.data;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          user?.photoUrl ??
                              'https://tanzolymp.com/images/default-non-user-no-photo-1.jpg',
                          errorListener: (p0) {
                            if (kDebugMode) {
                              print(p0);
                            }
                          },
                        ),
                        radius: 20,
                      ),
                    ),
                  ),
                  const Gap(10),
                  Flexible(
                    flex: 6,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (user != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(
                                        user: user,
                                      ),
                                    ));
                              }
                            },
                            child: Text(
                              user?.name ?? 'Deleted User',
                              style: const TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          Text(
                            '@${user?.username ?? ''}',
                            style: const TextStyle(
                              color: AppColors.lightGrey,
                            ),
                          ),
                          const Gap(5),
                          Text(
                            DateService.timestampToDate(
                              widget.comment.timestamp,
                            ),
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
                            widget.comment.message,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                            ),
                          ),
                          const Gap(5),
                          LikeButton(
                            onTap: (bool isLiked) async {
                              await _db.likeCommentInFirebase(
                                widget.comment.postId,
                                widget.comment.id,
                              );
                              return !isLiked;
                            },
                            isLiked: likedByCurrentUser,
                            size: 20,
                            likeCount: likes,
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isLiked ? Colors.red : AppColors.lightGrey,
                                size: 20,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.comment.uid == _auth.getCurrentUserUid()
                      ? Flexible(
                          flex: 1,
                          child: IconButton(
                            onPressed: () async {
                              await _db.deleteCommentInFirebase(
                                comment: widget.comment,
                                postId: widget.comment.postId,
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.lightGrey,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
