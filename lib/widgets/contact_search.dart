import 'package:flutter/material.dart';

class ContactSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> contacts;

  ContactSearchDelegate(this.contacts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // You can implement a more advanced search logic here
    var results = contacts.where((contact) {
      return contact['name'].toLowerCase().contains(query.toLowerCase()) ||
          contact['email'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]['name']),
          subtitle: Text(results[index]['email']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions based on the search query
    return buildResults(context);
  }
}
