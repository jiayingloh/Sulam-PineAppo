import 'package:flutter/material.dart';
import 'ui/register.dart'; // Import your register screen

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(), // Use your register screen here
    );
  }
}
