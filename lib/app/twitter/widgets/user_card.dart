import 'package:flutter/material.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });
  final UserProfile user;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: AppColors.drawerBackground,
      child: ListTile(
        onTap: onTap,
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
