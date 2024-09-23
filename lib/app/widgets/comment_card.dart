import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/comment.dart';
import 'package:twitter/app/models/user.dart';
import 'package:twitter/app/pages/profile/profile.dart';
import 'package:twitter/app/services/database_service.dart';
import 'package:twitter/app/src/date_service.dart';

class CommentCard extends StatefulWidget {
  CommentCard({super.key, required this.comment});
  Comment comment;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late final listeningController = Provider.of<DatabaseController>(context);
  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    bool likedByCurrentUser =
        listeningController.isCommentLikedByCurrentUser(widget.comment.id);
    int likes = listeningController.getCommentsLikeCount(widget.comment.id);
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
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
                          backgroundImage: NetworkImage(
                            user?.photoUrl ?? '',
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(
                                        user: user!,
                                      ),
                                    ));
                              },
                              child: Text(
                                user?.name ?? '',
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await databaseController.likeComment(
                                      postId: widget.comment.postId,
                                      commentId: widget.comment.id,
                                    );
                                  },
                                  child: likedByCurrentUser
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.favorite,
                                          color: AppColors.lightGrey,
                                        ),
                                ),
                                const Gap(5),
                                Text(
                                  likes.toString(),
                                  style: const TextStyle(
                                    color: AppColors.lightGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.comment.uid == databaseController.loggedUserInfo?.uid
                        ? Flexible(
                            flex: 1,
                            child: IconButton(
                              onPressed: () async {
                                await databaseController.deleteComment(
                                  widget.comment.id,
                                  widget.comment.postId,
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
              }),
        ],
      ),
    );
  }
}
