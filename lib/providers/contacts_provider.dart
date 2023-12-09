import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, List<Map<String, dynamic>>>((ref) {
  return ContactsNotifier();
});

class ContactsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ContactsNotifier() : super([]);

  void loadContacts(List<Map<String, dynamic>> contacts) {
    state = contacts;
  }

  Future<void> fetchContacts() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    var contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts');

    var querySnapshot = await contactsCollection.get();
    loadContacts(querySnapshot.docs.map((doc) => doc.data()).toList());
  }

  void toggleFavorite(String email) {
    state = [
      for (final contact in state)
        if (contact['email'] == email)
          {...contact, 'isFavorite': !(contact['isFavorite'] ?? false)}
        else
          contact
    ];
  }
}
