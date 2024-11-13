import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:twitter/app/core/app_colors.dart';

import 'package:intl/intl.dart';
import 'package:twitter/app/twitter/models/message.dart';
import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/src/date_service.dart';
import 'package:twitter/app/twitter/widgets/my_button.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  final String chatId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatId,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    if (!widget.message.isRead &&
        widget.message.senderId != FirebaseAuth.instance.currentUser!.uid) {
      _db.markMessageAsRead(widget.chatId, widget.message.id);
    }
    return GestureDetector(
      onLongPress: () {
        //Abrir um popup para deletar a mensagem se o usuário for o remetente
        if (widget.isMe) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text('Deletar mensagem'),
              content:
                  const Text('Tem certeza que deseja deletar esta mensagem?'),
              actions: [
                MyButton(
                  width: 100,
                  buttonColor: AppColors.background,
                  textColor: AppColors.white,
                  text: 'Cancelar',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                MyButton(
                  width: 100,
                  buttonColor: Colors.red,
                  textColor: AppColors.white,
                  text: 'Deletar',
                  onTap: () async {
                    await _db.deleteMessage(
                      widget.chatId,
                      widget.message.id,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
      onDoubleTap: () {
        if (widget.isMe) {
          return;
        }
        if (!widget.message.isLiked) {
          _db.likeMessage(widget.chatId, widget.message.id);
        } else {
          _db.unlikeMessage(widget.chatId, widget.message.id);
        }
      },
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    widget.isMe ? Colors.blueGrey : AppColors.drawerBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message.content,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateService.timestampToHourAndMinute(
                            widget.message.timestamp),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      !widget.message.isRead
                          ? const Icon(
                              Icons.check,
                              color: Colors.white70,
                              size: 16,
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 16,
                            ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.message.isLiked)
              Positioned(
                bottom: 0,
                right: 0,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
