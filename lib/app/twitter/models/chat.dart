import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart'; // Importe a classe Message

class Chat {
  final String chatId;
  final List<String> participants;
  final Message lastMessage;

  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: Message.fromMap(data['lastMessage'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage.toMap(),
    };
  }

  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
