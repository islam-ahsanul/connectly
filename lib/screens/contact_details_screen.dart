import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/providers/contacts_provider.dart';
import 'package:connectly/screens/chat_screen.dart';
import 'package:connectly/services/chat_service.dart';
import 'package:connectly/screens/call_screen.dart';

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
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteContact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.contact['profileImageUrl']),
            ),
            SizedBox(height: 8),
            Text(
              widget.contact['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(widget.contact['email']),
            Text(widget.contact['phoneNumber']),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildActionButton(Icons.call, 'Call', _makeCall)),
            SizedBox(width: 8), // Spacing between buttons
            Expanded(
                child: _buildActionButton(
                    Icons.videocam, 'Video Call', _startVideoCall)),
          ],
        ),
        SizedBox(height: 16), // Spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: _buildActionButton(Icons.message, 'Chat', _startChat)),
            SizedBox(width: 8), // Spacing between buttons
            Expanded(
                child:
                    _buildActionButton(Icons.email, 'Send Email', _sendEmail)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _makeCall() {
    // Implement call functionality
  }

  void _sendEmail() {}

  void _startVideoCall() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String callID = '1'; // Replace with your actual call ID

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(callID: callID),
      ),
    );
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
