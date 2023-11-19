import 'package:flutter/material.dart';
import 'package:connectly/views/screens/AuthScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectly',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 177, 17, 164),
          background: Colors.white,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
