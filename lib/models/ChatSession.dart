import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String chatId;
  final List<String> participantIds;
  final String lastMessage; // last message text
  final DateTime lastMessageTime; // timestamp of the last message

  ChatSession({
    required this.chatId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  // Factory method to create a ChatSession from a Firestore document
  factory ChatSession.fromFirestore(Map<String, dynamic> firestore) {
    return ChatSession(
      chatId: firestore['chatId'] ?? '',
      participantIds: List<String>.from(firestore['participantIds'] ?? []),
      lastMessage: firestore['lastMessage'] ?? '',
      lastMessageTime: (firestore['lastMessageTime'] as Timestamp).toDate(),
    );
  }

  // Optionally, add a method to convert a ChatSession to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }
}
