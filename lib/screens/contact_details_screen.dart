import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  const ContactDetailsScreen({Key? key, required this.contact})
      : super(key: key);

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  bool isFavorite = false;

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
          ElevatedButton(onPressed: () => _makeCall(), child: Text('Call')),
          ElevatedButton(
              onPressed: () => _startVideoCall(), child: Text('Video Call')),
          ElevatedButton(onPressed: () => _startChat(), child: Text('Chat')),
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: () => _toggleFavorite(),
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

  void _startChat() {
    // Implement chat functionality
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

    // Query to find the contact document by email
    var querySnapshot = await contactsCollection
        .where('email', isEqualTo: widget.contact['email'])
        .get();

    // Assuming the email is unique and will return only one document
    if (querySnapshot.docs.isNotEmpty) {
      var contactDoc = querySnapshot.docs.first.reference;
      await contactDoc.update({
        'isFavorite': isFavorite,
      });
    }
  }
}
