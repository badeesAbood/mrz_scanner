import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('MRZ SC NFC Core Example')),
        body: const Center(child: Text('NFC Reader Extension Package')),
      ),
    );
  }
}
