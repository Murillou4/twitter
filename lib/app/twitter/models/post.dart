import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter/app/twitter/models/comment.dart';

class Post {
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final String postImage;
  final String postAudio;
  int likeCount;
  final List<String> likedBy;
  List<Comment> comments;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    this.likeCount = 0,
    this.likedBy = const [],
    this.postImage = '',
    this.postAudio = '',
    this.comments = const [],
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      postImage: doc['postImage'],
      postAudio: doc['postAudio'],
      likeCount: doc['likeCount'],
      likedBy: List<String>.from(doc['likedBy']),
      comments: List<Comment>.from(
          doc['comments'].map((comment) => Comment.fromMap(comment))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'postImage': postImage,
      'postAudio': postAudio,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }
}
