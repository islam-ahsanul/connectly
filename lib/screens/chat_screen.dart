import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectly/services/chat_service.dart';
import 'package:connectly/models/Chat.dart';
import 'package:connectly/screens/call_screen.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:connectly/providers/contacts_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final List<String> participantIds;

  const ChatScreen(
      {Key? key, required this.chatId, required this.participantIds})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<ChatMessage>> _chatMessagesStream;

  String otherParticipantId = '';
  String otherParticipantName = 'Loading...';
  String otherParticipantNumber = 'Loading...';
  String otherParticipantProfileUrl = '';
  String otherParticipantEmail = '';
  String otherParticipantBirthdate = '';
  String otherParticipantAddress = '';
  bool _isUserDetailsFetched = false;

  @override
  void initState() {
    super.initState();
    _chatMessagesStream = _chatService.getChatMessages(widget.chatId);
    if (!_isUserDetailsFetched) {
      _loadParticipantData();
      _isUserDetailsFetched = true;
    }
  }

  void _loadParticipantData() async {
    otherParticipantId = _getOtherParticipantId();

    try {
      var userDetails = await _chatService.getUserDetails(otherParticipantId);
      if (mounted) {
        setState(() {
          otherParticipantName = userDetails['name'] ?? 'Unknown User';
          otherParticipantNumber = userDetails['phoneNumber'] ?? 'Unknown User';
          otherParticipantEmail = userDetails['email'] ?? '';
          otherParticipantProfileUrl = userDetails['profileImageUrl'] ?? '';
          otherParticipantBirthdate = userDetails['birthdate'] ?? '';
          otherParticipantAddress = userDetails['address'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching participant details: $e');
    }
  }

  String _getOtherParticipantId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return '';
    }
    return widget.participantIds.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () => '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);
    final isContact =
        contacts.any((contact) => contact['uid'] == otherParticipantId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (otherParticipantProfileUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(otherParticipantProfileUrl),
              ),
            const SizedBox(width: 10),
            Text(otherParticipantName),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () =>
                FlutterPhoneDirectCaller.callNumber(otherParticipantNumber),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isContact)
            ElevatedButton(
              onPressed: () => _addContact(context, {
                'uid': otherParticipantId,
                'name': otherParticipantName,
                'email': otherParticipantEmail,
                'phoneNumber': otherParticipantNumber,
                'profileImageUrl': otherParticipantProfileUrl,
                'birthdate': otherParticipantBirthdate,
                'address': otherParticipantAddress,
              }),
              child: const Text('Add to Contacts'),
            ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatMessagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet'));
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Type a message'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
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
      duration: const Duration(milliseconds: 300),
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String email = '';
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Start Instant Meeting'),
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
                    decoration: const InputDecoration(
                      labelText: 'Enter email to join call',
                    ),
                  ),
                  ElevatedButton(
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
                    child: const Text('Join Call'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _addContact(
      BuildContext context, Map<String, dynamic> contactData) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    }

    var contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts');

    var existingContact = await contactsCollection
        .where('uid', isEqualTo: contactData['uid'])
        .get();
    if (existingContact.docs.isNotEmpty) {
      return false;
    }

    await contactsCollection.add(contactData);

    // Refetch contacts after adding a new contact
    ref.read(contactsProvider.notifier).fetchContacts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contactData['name']} added to contacts.')),
    );
    return true;
  }
}
