import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectly/models/ChatSession.dart';
import 'package:connectly/screens/chat_screen.dart';

class RecentChatsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<ChatSession>>(
      stream: _getRecentChats(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(snapshot.data);
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No recent chats'));
        }

        var recentChats = snapshot.data!;
        return ListView.builder(
          itemCount: recentChats.length,
          itemBuilder: (context, index) {
            var chatSession = recentChats[index];
            return ListTile(
              title: Text(chatSession.lastMessage),
              subtitle: Text(chatSession.lastMessageTime.toString()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(chatId: chatSession.chatId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Stream<List<ChatSession>> _getRecentChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSession.fromFirestore(doc.data()))
            .toList());
  }
}
