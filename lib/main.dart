import 'package:flutter/material.dart';

import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ProfileHeader(name: myName, university: myUniversity),
              const SizedBox(height: 24),
              for (final f in facts) InfoRow(label: f.label, value: f.value),
            ],
          ),
        ),
      ),
    );
  }
}
