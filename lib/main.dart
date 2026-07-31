import 'package:flutter/material.dart';

void main() {
  runApp(const ScopifyApp());
}

class ScopifyApp extends StatelessWidget {
  const ScopifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scopify',
      home: Scaffold(body: Center(child: Text('Scopify'))),
    );
  }
}
