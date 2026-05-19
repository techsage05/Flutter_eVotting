import 'package:flutter/material.dart';

class ElectionDetailScreen extends StatelessWidget {
  final String electionName;

  const ElectionDetailScreen({super.key, required this.electionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Election Details")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.how_to_vote, size: 100),

              const SizedBox(height: 20),

              Text(
                electionName,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Election information page",

                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
