import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String uid;
  final String postId;
  final String message;
  final Timestamp timestamp;
  int likeCount;
  final List<String> likedBy;
  Comment({
    required this.id,
    required this.uid,
    required this.postId,
    required this.message,
    required this.timestamp,
    this.likeCount = 0,
    this.likedBy = const [],
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      uid: doc['uid'],
      postId: doc['postId'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      likeCount: doc['likeCount'],
      likedBy: List<String>.from(doc['likedBy']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'postId': postId,
      'message': message,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likedBy': likedBy,
    };
  }
}