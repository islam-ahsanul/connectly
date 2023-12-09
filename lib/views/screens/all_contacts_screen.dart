import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectly/views/widgets/contact_search.dart';

class AllContactsScreen extends StatefulWidget {
  const AllContactsScreen({Key? key}) : super(key: key);

  @override
  State<AllContactsScreen> createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends State<AllContactsScreen> {
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Contacts'),
        // Add a search icon if you plan to implement a search feature
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(contacts),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  contacts[index]['profileImageUrl'] ?? 'default_image_url'),
            ),
            title: Text(contacts[index]['name']),
            subtitle: Text(contacts[index]['email']),
          );
        },
      ),
    );
  }

  void _loadContacts() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    var contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts');

    var querySnapshot = await contactsCollection.get();
    setState(() {
      contacts = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
