import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart'; // Importe a classe Message

class Chat {
  final String chatId;
  final List<String> participants;
  final Message? lastMessage;

  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
  });

  factory Chat.fromDocument(DocumentSnapshot doc) {
    List<String> auxParticipants = [];
    Message? auxLastMessage;
    try {
      auxParticipants = List<String>.from(doc['participants'] ?? []);
    } catch (e) {
      auxParticipants = [];
    }

    try {
      auxLastMessage = Message.fromMap(doc['lastMessage'] ?? {});
    } catch (e) {
      auxLastMessage = null;
    }
    return Chat(
      chatId: doc.id,
      participants: auxParticipants,
      lastMessage: auxLastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage?.toMap(),
    };
  }

  factory Chat.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return Chat(
      chatId: map['chatId'],
      participants: List<String>.from(map['participants']),
      lastMessage: Message.fromMap(map['lastMessage']),
    );
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
