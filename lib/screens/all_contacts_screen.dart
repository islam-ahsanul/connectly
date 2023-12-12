import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/widgets/contact_search.dart';
import 'package:connectly/screens/contact_details_screen.dart';
import 'package:connectly/providers/contacts_provider.dart'; // Adjust the import based on your project structure
import 'package:connectly/screens/new_contact_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllContactsScreen extends ConsumerWidget {
  const AllContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          GestureDetector(
            onTap: () {
              _showProfileOptions(context);
            },
            child: CircleAvatar(
                // Placeholder for user profile image
                // backgroundImage: AssetImage('assets/images/chat.png'),
                ),
          ),
          SizedBox(width: 10),
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
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to the settings screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
