import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/core/app_colors.dart';

import 'package:twitter/app/twitter/widgets/input_post_dialog.dart';
import 'package:twitter/app/twitter/widgets/my_drawer.dart';
import 'package:twitter/app/twitter/widgets/post_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  final TextEditingController postController = TextEditingController();
  ScrollController scrollController = ScrollController();
  ListController listController = ListController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await databaseProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, database, child) {
      final posts = database.posts;
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
              posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Nenhum tweet',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 30,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await databaseProvider.init();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.white,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await databaseProvider.init();
                      },
                      child: SuperListView.separated(
                        listController: listController,
                        controller: scrollController,
                        restorationId: 'home_page',
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(
                          color: AppColors.lightGrey,
                          thickness: 1,
                        ),
                        itemCount: posts.length,
                      ),
                    ),
              FutureBuilder(
                future: databaseProvider.getFollowingPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return snapshot.data!.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum tweet',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 30,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            return PostCard(post: snapshot.data![index]);
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: AppColors.lightGrey,
                            thickness: 0.5,
                          ),
                          itemCount: snapshot.data!.length,
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
    });
  }
}
