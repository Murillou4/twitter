import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/chat.dart';
import 'package:twitter/app/twitter/models/user_profile.dart';
import 'package:twitter/app/twitter/pages/chat/pages/chat_page.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/src/date_service.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    super.key,
    required this.chat,
  });
  final Chat chat;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final _db = DatabaseService();

  bool get hasUnreadMessage {
    return widget.chat.lastMessage!.senderId != currentUserId &&
        !widget.chat.lastMessage!.isRead;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _db.getUserInfoFromFirebase(
        widget.chat.getOtherParticipantId(
          currentUserId,
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: AppColors.drawerBackground,
            child: Stack(
              children: [
                ListTile(
                  onTap: () async {
                    if (widget.chat.lastMessage != null) {
                      if (hasUnreadMessage) {
                        await _db.markChatLastMessageAsRead(widget.chat.chatId);
                      }
                    }
                    context.mounted
                        ? Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  ChatPage(
                                otherUser: user,
                                chat: widget.chat,
                              ),
                              transitionDuration:
                                  Duration.zero, // Duração da animação
                              reverseTransitionDuration: Duration
                                  .zero, // Duração da animação ao voltar
                            ),
                          )
                        : null;
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.lightGrey,
                    backgroundImage: NetworkImage(user!.photoUrl),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: AppColors.lightGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(5),
                      Text(
                        DateService.timestampToDayAndMonth(
                          widget.chat.lastMessage?.timestamp ?? Timestamp.now(),
                        ),
                        style: const TextStyle(
                          color: AppColors.lightGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    widget.chat.lastMessage?.content ?? '',
                    style: const TextStyle(
                      color: AppColors.lightGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.chat_rounded,
                    color: AppColors.white,
                  ),
                ),
                if (hasUnreadMessage)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.twitterBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
