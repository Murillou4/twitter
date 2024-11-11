import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter/app/twitter/models/post.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String photoUrl;
  final Timestamp timestamp;
  final String deviceToken;

  UserProfile(
      {required this.uid,
      required this.name,
      required this.email,
      required this.username,
      required this.bio,
      this.photoUrl =
          'https://tanzolymp.com/images/default-non-user-no-photo-1.jpg',
      required this.timestamp,
      required this.deviceToken});

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      photoUrl: doc['photoUrl'],
      timestamp: doc['timestamp'],
      deviceToken: doc['deviceToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl,
      'timestamp': timestamp,
      'deviceToken': deviceToken
    };
  }
}
