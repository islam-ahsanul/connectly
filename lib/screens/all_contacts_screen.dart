import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/widgets/contact_search.dart';
import 'package:connectly/screens/contact_details_screen.dart';
import 'package:connectly/providers/contacts_provider.dart'; // Adjust the import based on your project structure

class AllContactsScreen extends ConsumerWidget {
  const AllContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(contactsProvider.notifier).fetchContacts();
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Contacts'),
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
}
