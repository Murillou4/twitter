import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter/app/models/comment.dart';
import 'package:twitter/app/models/post.dart';
import 'package:twitter/app/services/database_service.dart';
import 'package:twitter/app/pages/auth/services/auth_service.dart';
import 'package:twitter/app/models/user.dart';
import 'package:twitter/app/src/download_gif.dart';

class DatabaseController extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();
  UserProfile? loggedUserInfo;
  List<Post> posts = [];
  Map<String, int> postsLikeCount = {};
  List<String> userLikedPosts = [];
  List<Comment> comments = [];
  Map<String, int> commentsLikeCount = {};
  List<String> userLikedComments = [];
  List<UserProfile> blockedUsers = [];
  final Map<String, List<String>> followers = {};
  final Map<String, List<String>> following = {};
  final Map<String, int> followersCount = {};
  final Map<String, int> followingCount = {};

  Future<void> init() async {
    clear();
    await initLoggedUserInfo();
    await initBlockedUsers();
    await initPosts();
    await initComments();
    await initPostsLikeMap();
    await initCommentsLikeMap();
    await initUserFollowers(_auth.getCurrentUserUid());
    await initUserFollowing(_auth.getCurrentUserUid());
  }

  void clear() {
    loggedUserInfo = null;
    posts = [];
    postsLikeCount = {};
    userLikedPosts = [];
    comments = [];
    commentsLikeCount = {};
    userLikedComments = [];
  }

  Future<List<Post>> getFollowingPosts() async {
    final uid = _auth.getCurrentUserUid();
    List<String> userFollowingUsers = following[uid] ?? [];

    List<Post> followingPosts = [];
    for (var user in userFollowingUsers) {
      followingPosts.addAll(posts.where((post) => post.uid == user));
    }

    return followingPosts;
  }

  Future<void> initPosts() async {
    posts = await getPosts();
    final blockedUsersIds = await _db.getBlockedUsersFromFirebase();

    posts = posts.where((post) => !blockedUsersIds.contains(post.uid)).toList();
    notifyListeners();
  }

  Future<void> initBlockedUsers() async {
    final blockedUsersIds = await _db.getBlockedUsersFromFirebase();

    final blockedUsersData = await Future.wait(
      blockedUsersIds.map(
        (id) => _db.getUserInfoFromFirebase(id),
      ),
    );

    blockedUsers = blockedUsersData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  Future<void> initComments() async {
    comments = await getPostsComments();
    notifyListeners();
  }

  Future<void> initPostsLikeMap() async {
    final uid = _auth.getCurrentUserUid();
    for (var post in posts) {
      postsLikeCount[post.id] = post.likeCount;

      if (post.likedBy.contains(uid)) {
        userLikedPosts.add(post.id);
      }
    }
  }

  Future<void> initCommentsLikeMap() async {
    final uid = _auth.getCurrentUserUid();
    for (var comment in comments) {
      commentsLikeCount[comment.id] = comment.likeCount;

      if (comment.likedBy.contains(uid)) {
        userLikedComments.add(comment.id);
      }
    }
  }

  Future<void> blockUser(String uid) async {
    await _db.blockUserInFirebase(uid);

    await initBlockedUsers();

    await initPosts();
    notifyListeners();
  }

  Future<void> unblockUser(String uid) async {
    await _db.unblockUserInFirebase(uid);
    await initBlockedUsers();

    await initPosts();
    notifyListeners();
  }

  Future<void> reportUserPost(String postId, String uid) async {
    await _db.reportUserPostInFirebase(uid, postId);
  }

  Future<void> addNewPost({required String text, File? image}) async {
    final post = await _db.addPostInFirebase(message: text, image: image);
    posts.insert(0, post!);
    notifyListeners();
  }

  Future<void> addNewComment(
      {required String postId, required String text}) async {
    Comment? comment = await _db.addCommentInFirebase(postId, text);
    comments.insert(0, comment!);
    notifyListeners();
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _db.deleteCommentInFirebase(commentId: commentId, postId: postId);
    comments.removeWhere((element) => element.id == commentId);
    notifyListeners();
  }

  bool isPostLikedByCurrentUser(String postId) =>
      userLikedPosts.contains(postId);

  int getPostsLikeCount(String postId) => postsLikeCount[postId] ?? 0;

  bool isCommentLikedByCurrentUser(String commentId) =>
      userLikedComments.contains(commentId);

  int getCommentsLikeCount(String commentId) =>
      commentsLikeCount[commentId] ?? 0;

  int getFollowersCount(String uid) => followersCount[uid] ?? 0;

  int getFollowingCount(String uid) => followingCount[uid] ?? 0;

  Future<void> initUserFollowers(String uid) async {
    final listOfFollowersUids = await _db.getFollowersUidsFromFirebase(uid);

    followers[uid] = listOfFollowersUids;
    followersCount[uid] = listOfFollowersUids.length;

    notifyListeners();
  }

  Future<void> initUserFollowing(String uid) async {
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    following[uid] = listOfFollowingUids;
    followingCount[uid] = listOfFollowingUids.length;
    notifyListeners();
  }

  Future<void> followUser(String targetUid) async {
    final currentUserUid = _auth.getCurrentUserUid();

    followers.putIfAbsent(targetUid, () => []);
    following.putIfAbsent(currentUserUid, () => []);

    if (!followers[targetUid]!.contains(currentUserUid)) {
      followers[targetUid]?.add(currentUserUid);
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) + 1;

      following[currentUserUid]?.add(targetUid);
      followingCount[currentUserUid] =
          (followingCount[currentUserUid] ?? 0) + 1;
    }

    notifyListeners();
    try {
      await _db.followUserInFirebase(targetUid);

      await initUserFollowers(currentUserUid);
      await initUserFollowing(currentUserUid);
    } catch (e) {
      followers[targetUid]?.remove(currentUserUid);

      followersCount[targetUid] = (followersCount[targetUid] ?? 0) - 1;

      following[currentUserUid]?.remove(targetUid);
      followingCount[currentUserUid] =
          (followingCount[currentUserUid] ?? 0) - 1;

      notifyListeners();
    }
  }

  Future<void> unfollowUser(String targetUid) async {
    final currentUserUid = _auth.getCurrentUserUid();

    followers.putIfAbsent(targetUid, () => []);
    following.putIfAbsent(currentUserUid, () => []);

    if (followers[targetUid]!.contains(currentUserUid)) {
      followers[targetUid]?.remove(currentUserUid);
      followersCount[targetUid] = (followersCount[targetUid] ?? 1) - 1;

      following[currentUserUid]?.remove(targetUid);
      followingCount[currentUserUid] =
          (followingCount[currentUserUid] ?? 1) - 1;
    }

    notifyListeners();

    try {
      await _db.unfollowUserInFirebase(targetUid);

      await initUserFollowers(currentUserUid);
      await initUserFollowing(currentUserUid);
    } catch (e) {
      followers[targetUid]?.add(currentUserUid);
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) + 1;

      following[currentUserUid]?.add(targetUid);
      followingCount[currentUserUid] =
          (followingCount[currentUserUid] ?? 0) + 1;

      notifyListeners();
    }
  }

  bool isFollowing(String uid) =>
      followers[uid]?.contains(_auth.getCurrentUserUid()) ?? false;

  Future<void> likePost(String postId) async {
    final uid = _auth.getCurrentUserUid();

    final userLikedPostsOriginal = userLikedPosts;
    final postsLikeCountOriginal = postsLikeCount;

    if (userLikedPosts.contains(postId)) {
      userLikedPosts.remove(postId);
      postsLikeCount[postId] = (postsLikeCountOriginal[postId] ?? 0) - 1;
    } else {
      userLikedPosts.add(postId);
      postsLikeCount[postId] = (postsLikeCountOriginal[postId] ?? 0) + 1;
    }

    try {
      await _db.likePostInFirebase(postId);
    } catch (e) {
      userLikedPosts = userLikedPostsOriginal;
      postsLikeCount = postsLikeCountOriginal;
    }
  }

  Future<void> likeComment(
      {required String postId, required String commentId}) async {
    final userLikedCommentsOriginal = userLikedComments;
    final commentsLikeCountOriginal = commentsLikeCount;

    if (userLikedComments.contains(commentId)) {
      userLikedComments.remove(commentId);
      commentsLikeCount[commentId] =
          (commentsLikeCountOriginal[commentId] ?? 0) - 1;
    } else {
      userLikedComments.add(commentId);
      commentsLikeCount[commentId] =
          (commentsLikeCountOriginal[commentId] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.likeCommentInFirebase(postId, commentId);
    } catch (e) {
      userLikedComments = userLikedCommentsOriginal;
      commentsLikeCount = commentsLikeCountOriginal;
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    await _db.deletePostInFirebase(postId);
    posts = await getPosts();
    notifyListeners();
  }

  Future<List<Post>> getPosts() async {
    return await _db.getAllPostsFromFirebase();
  }

  Future<List<Comment>> getPostsComments() async {
    return await _db.getPostsCommentsFromFirebase();
  }

  Future<List<Post>> getUserPosts(String uid) async {
    return await _db.getIndividualUserPostsFromFirebase(uid);
  }

  Future<UserProfile?> userProfile(String uid) async {
    return await _db.getUserInfoFromFirebase(uid);
  }

  Future<void> initLoggedUserInfo() async {
    final uid = _auth.getCurrentUserUid();
    loggedUserInfo = await userProfile(uid);
    notifyListeners();
  }

  Future<void> updateUserBio(String bio) async {
    final uid = _auth.getCurrentUserUid();
    await _db.updateUserBioInFirebase(bio);
    loggedUserInfo = await userProfile(uid);
    notifyListeners();
  }

  Future<void> updateUserName(String newUsername) async {
    final uid = _auth.getCurrentUserUid();
    await _db.updateUserNameInFirebase(newUsername);
    loggedUserInfo = await userProfile(uid);
    notifyListeners();
  }

  Future<void> updateProfileImage(BuildContext context ,ImageSource source,
      [bool isGif = false]) async {
    final uid = _auth.getCurrentUserUid();
    if (isGif) {
      final gif = await GiphyPicker.pickGif(
          context: context, apiKey: 'LgLuuMlL3aaDQHRHL5gXsVtgHY9woHTU');
      if (gif == null) return;
      // Baixa o GIF da URL e salva localmente
      final gifUrl = gif.images.original!.url;
      final gifFile = await downloadGif(gifUrl!);
      await _db.updateUserProfileImageInFirebase(gifFile);
      loggedUserInfo = await userProfile(uid);
      notifyListeners();
      return;
    }
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: source);
    if (image == null) return;
    File file = File(image.path);
    await _db.updateUserProfileImageInFirebase(file);
    loggedUserInfo = await userProfile(uid);
    notifyListeners();
  }

  List<UserProfile> searchResults = [];

  Future<void> searchUsers(String searchTerm) async {
    try {
      final users = await _db.searchUsersInFirebase(searchTerm);
      searchResults = users;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
