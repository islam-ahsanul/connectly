import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({Key? key}) : super(key: key);

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  if (_searchQuery.isNotEmpty) {
                    _searchUsers(_searchQuery);
                  } else {
                    setState(() {
                      _searchResults = [];
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  suffixIcon:
                      _searchQuery.isNotEmpty ? const Icon(Icons.search) : null,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index]['name']),
                    subtitle: Text(_searchResults[index]['email']),
                    onTap: () async {
                      bool contactAdded =
                          await _addContact(_searchResults[index]);
                      if (contactAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${_searchResults[index]['name']} added to contacts.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to add contact.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    String searchUpperBound = query.substring(0, query.length - 1) +
        String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);

    var usersCollection = FirebaseFirestore.instance.collection('users');
    var emailResults = await usersCollection
        .where('email',
            isGreaterThanOrEqualTo: query, isLessThan: searchUpperBound)
        .get();
    var phoneResults = await usersCollection
        .where('phoneNumber',
            isGreaterThanOrEqualTo: query, isLessThan: searchUpperBound)
        .get();

    setState(() {
      _searchResults = [
        ...emailResults.docs.map((doc) => doc.data()),
        ...phoneResults.docs.map((doc) => doc.data()),
      ];
    });
  }

  Future<bool> _addContact(Map<String, dynamic> contactData) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where there is no logged-in user
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
      // Contact already exists
      return false;
    }

    await contactsCollection.add({
      'uid': contactData['uid'],
      'name': contactData['name'],
      'email': contactData['email'],
      'phoneNumber': contactData['phoneNumber'],
      'profileImageUrl': contactData['profileImageUrl'],
      'isFavorite': false,
      'birthdate': contactData['birthdate'],
      'address': contactData['address'],
      // Add other relevant fields
    });

    return true;
  }
}
