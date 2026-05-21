import 'package:flutter/material.dart';

class ElectionDetailScreen extends StatelessWidget {
  final String electionName;
  final VoidCallback? onBack;

  const ElectionDetailScreen({
    super.key,
    required this.electionName,
    this.onBack,
  });

  void _goBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF1A2980),

        // ── Back Button ──────────────────────────────────────────────────────
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          tooltip: 'Go back',
          onPressed: () => _goBack(context),
        ),

        title: const Text(
          "Election Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // ── Icon ──────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2980).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_vote,
                  size: 90,
                  color: Color(0xFF1A2980),
                ),
              ),

              const SizedBox(height: 24),

              // ── Election Name ─────────────────────────────────────────────
              Text(
                electionName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2980),
                ),
              ),

              const SizedBox(height: 12),

              // ── Sub-text ──────────────────────────────────────────────────
              const Text(
                "Election information page",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 36),

              // ── Back Button (in body too for clarity) ─────────────────────
              OutlinedButton.icon(
                onPressed: () => _goBack(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Go Back"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A2980),
                  side: const BorderSide(color: Color(0xFF1A2980)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
