import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/providers/contacts_provider.dart';
import 'package:connectly/screens/chat_screen.dart';
import 'package:connectly/services/chat_service.dart';

class ContactDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> contact;

  const ContactDetailsScreen({Key? key, required this.contact})
      : super(key: key);

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends ConsumerState<ContactDetailsScreen> {
  bool isFavorite = false;

  final ChatService _chatService = ChatService();

  void _startChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String chatId = await _chatService
        .createChatSession([currentUser.uid, widget.contact['uid']]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          participantIds: [currentUser.uid, widget.contact['uid']],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isFavorite = widget.contact['isFavorite'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact['name']),
      ),
      body: Column(
        children: [
          // Display contact details
          Text('Email: ${widget.contact['email']}'),
          Text('Phone: ${widget.contact['phone']}'),
          // Other details...

          // Action buttons
          ElevatedButton(onPressed: _makeCall, child: Text('Call')),
          ElevatedButton(onPressed: _startVideoCall, child: Text('Video Call')),
          ElevatedButton(onPressed: _startChat, child: Text('Chat')),
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
          ElevatedButton(
            onPressed: _deleteContact,
            child: Text('Delete Contact'),
            style: ElevatedButton.styleFrom(primary: Colors.red),
          ),
        ],
      ),
    );
  }

  void _makeCall() {
    // Implement call functionality
  }

  void _startVideoCall() {
    // Implement video call functionality
  }

  void _toggleFavorite() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    var contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts');

    var querySnapshot = await contactsCollection
        .where('email', isEqualTo: widget.contact['email'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var contactDoc = querySnapshot.docs.first.reference;
      await contactDoc.update({
        'isFavorite': isFavorite,
      });
    }

    ref.read(contactsProvider.notifier).toggleFavorite(widget.contact['email']);
  }

  void _deleteContact() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    var contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts');

    var querySnapshot = await contactsCollection
        .where('email', isEqualTo: widget.contact['email'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var contactDoc = querySnapshot.docs.first.reference;
      await contactDoc.delete();
    }

    Navigator.pop(context); // Pop back to the previous screen after deletion
  }
}
