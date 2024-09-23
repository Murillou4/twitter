import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/user.dart';
import 'package:twitter/app/pages/profile/profile.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
  });
  final UserProfile user;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: AppColors.drawerBackground,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => Profile(
                user: user,
              ),
              transitionDuration: Duration.zero, // Duração da animação
              reverseTransitionDuration:
                  Duration.zero, // Duração da animação ao voltar
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.lightGrey,
          backgroundImage: NetworkImage(user.photoUrl),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            color: AppColors.white,
          ),
        ),
        subtitle: Text(
          '@${user.username}',
          style: const TextStyle(
            color: AppColors.lightGrey,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.white,
        ),
      ),
    );
  }
}
