import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectly/models/Chat.dart';
import 'package:connectly/models/ChatSession.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get chat messages for a specific chat session
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());

    // Update last message, timestamp, and sender ID in the chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      'lastSenderId': message.senderId, // Add this line
    });
  }

  // Create a new chat session
  Future<String> createChatSession(List<String> participantIds) async {
    // Generate a unique chat ID (e.g., combining participant IDs)
    String chatId = generateChatId(participantIds);

    // Check if the chat session already exists
    var chatSession = await _firestore.collection('chats').doc(chatId).get();
    if (!chatSession.exists) {
      // Create a new chat document with participant IDs
      await _firestore.collection('chats').doc(chatId).set({
        'participantIds': participantIds,
        'chatId': chatId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  // Generate a unique chat session ID (example implementation)
  String generateChatId(List<String> participantIds) {
    participantIds.sort(); // Ensure the order is consistent
    return participantIds.join('-');
  }

  Stream<List<ChatSession>> getRecentChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSession.fromFirestore(doc.data()))
            .toList());
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }
}
