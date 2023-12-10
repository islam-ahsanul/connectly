import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String chatId;
  final List<String> participantIds;
  final String lastMessage; // last message text
  final DateTime lastMessageTime; // timestamp of the last message
  final String lastSenderId; // ID of the user who sent the last message

  ChatSession({
    required this.chatId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId, // Add this line
  });

  // Update factory method accordingly
  factory ChatSession.fromFirestore(Map<String, dynamic> firestore) {
    return ChatSession(
      chatId: firestore['chatId'] ?? '',
      participantIds: List<String>.from(firestore['participantIds'] ?? []),
      lastMessage: firestore['lastMessage'] ?? '',
      lastMessageTime: (firestore['lastMessageTime'] as Timestamp).toDate(),
      lastSenderId: firestore['lastSenderId'] ?? '', // Add this line
    );
  }

  // Update toFirestore method if needed
  // ...
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastSenderId': lastSenderId, // Add this line
    };
  }
}
