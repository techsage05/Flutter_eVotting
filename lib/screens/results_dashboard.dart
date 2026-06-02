import 'package:flutter/material.dart';
import '../models/election_model.dart';
import '../services/storage_service.dart';

class ResultsDashboard extends StatefulWidget {
  final String electionId;
  final String electionTitle;

  const ResultsDashboard({
    super.key,
    required this.electionId,
    required this.electionTitle,
  });

  @override
  State<ResultsDashboard> createState() => _ResultsDashboardState();
}

class _ResultsDashboardState extends State<ResultsDashboard> {
  bool isLoading = true;
  ElectionModel? election;
  Map<String, int> voteCounts = {};
  int totalVotes = 0;

  PartyModel? winnerParty;
  int winnerVotes = 0;
  int margin = 0;
  List<Map<String, dynamic>> standingList = [];

  final List<Map<String, dynamic>> symbolOptions = [
    {
      'id': 'lotus',
      'name': 'Lotus',
      'icon': Icons.brightness_high,
      'color': Colors.orange,
    },
    {
      'id': 'hand',
      'name': 'Hand',
      'icon': Icons.front_hand,
      'color': Colors.blue,
    },
    {
      'id': 'broom',
      'name': 'Broom',
      'icon': Icons.cleaning_services,
      'color': Colors.brown,
    },
    {
      'id': 'elephant',
      'name': 'Elephant',
      'icon': Icons.cruelty_free,
      'color': Colors.blueGrey,
    },
    {
      'id': 'cycle',
      'name': 'Bicycle',
      'icon': Icons.directions_bike,
      'color': Colors.green,
    },
    {
      'id': 'star',
      'name': 'Star',
      'icon': Icons.star,
      'color': Colors.yellow.shade700,
    },
  ];

  @override
  void initState() {
    super.initState();
    calculateResults();
  }

  Future<void> calculateResults() async {
    setState(() => isLoading = true);

    final elections = await StorageService.getElections();
    try {
      election = elections.firstWhere((e) => e.id == widget.electionId);
    } catch (_) {
      election = null;
    }

    if (election != null) {
      voteCounts = await StorageService.getVotesForElection(widget.electionId);
      totalVotes = voteCounts.values.fold(0, (sum, val) => sum + val);

      final List<Map<String, dynamic>> standings = [];
      for (var party in election!.parties) {
        final count = voteCounts[party.name] ?? 0;
        standings.add({
          'party': party,
          'votes': count,
          'percentage': totalVotes > 0 ? (count / totalVotes) * 100 : 0.0,
        });
      }

      standings.sort(
        (a, b) => (b['votes'] as int).compareTo(a['votes'] as int),
      );
      standingList = standings;

      if (totalVotes > 0 && standings.isNotEmpty) {
        winnerParty = standings[0]['party'] as PartyModel;
        winnerVotes = standings[0]['votes'] as int;

        if (standings.length > 1) {
          final runnerUpVotes = standings[1]['votes'] as int;
          margin = winnerVotes - runnerUpVotes;
        } else {
          margin = winnerVotes;
        }
      }
    }

    setState(() => isLoading = false);
  }

  IconData getSymbolIcon(String symName) {
    final opt = symbolOptions.firstWhere(
      (o) => o['id'] == symName,
      orElse: () => symbolOptions.first,
    );
    return opt['icon'] as IconData;
  }

  Color getSymbolColor(String symName) {
    final opt = symbolOptions.firstWhere(
      (o) => o['id'] == symName,
      orElse: () => symbolOptions.first,
    );
    return opt['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A2980),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Election Results",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (election == null ? buildErrorView() : buildResultsView()),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          const Text(
            "Failed to load results. Election not found.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Election title header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  election!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2980),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      election!.city,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$totalVotes total votes cast",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // WINNER CARD
          if (totalVotes > 0 && winnerParty != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2980).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "OFFICIAL WINNER",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    winnerParty!.candidateName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    winnerParty!.name,
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      margin > 0
                          ? "Won by a margin of $margin ${margin == 1 ? 'vote' : 'votes'}!"
                          : "Won unopposed with $winnerVotes votes!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "No ballots recorded",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Voting ended, but no voter participated in this election.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // VOTE SHARE / DETAILED STANDINGS
          const Text(
            "Vote Share Standings",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2980),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: standingList.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final item = standingList[index];
                  final PartyModel p = item['party'] as PartyModel;
                  final int votes = item['votes'] as int;
                  final double percentage = item['percentage'] as double;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            getSymbolIcon(p.symbolName),
                            color: getSymbolColor(p.symbolName),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.candidateName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1A2980),
                                  ),
                                ),
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "$votes ${votes == 1 ? 'vote' : 'votes'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${percentage.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0 ? (votes / totalVotes) : 0.0,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            index == 0 && totalVotes > 0
                                ? const Color(0xFF1A2980)
                                : const Color(0xFF26D0CE),
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PRIVACY ASSURANCE BLOCK
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50.withOpacity(0.4),
              border: Border.all(color: Colors.teal.shade100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Colors.teal.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Absolute Confidentiality Assured",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "This platform separates voter registration logs from the ballot repository. "
                        "Because individual votes are stored anonymously without any linking tokens, "
                        "it is mathematically impossible for administrators or external entities to trace who voted for whom.",
                        style: TextStyle(
                          color: Colors.teal.shade800,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
