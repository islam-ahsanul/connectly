import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory method to create a ChatMessage from a Firestore document
  factory ChatMessage.fromFirestore(Map<String, dynamic> firestore) {
    return ChatMessage(
      senderId: firestore['senderId'] ?? '',
      text: firestore['text'] ?? '',
      timestamp: (firestore['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert a ChatMessage to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
