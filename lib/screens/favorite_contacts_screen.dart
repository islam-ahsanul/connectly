import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectly/providers/contacts_provider.dart';
import 'package:connectly/screens/contact_details_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);
    final favoriteContacts = contacts.where((contact) => contact['isFavorite'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoriteContacts.isEmpty
          ? const Center(child: Text('No favorite contacts'))
          : ListView.builder(
              itemCount: favoriteContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailsScreen(contact: favoriteContacts[index]),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(favoriteContacts[index]['profileImageUrl'] ?? 'default_image_url'),
                  ),
                  title: Text(favoriteContacts[index]['name']),
                  subtitle: Text(favoriteContacts[index]['email']),
                );
              },
            ),
    );
  }
}
