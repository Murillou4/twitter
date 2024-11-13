import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:twitter/app/twitter/models/chat.dart';
import 'package:twitter/app/twitter/models/comment.dart';
import 'package:twitter/app/twitter/models/message.dart';
import 'package:twitter/app/twitter/models/post.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  //gs://twitter-ed33c.appspot.com/profile_images
  final _storage = FirebaseStorage.instance;

  // User info

  Future<void> saveUserInfoInFirebase(
      {required String name, required String email}) async {
    String uid = _auth.currentUser!.uid;
    String username = email.split('@')[0];
    final timestamp = FieldValue.serverTimestamp();

    final userMap = {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': '',
      'timestamp': timestamp,
      'photoUrl':
          'https://tanzolymp.com/images/default-non-user-no-photo-1.jpg',
    };

    await _db.collection('Users').doc(uid).set(userMap);
  }

  Future<bool> userAlreadyExistsInFirebase() async {
    final uid = _auth.currentUser!.uid;
    final snapshot =
        await _db.collection('Users').where('uid', isEqualTo: uid).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteUserInfoInFirebase() async {
    String uid = _auth.currentUser!.uid;

    // Primeiro deletar todas as relações e dados

    //Unfollow all users
    List<String> followingUids = await getFollowingUidsFromFirebase(uid);
    for (var followingUid in followingUids) {
      await unfollowUserInFirebase(followingUid);
    }

    //Remove user from following
    List<String> followersUids = await getFollowersUidsFromFirebase(uid);

    for (var followerUid in followersUids) {
      await removeUserFromFollowing(followerUid, uid);
    }

    //Delete user posts
    QuerySnapshot postsSnapshot =
        await _db.collection('Posts').where('uid', isEqualTo: uid).get();
    for (var post in postsSnapshot.docs) {
      await deletePostInFirebase(post.id);
    }

    //Delete user chats
    QuerySnapshot chatsSnapshot = await _db
        .collection('Chats')
        .where('participants', arrayContains: uid)
        .get();
    for (var chat in chatsSnapshot.docs) {
      await deleteChat(chat.id);
    }

    // Delete user profile picture
    await deleteProfileImageInFirebase(uid);
    await _db.collection('Users').doc(uid).delete();

    // Por último, deletar a conta do Auth
    try {
      await _auth.currentUser!.delete();
    } catch (e) {
      throw 'Essa operação é sensível e precisa de uma autenticação recente';
    }
  }

  Future<void> removeUserFromFollowing(
      String sourceUid, String targetUid) async {
    final docFollowingRef = await _db
        .collection('Users')
        .doc(sourceUid)
        .collection('Following')
        .where('uid', isEqualTo: targetUid)
        .get();
    await docFollowingRef.docs.first.reference.delete();
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

  Future<void> deleteProfileImageInFirebase(String uid) async {
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
      await deleteProfileImageInFirebase(uid);
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

  Future<void> deletePostInFirebase(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
      await deletePostImageInFirebase(postId);
      await deletePostAudioInFirebase(postId);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addCommentInFirebase(String postId, String text) async {
    String uid = _auth.currentUser!.uid;
    try {
      // Primeiro, buscamos o documento do post
      DocumentReference postRef = _db.collection('Posts').doc(postId);
      DocumentSnapshot postDoc = await postRef.get();

      // Obtemos a lista atual de comentários com o cast apropriado
      List<dynamic> currentComments =
          List.from((postDoc.data() as Map<String, dynamic>)['comments'] ?? []);

      // Criamos o novo comentário com Timestamp.now()
      final commentMap = {
        'id': Uuid().v4(),
        'postId': postId,
        'message': text,
        'uid': uid,
        'timestamp': Timestamp.now(),
        'likeCount': 0,
        'likedBy': [],
      };

      // Adicionamos o novo comentário à lista
      currentComments.add(commentMap);

      // Atualizamos o documento com a nova lista de comentários
      await postRef.update({
        'comments': currentComments,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteCommentInFirebase(
      {required Comment comment, required String postId}) async {
    try {
      await _db.collection('Posts').doc(postId).update({
        'comments': FieldValue.arrayRemove([comment.toMap()])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> likeCommentInFirebase(String postId, String commentId) async {
    String uid = _auth.currentUser!.uid;

    try {
      // Referência ao documento do post no Firestore
      final postRef = _db.collection('Posts').doc(postId);

      // Obtenha os dados atuais do post
      final postSnapshot = await postRef.get();
      if (!postSnapshot.exists) {
        print('Post não encontrado');
        return;
      }

      // Converta a lista de comentários para uma lista mutável
      List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
          postSnapshot.data()?['comments'] ?? []);

      // Encontre o comentário e atualize os campos `likeCount` e `likedBy`
      for (var comment in comments) {
        if (comment['id'] == commentId) {
          List<dynamic> likedBy = List.from(comment['likedBy'] ?? []);

          if (likedBy.contains(uid)) {
            // Se já curtiu, faz "unlike"
            comment['likeCount'] = (comment['likeCount'] ?? 0) - 1;
            likedBy.remove(uid);
          } else {
            // Se ainda não curtiu, faz "like"
            comment['likeCount'] = (comment['likeCount'] ?? 0) + 1;
            likedBy.add(uid);
          }

          // Atualize o campo `likedBy` com a nova lista
          comment['likedBy'] = likedBy;
          break; // Saia do loop após encontrar o comentário
        }
      }

      // Atualize o documento com a lista modificada de comentários
      await postRef.update({
        'comments': comments,
      });
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
    File? audio,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserInfoFromFirebase(uid);

      if (user == null) {
        throw 'Usuário não encontrado';
      }

      // Processa imagem e áudio em paralelo se existirem
      String postImage = '';
      String postAudio = '';

      final postRef = await _db.collection('Posts').add({
        'uid': uid,
        'name': user.name,
        'username': user.username,
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'postImage': postImage,
        'postAudio': postAudio,
        'likeCount': 0,
        'likedBy': [],
        'comments': [],
      });

      // Processa mídia em paralelo se existir
      if (image != null || audio != null) {
        final futures = <Future>[];

        if (image != null) {
          futures.add(generatePostImageLink(image, postRef.id).then((url) {
            postImage = url;
          }));
        }

        if (audio != null) {
          futures.add(generatePostAudioLink(audio, postRef.id).then((url) {
            postAudio = url;
          }));
        }

        await Future.wait(futures);

        // Atualiza o post com as URLs de mídia
        await postRef.update({
          if (postImage.isNotEmpty) 'postImage': postImage,
          if (postAudio.isNotEmpty) 'postAudio': postAudio,
        });
      }

      final postDoc = await postRef.get();
      return Post.fromDocument(postDoc);
    } catch (e) {
      debugPrint('Erro ao criar post: $e');
      return null;
    }
  }

  Future<void> followUserInFirebase(UserProfile user) async {
    final currentUserId = _auth.currentUser!.uid;
    final currentUser = await getUserInfoFromFirebase(currentUserId);

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .add(user.toMap());

    await _db
        .collection('Users')
        .doc(user.uid)
        .collection('Followers')
        .add(currentUser!.toMap());
  }

  Future<void> unfollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;
    try {
      final docFollowingRef = await _db
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .where('uid', isEqualTo: uid)
          .get();
      await docFollowingRef.docs.first.reference.delete();

      final docFollowersRef = await _db
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .where('uid', isEqualTo: currentUserId)
          .get();
      await docFollowersRef.docs.first.reference.delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<List<UserProfile>> getFollowersFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Followers').get();
    return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
  }

  Future<List<String>> getFollowersUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Followers').get();
    List<UserProfile> followersUsers = [];
    for (var doc in snapshot.docs) {
      followersUsers.add(UserProfile.fromDocument(doc));
    }
    return followersUsers.map((user) => user.uid).toList();
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Following').get();
    List<UserProfile> followingUsers = [];
    for (var doc in snapshot.docs) {
      followingUsers.add(UserProfile.fromDocument(doc));
    }
    return followingUsers.map((user) => user.uid).toList();
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

  Future<void> blockUserInFirebase(UserProfile user) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(user.uid)
        .set(user.toMap());
    await unfollowUserInFirebase(user.uid);
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

  Future<void> deletePostImageInFirebase(String postId) async {
    try {
      ListResult listResult = await _storage.ref('posts_images').list();
      for (var item in listResult.items) {
        if (item.name.contains(postId)) {
          await item.delete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> generatePostAudioLink(File file, String postId) async {
    String type = file.path.split('.').last;
    try {
      String audioUrl = await _storage
          .ref('posts_audios/$postId.$type')
          .putFile(file)
          .then((p0) => p0.ref.getDownloadURL());
      return audioUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePostAudioInFirebase(String postId) async {
    try {
      ListResult listResult = await _storage.ref('posts_audios').list();
      for (var item in listResult.items) {
        if (item.name.contains(postId)) {
          await item.delete();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  ///
  /// Chat
  ///

  Future<void> sendMessage(String receiverId, String content) async {
    if (content.trim().isEmpty) {
      throw 'A mensagem não pode estar vazia';
    }

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw 'Usuário não está autenticado';
    }

    if (currentUserId == receiverId) {
      throw 'Não é possível enviar mensagem para si mesmo';
    }

    try {
      // Cria um ID de chat consistente
      final chatId = [currentUserId, receiverId]..sort();
      final String consistentChatId = '${chatId[0]}_${chatId[1]}';
      final timestamp = FieldValue.serverTimestamp();

      // Prepara os dados da mensagem
      final messageData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'content': content.trim(),
        'timestamp': timestamp,
        'isRead': false,
        'isLiked': false,
      };

      // Usa transação para garantir consistência
      await _db.runTransaction((transaction) async {
        // Atualiza ou cria o documento do chat
        final chatRef = _db.collection('Chats').doc(consistentChatId);

        transaction.set(
            chatRef,
            {
              'participants': [currentUserId, receiverId],
              'lastMessage': messageData,
            },
            SetOptions(merge: true));

        // Adiciona a mensagem na subcoleção
        final messageRef = chatRef.collection('Messages').doc();
        transaction.set(messageRef, messageData);
      });
    } catch (e) {
      throw 'Erro ao enviar mensagem: ${e.toString()}';
    }
  }

  Future<Chat> getChat(String chatId) async {
    final chat = await _db.collection('Chats').doc(chatId).get();
    return Chat.fromDocument(chat);
  }

  Future<void> likeMessage(String chatId, String messageId) async {
    await _db
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .doc(messageId)
        .update({'isLiked': true});
  }

  Future<void> unlikeMessage(String chatId, String messageId) async {
    await _db
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .doc(messageId)
        .update({'isLiked': false});
  }

  //Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _db
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .doc(messageId)
        .delete();
  }

  // Marcar mensagem como lida
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _db
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<void> markChatLastMessageAsRead(String chatId) async {
    final chat = await _db.collection('Chats').doc(chatId).get();
    final lastMessage = Message.fromMap(chat['lastMessage']);
    Message newLastMessage = Message(
      id: lastMessage.id,
      senderId: lastMessage.senderId,
      receiverId: lastMessage.receiverId,
      content: lastMessage.content,
      timestamp: lastMessage.timestamp,
      isRead: true,
    );
    await _db.collection('Chats').doc(chatId).update({
      'lastMessage': newLastMessage.toMap(),
    });
  }

  // Buscar mensagens
  Stream<List<Message>> getMessages(String otherUserId) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Cria o mesmo ID consistente
    final chatId = [currentUserId, otherUserId]..sort();
    final String consistentChatId = '${chatId[0]}_${chatId[1]}';

    return _db
        .collection('Chats')
        .doc(consistentChatId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromDocument(doc)).toList());
  }

  // Buscar chats do usuário
  Stream<List<Chat>> getUserChats() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('Chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList());
  }

  // Deletar chat
  Future<void> deleteChat(String chatId) async {
    await _db.collection('Chats').doc(chatId).delete();
  }

  Stream<List<UserProfile>> getUserFollowersStream(String uid) {
    try {
      return _db
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .snapshots()
          .asyncMap((snapshot) async {
        return snapshot.docs
            .map((doc) => UserProfile.fromDocument(doc))
            .toList();
      });
    } catch (e) {
      print(e);
      return Stream.empty();
    }
  }

  Stream<List<UserProfile>> getUserFollowingStream(String uid) {
    try {
      return _db
          .collection('Users')
          .doc(uid)
          .collection('Following')
          .snapshots()
          .asyncMap((snapshot) async {
        return snapshot.docs
            .map((doc) => UserProfile.fromDocument(doc))
            .toList();
      });
    } catch (e) {
      print(e);
      return Stream.empty();
    }
  }

  Stream<List<UserProfile>> getBlockedUsersStream() {
    final currentUserId = _auth.currentUser!.uid;
    return _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList());
  }

  ///
  /// Posts
  ///

  Stream<List<Post>> getPostsStream() {
    return _db
        .collection('Posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  Stream<List<Comment>> getPostCommentsStream(String postId) {
    // Os comentários não são uma coleção e sim uma lista de maps
    return _db.collection('Posts').doc(postId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];

      final List<dynamic> commentsData = snapshot.data()?['comments'] ?? [];
      return commentsData
          .map((commentData) =>
              Comment.fromMap(Map<String, dynamic>.from(commentData)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(
            a.timestamp)); // Ordena do mais recente para o mais antigo
    });
  }
}
