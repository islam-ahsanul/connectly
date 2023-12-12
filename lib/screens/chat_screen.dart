import 'package:flutter/material.dart';
import 'package:connectly/services/chat_service.dart';
import 'package:connectly/models/Chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectly/screens/call_screen.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final List<String> participantIds;

  const ChatScreen(
      {Key? key, required this.chatId, required this.participantIds})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String otherParticipantId = '';
  String otherParticipantName = 'Loading...';
  String otherParticipantNumber = 'Loading...';
  String otherParticipantProfileUrl = '';

  @override
  void initState() {
    super.initState();
    _loadParticipantData();
  }

  void _loadParticipantData() async {
    otherParticipantId = _getOtherParticipantId();

    try {
      var userDetails = await _chatService.getUserDetails(otherParticipantId);
      setState(() {
        otherParticipantName = userDetails['name'] ?? 'Unknown User';
        otherParticipantNumber = userDetails['phoneNumber'] ?? 'Unknown User';
        otherParticipantProfileUrl = userDetails['profileImageUrl'] ?? '';
      });
    } catch (e) {
      print('Error fetching participant details: $e');
    }
  }

  String _getOtherParticipantId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return ''; // or handle this scenario appropriately
    }

    return widget.participantIds.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () =>
          '', // Return an empty string if no other participant is found
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (otherParticipantProfileUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(otherParticipantProfileUrl),
              ),
            SizedBox(width: 10),
            Text(otherParticipantName),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              // Add your call function here
              FlutterPhoneDirectCaller.callNumber(otherParticipantNumber);
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: _startVideoCall,
            // onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                var messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message.senderId ==
                        FirebaseAuth.instance.currentUser!.uid;
                    return _buildMessageTile(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Type a message'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    var message = ChatMessage(
      senderId: FirebaseAuth.instance.currentUser!.uid,
      text: _messageController.text,
      timestamp: DateTime.now(),
    );
    _chatService.sendMessage(widget.chatId, message);
    _messageController.clear();
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _startVideoCall() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null ||
        currentUser.email == null ||
        currentUser.email!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        String email = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('Start Instant Meeting'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CallPage(callID: currentUser.email!),
                        ),
                      );
                    },
                  ),
                  TextField(
                    onChanged: (value) {
                      setModalState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter email to join call',
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Join Call'),
                    onPressed: email.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallPage(callID: email),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
