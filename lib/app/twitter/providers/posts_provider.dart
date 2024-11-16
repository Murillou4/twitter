import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'dart:async';

class PostsProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();

  List<Post> posts = [];
  List<Post> followingPosts = [];
  List<String> blockedUsersIds = [];
  List<String> followingUsersIds = [];

  StreamSubscription? _postsSubscription;
  StreamSubscription? _blockedUsersSubscription;
  StreamSubscription? _followingUsersSubscription;

  Future<void> _initPostsDataLocally() async {
    blockedUsersIds = (await _db.getBlockedUsersFromFirebase())
        .map((user) => user.uid)
        .toList();
    posts = await _db.getPostsFromFirebase();
    followingUsersIds = (await _db.getFollowingUsersFromFirebase())
        .map((user) => user.uid)
        .toList();
    followingPosts =
        posts.where((post) => followingUsersIds.contains(post.uid)).toList();
    notifyListeners();
  }

  void init() {
    // Inicializa os dados locais
    _initPostsDataLocally();
    // Inscreve-se nas streams
    _postsSubscription = _db.getPostsSnapshotStream().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        final post = Post.fromDocument(change.doc);
        if (change.type == DocumentChangeType.added) {
          !blockedUsersIds.contains(post.uid) ? posts.insert(0, post) : null;
          followingUsersIds.contains(post.uid)
              ? followingPosts.insert(0, post)
              : null;
          notifyListeners();
          break;
        } else if (change.type == DocumentChangeType.modified) {
          if (!blockedUsersIds.contains(post.uid)) {
            posts[posts.indexWhere((p) => p.id == post.id)].comments =
                post.comments;
            posts[posts.indexWhere((p) => p.id == post.id)].likeCount =
                post.likeCount;
            posts[posts.indexWhere((p) => p.id == post.id)].likedBy =
                post.likedBy;
            posts[posts.indexWhere((p) => p.id == post.id)].postImage =
                post.postImage;
            posts[posts.indexWhere((p) => p.id == post.id)].postAudio =
                post.postAudio;
            notifyListeners();
          }

          break;
        } else if (change.type == DocumentChangeType.removed) {
          !blockedUsersIds.contains(post.uid)
              ? posts.removeWhere((p) => p.id == post.id)
              : null;
          notifyListeners();
          break;
        }
      }
    });
    _blockedUsersSubscription =
        _db.getBlockedUsersStream().listen(_handleBlockedUsersUpdate);
    _followingUsersSubscription = _db
        .getUserFollowingStream(_auth.getCurrentUserUid())
        .listen(_handleFollowingUsersUpdate);
  }

  void _handleBlockedUsersUpdate(List<UserProfile> blockedUsers) {
    blockedUsersIds = blockedUsers.map((user) => user.uid).toList();
    notifyListeners();
  }

  void _handleFollowingUsersUpdate(List<UserProfile> followingUsers) {
    followingUsersIds = followingUsers.map((user) => user.uid).toList();

    // Atualiza lista de posts de usuários seguidos
    followingPosts =
        posts.where((post) => followingUsersIds.contains(post.uid)).toList();

    notifyListeners();
  }

  Future<void> clear() async {
    await _postsSubscription?.cancel();
    await _blockedUsersSubscription?.cancel();
    await _followingUsersSubscription?.cancel();
    posts = [];
    followingPosts = [];
    blockedUsersIds = [];
    followingUsersIds = [];
  }

  @override
  void dispose() async {
    await _postsSubscription?.cancel();
    await _blockedUsersSubscription?.cancel();
    await _followingUsersSubscription?.cancel();
    super.dispose();
  }
}
