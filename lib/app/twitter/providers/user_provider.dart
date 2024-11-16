import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/pages/auth/widgets/my_textfield.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/pages/auth/services/auth_service.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';
import 'package:twitter/app/twitter/widgets/my_loading_circle.dart';

class UserProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();
  UserProfile? loggedUserInfo;
  StreamSubscription? _notificationSubscription;

  Future<UserProfile> initLoggedUserInfo() async {
    try {
      final uid = _auth.getCurrentUserUid();

      // Busca as informações do usuário
      final userInfo = await _db.getUserInfoFromFirebase(uid);

      // Verifica se os dados foram encontrados
      if (userInfo == null) {
        await FirebaseAuth.instance.signOut();
        return Future.error('Dados do usuário não encontrados');
      }

      // Atualiza o estado e notifica
      loggedUserInfo = userInfo;
      notifyListeners();

      return userInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar informações do usuário: $e');
      }
      rethrow; // Propaga o erro para ser tratado pelo FutureBuilder
    }
  }

  Future<void> clear() async {
    await _notificationSubscription?.cancel();
    loggedUserInfo = null;
    notifyListeners();
  }

  Future<void> reloadLoggedUserInfo() async {
    loggedUserInfo =
        await _db.getUserInfoFromFirebase(_auth.getCurrentUserUid());
    notifyListeners();
  }

  Future<void> updateUserBio(String bio) async {
    await _db.updateUserBioInFirebase(bio);
    reloadLoggedUserInfo();
    notifyListeners();
  }

  Future<void> updateUserName(String newUsername) async {
    await _db.updateUserNameInFirebase(newUsername);
    reloadLoggedUserInfo();
    notifyListeners();
  }

  List<UserProfile> searchResults = [];

  Future<void> searchUsers(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    try {
      final users = await _db.searchUsersInFirebase(searchTerm);
      searchResults = users;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final controller = TextEditingController();
    final authentication = FirebaseAuth.instance;
    UserCredential? userCredential = await showDialog<UserCredential>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.drawerBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Digite sua senha',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        content: MyTextfield(
          controller: controller,
          hintText: 'Senha',
          icon: Icons.lock,
          isPassword: true,
        ),
        actions: [
          MyButton(
            width: 100,
            buttonColor: AppColors.background,
            textColor: AppColors.white,
            text: 'Cancelar',
            onTap: () => Navigator.of(context).pop(null),
          ),
          MyButton(
            width: 100,
            buttonColor: Colors.red,
            textColor: AppColors.white,
            text: 'Deletar conta',
            onTap: () async {
              try {
                final userCrend = await authentication.currentUser!
                    .reauthenticateWithCredential(
                  EmailAuthProvider.credential(
                    email: authentication.currentUser!.email!,
                    password: controller.text,
                  ),
                );
                context.mounted ? Navigator.of(context).pop(userCrend) : null;
              } catch (e) {
                context.mounted ? Navigator.of(context).pop(null) : null;
              }
            },
          ),
        ],
      ),
    );
    if (userCredential == null) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Senha inválida'),
                behavior: SnackBarBehavior.floating,
              ),
            )
          : null;
      return;
    }
    try {
      context.mounted ? showLoadingCircle(context) : null;
      await _db.deleteUserInfoInFirebase();
      if (!context.mounted) return;
      context.mounted ? hideLoadingCircle(context) : null;
      Navigator.of(context).pop();
    } catch (e) {
      context.mounted ? hideLoadingCircle(context) : null;
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString(),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            )
          : null;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
