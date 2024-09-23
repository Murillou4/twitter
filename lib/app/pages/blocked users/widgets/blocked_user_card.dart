import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/models/user.dart';

class BlockedUserCard extends StatefulWidget {
  const BlockedUserCard({
    super.key,
    required this.user,
  });
  final UserProfile user;

  @override
  State<BlockedUserCard> createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends State<BlockedUserCard> {
  late final databaseController =
      Provider.of<DatabaseController>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.lightGrey,
        backgroundImage: NetworkImage(widget.user.photoUrl),
      ),
      title: Text(
        widget.user.name,
        style: const TextStyle(
          color: AppColors.white,
        ),
      ),
      subtitle: Text(
        '@${widget.user.username}',
        style: const TextStyle(
          color: AppColors.lightGrey,
        ),
      ),
      trailing: GestureDetector(
        onTap: () async {
          await databaseController.unblockUser(widget.user.uid);
        },
        child: const Card(
          color: AppColors.drawerBackground,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Desbloquear',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
