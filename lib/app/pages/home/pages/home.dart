import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/post.dart';
import 'package:twitter/app/pages/auth/services/auth_service.dart';
import 'package:twitter/app/widgets/input_dialog.dart';
import 'package:twitter/app/widgets/input_post_dialog.dart';
import 'package:twitter/app/widgets/my_button.dart';
import 'package:twitter/app/widgets/my_drawer.dart';
import 'package:twitter/app/widgets/post_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = AuthService();
  late final listeningController = Provider.of<DatabaseController>(context);
  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);
  final TextEditingController postController = TextEditingController();
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseController.init();
  }
  
  @override
  Widget build(BuildContext context) {
    List<Post> posts = databaseController.posts;
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
                            await databaseController.init();
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
                    onRefresh: databaseController.init,
                    child: ListView.separated(
                      key: const PageStorageKey<String>('forYouList'),
                      addAutomaticKeepAlives: true,
                      addSemanticIndexes: true,
                      addRepaintBoundaries: true,
                      cacheExtent: 100,
                      shrinkWrap: true,
                      controller: scrollController,
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
              future: databaseController.getFollowingPosts(),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return InputPostDialog();
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
    );
  }
}