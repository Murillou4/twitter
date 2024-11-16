import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/providers/posts_provider.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/services/database_service.dart';

import 'package:twitter/app/twitter/widgets/input_post_dialog.dart';
import 'package:twitter/app/twitter/widgets/my_drawer.dart';
import 'package:twitter/app/twitter/widgets/post_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const MyDrawer(),
        appBar: AppBar(
          title: const Text(
            'H O M E',
            style: TextStyle(
              color: AppColors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.white),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.lightGrey,
            indicatorColor: AppColors.white,
            indicatorWeight: 2,
            dividerColor: AppColors.background,
            tabs: [
              Tab(
                text: 'For you',
              ),
              Tab(
                text: 'Seguindo',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                final posts = postsProvider.posts
                    .where(
                        (p) => !postsProvider.blockedUsersIds.contains(p.uid))
                    .toList();
                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum post encontrado',
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 20,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return FutureBuilder<UserProfile?>(
                      future: _db.getUserInfoFromFirebase(posts[index].uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return PostCard(
                              post: posts[index], user: snapshot.data!);
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    thickness: 2,
                    color: AppColors.lightGrey,
                  ),
                  itemCount: posts.length,
                );
              },
            ),
            Consumer<PostsProvider>(
              builder: (context, postsProvider, child) {
                final followingPosts = postsProvider.followingPosts;
                if (followingPosts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum post encontrado',
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 20,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return FutureBuilder<UserProfile?>(
                      future: _db
                          .getUserInfoFromFirebase(followingPosts[index].uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return PostCard(
                              post: followingPosts[index],
                              user: snapshot.data!);
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    thickness: 2,
                    color: AppColors.lightGrey,
                  ),
                  itemCount: followingPosts.length,
                );
              },
            ),
          ],
        ),

        // Não deixar ele tão colado na direita
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            right: 10,
            bottom: 10,
          ),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return const InputPostDialog();
                },
              );
            },
            backgroundColor: AppColors.white,
            child: const Icon(
              Icons.add,
              color: AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
