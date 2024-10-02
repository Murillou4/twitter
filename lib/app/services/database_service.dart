import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:twitter/app/models/comment.dart';
import 'package:twitter/app/models/post.dart';
import 'package:twitter/app/models/user.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  //gs://twitter-ed33c.appspot.com/profile_images
  final _storage = FirebaseStorage.instance;
  final _messaging = FirebaseMessaging.instance;

  // User info

  Future<void> saveUserInfoInFirebase(
      {required String name, required String email}) async {
    String uid = _auth.currentUser!.uid;
    String username = email.split('@')[0];
    Timestamp timestamp = Timestamp.now();
    String deviceToken = await _messaging.getToken() ?? '';
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
      timestamp: timestamp,
      deviceToken: deviceToken,
    );

    final userMap = user.toMap();

    await _db.collection('Users').doc(uid).set(userMap);
  }

  Future<List<UserProfile>> searchUsersInFirebase(String query) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<UserProfile?> getUserInfoFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('Users').doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = _auth.currentUser!.uid;
    try {
      await _db.collection('Users').doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserNameInFirebase(String newUsername) async {
    String uid = _auth.currentUser!.uid;
    try {
      await _db.collection('Users').doc(uid).update({'username': newUsername});
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteProfileImageInFirebase() async {
    String uid = _auth.currentUser!.uid;
    try {
      ListResult listResult = await _storage.ref('profile_images').list();
      for (var item in listResult.items) {
        if (item.name.contains(uid)) {
          await item.delete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserProfileImageInFirebase(File image) async {
    String uid = _auth.currentUser!.uid;
    String type = image.path.split('.').last;
    try {
      //Delete previous image from storage if exists
      await deleteProfileImageInFirebase();
      // Add image to storage and get url
      String photoUrl = await _storage
          .ref('profile_images/$uid.$type')
          .putFile(image)
          .then((p0) => p0.ref.getDownloadURL());
      // Update image url in firebase
      _db.collection('Users').doc(uid).update({
        'photoUrl': photoUrl,
      });
    } catch (e) {
      print(e);
    }
  }

  // Post

  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      // Busca os posts
      QuerySnapshot querySnapshotPosts = await _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();

      // Mapeia os documentos para a classe Post e obtém os comentários de cada post
      List<Post> posts = [];

      for (var doc in querySnapshotPosts.docs) {
        Post post = Post.fromDocument(doc);

        // Busca os comentários na subcoleção "Comments" de cada post
        QuerySnapshot querySnapshotComments = await _db
            .collection('Posts')
            .doc(post.id)
            .collection('Comments')
            .orderBy('timestamp', descending: true)
            .get();

        // Adiciona os comentários ao post
        post.comments = querySnapshotComments.docs
            .map((commentDoc) => Comment.fromDocument(commentDoc))
            .toList();

        posts.add(post);
      }

      return posts;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Post>> getIndividualUserPostsFromFirebase(String uid) async {
    try {
      QuerySnapshot querySnapshotPosts = await _db
          .collection('Posts')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();
      // Mapeia os documentos para a classe Post e obtém os comentários de cada post
      List<Post> posts = [];

      for (var doc in querySnapshotPosts.docs) {
        Post post = Post.fromDocument(doc);

        // Busca os comentários na subcoleção "Comments" de cada post
        QuerySnapshot querySnapshotComments = await _db
            .collection('Posts')
            .doc(post.id)
            .collection('Comments')
            .orderBy('timestamp', descending: true)
            .get();

        // Adiciona os comentários ao post
        post.comments = querySnapshotComments.docs
            .map((commentDoc) => Comment.fromDocument(commentDoc))
            .toList();

        posts.add(post);
      }

      return posts;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> deletePostInFirebase(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<Comment?> addCommentInFirebase(String postId, String text) async {
    String uid = _auth.currentUser!.uid;
    try {
      Comment comment = Comment(
        id: '',
        postId: postId,
        message: text,
        uid: uid,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );
      final data = await _db
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .add(comment.toMap());
      final doc = await data.get();
      return Comment.fromDocument(doc);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> deleteCommentInFirebase(
      {required String commentId, required String postId}) async {
    try {
      await _db
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> likeCommentInFirebase(String postId, String commentId) async {
    String uid = _auth.currentUser!.uid;
    try {
      DocumentSnapshot commentDoc = await _db
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .doc(commentId)
          .get();
      Comment comment = Comment.fromDocument(commentDoc);
      if (comment.likedBy.contains(uid)) {
        await _db
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .update({
          'likeCount': comment.likeCount - 1,
          'likedBy': FieldValue.arrayRemove([uid])
        });
      } else {
        await _db
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .update({
          'likeCount': comment.likeCount + 1,
          'likedBy': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> likePostInFirebase(String postId) async {
    String uid = _auth.currentUser!.uid;
    try {
      DocumentSnapshot postDoc =
          await _db.collection('Posts').doc(postId).get();
      Post post = Post.fromDocument(postDoc);
      if (post.likedBy.contains(uid)) {
        await _db.collection('Posts').doc(postId).update({
          'likeCount': post.likeCount - 1,
          'likedBy': FieldValue.arrayRemove([uid])
        });
      } else {
        await _db.collection('Posts').doc(postId).update({
          'likeCount': post.likeCount + 1,
          'likedBy': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Post?> addPostInFirebase({
    required String message,
    File? image,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserInfoFromFirebase(uid);
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        postImage: '',
        likeCount: 0,
        likedBy: [],
      );

      final data = await _db.collection('Posts').add(newPost.toMap());
      final doc = await data.get();
      Post post = Post.fromDocument(doc);
      if (image != null) {
        String postImage = await generatePostImageLink(image, post.id);
        await _db.collection('Posts').doc(post.id).update(
          {'postImage': postImage},
        );
        final postDoc = await _db.collection('Posts').doc(post.id).get();
        post = Post.fromDocument(postDoc);
        return post;
      }
      return Post.fromDocument(doc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> followUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .set({});

    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .set({});
  }

  Future<void> unfollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .delete();

    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(uid)
        .delete();
  }

  Future<List<String>> getFollowersUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Followers').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Following').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> reportUserPostInFirebase(String postId, String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    final report = {
      'reportedBy': currentUserId,
      'postId': postId,
      'messageOwnerId': uid,
      'timestamp': Timestamp.now(),
    };

    await _db.collection('Reports').add(report);
  }

  Future<void> blockUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(uid)
        .set({});
  }

  Future<void> unblockUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(uid)
        .delete();
  }

  Future<List<String>> getBlockedUsersFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;
    final snapshot = await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<String> generatePostImageLink(File file, String postId) async {
    String type = file.path.split('.').last;
    try {
      String photoUrl = await _storage
          .ref('posts_images/$postId.$type')
          .putFile(file)
          .then((p0) => p0.ref.getDownloadURL());
      return photoUrl;
    } catch (e) {
      print(e);
      return '';
    }
  }
}
