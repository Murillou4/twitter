import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/comment.dart';
import 'package:twitter/app/models/post.dart';
import 'package:twitter/app/widgets/comment_card.dart';
import 'package:twitter/app/widgets/post_card.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listeningController = Provider.of<DatabaseController>(context);
  @override
  Widget build(BuildContext context) {
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
            post: widget.post,
            isClickble: false,
            isOnPage: true,
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
          widget.post.comments.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum comentário',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 20,
                    ),
                  ),
                )
              : Flexible(
                  child: Consumer<DatabaseController>(
                      builder: (context, databaseController, child) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CommentCard(
                          comment: widget.post.comments[index],
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.lightGrey,
                        thickness: 0.5,
                      ),
                      itemCount: widget.post.comments.length,
                    );
                  }),
                )
        ],
      ),
    );
  }
}
