import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:connectly/widgets/contact_search.dart';
import 'package:connectly/screens/contact_details_screen.dart';
import 'package:connectly/providers/contacts_provider.dart';
import 'package:connectly/screens/new_contact_screen.dart';

class AllContactsScreen extends ConsumerStatefulWidget {
  const AllContactsScreen({Key? key}) : super(key: key);

  @override
  _AllContactsScreenState createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends ConsumerState<AllContactsScreen> {
  late Future<DocumentSnapshot> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    _userProfileFuture =
        FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(contactsProvider.notifier).fetchContacts();
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Connectly'),
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewContactScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
          FutureBuilder<DocumentSnapshot>(
            future: _userProfileFuture,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String profileImageUrl =
                    userData['profileImageUrl'] ?? 'default_fallback_image_url';
                return GestureDetector(
                  onTap: () {
                    _showProfileOptions(context);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                );
              }
              // Show a placeholder or loading indicator while waiting for the data
              return const CircleAvatar(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ContactDetailsScreen(contact: contacts[index]),
                ),
              );
            },
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

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to the settings screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
