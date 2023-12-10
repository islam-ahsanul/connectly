import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectly/models/ChatSession.dart';
import 'package:connectly/services/chat_service.dart';
import 'package:connectly/screens/chat_screen.dart';

class RecentChatsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<ChatSession>>(
      stream: _chatService.getRecentChats(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
            String otherUserId = chatSession.participantIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            return FutureBuilder<Map<String, dynamic>>(
              future: _chatService.getUserDetails(otherUserId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(title: Text("Loading..."));
                }

                var userDetails = userSnapshot.data!;
                String name = userDetails['name'] ?? 'Unknown';
                String profilePictureUrl = userDetails['profileImageUrl'] ?? '';

                return ListTile(
                  leading: profilePictureUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(profilePictureUrl))
                      : CircleAvatar(child: Text(name[0])),
                  title: Text(name),
                  subtitle: Text(chatSession.lastMessage),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            chatId: chatSession.chatId,
                            participantIds: chatSession.participantIds),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
