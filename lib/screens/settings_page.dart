import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(leading: Icon(Icons.person), title: Text("Profile")),

        ListTile(leading: Icon(Icons.lock), title: Text("Privacy")),

        ListTile(leading: Icon(Icons.info), title: Text("About App")),
      ],
    );
  }
}
