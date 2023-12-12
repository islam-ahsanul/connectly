import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/providers/contacts_provider.dart';
import 'package:connectly/screens/chat_screen.dart';
import 'package:connectly/services/chat_service.dart';
import 'package:connectly/screens/call_screen.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

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
            icon: const Icon(Icons.delete),
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
            const SizedBox(height: 8),
            Text(
              widget.contact['name'],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: widget.contact['email']));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email copied to clipboard')),
                );
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(4, 24, 4, 2),
                child: Text(
                  widget.contact['email'],
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: widget.contact['phoneNumber']));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Phone number copied to clipboard')),
                );
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(4, 2, 4, 24),
                child: Text(
                  widget.contact['phoneNumber'],
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            Expanded(
                child: _buildActionButton(Icons.call, 'Call',
                    () => _makeCall(widget.contact['phoneNumber']))),
            const SizedBox(width: 8),
            Expanded(
                child: _buildActionButton(
                    Icons.videocam, 'Video Call', _startVideoCall)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: _buildActionButton(Icons.message, 'Chat', _startChat)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildActionButton(Icons.email, 'Send Email',
                    () => _sendEmail(widget.contact['email']))),
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

  void _makeCall(String phoneNumber) async {
    // Implement call functionality
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void _sendEmail(String email) {
    // Implement email functionality
    launch('mailto:$email');
  }

  void _startVideoCall() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null ||
        currentUser.email == null ||
        currentUser.email!.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        String email = '';
        return StatefulBuilder(
          // Use StatefulBuilder here
          builder: (BuildContext context, StateSetter setState) {
            // This setState is local to the StatefulBuilder
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: SingleChildScrollView(
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
                        setState(() {
                          // Update the local state of the dialog
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
              ),
            );
          },
        );
      },
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
