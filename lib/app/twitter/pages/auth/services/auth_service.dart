import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/providers/posts_provider.dart';
import 'package:twitter/app/twitter/providers/user_provider.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUserUid() => _auth.currentUser!.uid;

  Future<UserCredential> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signup(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> forgetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        
      );
      
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'auth/invalid-email':
          throw Exception('Email inválido');
        case 'auth/user-not-found':
          throw Exception('Usuário não encontrado');
        default:
          throw Exception(e.code);
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await postsProvider.clear();
    await userProvider.clear();
    await _auth.signOut();
  }
}
