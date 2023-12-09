import 'package:flutter/material.dart';

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({Key? key}) : super(key: key);

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _searchUsers(value);
            },
            decoration: InputDecoration(
              labelText: 'Email or Phone Number',
              suffixIcon: _searchQuery.isNotEmpty ? Icon(Icons.search) : null,
            ),
          ),
        ),
      ),
    );
  }

  void _searchUsers(String query) {
    // TODO: Implement search functionality
  }
}
