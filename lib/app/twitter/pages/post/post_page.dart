import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/models/comment.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/widgets/comment_card.dart';
import 'package:twitter/app/twitter/widgets/post_card.dart';

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.post,
    required this.user,
  });

  final Post post;
  final UserProfile user;
  @override
  Widget build(BuildContext context) {
    final _db = DatabaseService();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'T W E E T',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostCard(
            post: post,
            isClickble: false,
            isOnPage: true,
            user: user,
          ),
          const Gap(15),
          const Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Text(
              'Comentários',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(
            color: AppColors.lightGrey,
            thickness: 0.5,
          ),
          StreamBuilder<List<Comment>>(
              stream: _db.getPostCommentsStream(post.id),
              builder: (context, comments) {
                return comments.data == null
                    ? const Center(
                        child: Text('Erro ao carregar comentários'),
                      )
                    : Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return CommentCard(
                              comment: comments.data![index],
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: AppColors.lightGrey,
                            thickness: 0.5,
                          ),
                          itemCount: comments.data!.length,
                        ),
                      );
              })
        ],
      ),
    );
  }
}
