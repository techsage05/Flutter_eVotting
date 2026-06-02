import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart';
import 'results_dashboard.dart';

class VoterDashboard extends StatefulWidget {
  const VoterDashboard({super.key});

  @override
  State<VoterDashboard> createState() => _VoterDashboardState();
}

class _VoterDashboardState extends State<VoterDashboard> {
  UserModel? voter;
  List<ElectionModel> elections = [];
  bool isLoading = true;
  String selectedCity = "Vadodara";

  // Voting State Control
  String viewMode = 'dashboard'; // 'dashboard' or 'ballot'
  ElectionModel? activeBallotElection;
  bool isVotingInProgress = false;

  final List<String> cities = ["Vadodara", "Ahmedabad", "Surat"];

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

  // Track which elections this voter has already voted in (for UI optimization)
  Map<String, bool> votedStatusMap = {};

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => isLoading = true);
    await StorageService.initAndSeed();
    voter = await StorageService.getCurrentUser();

    if (voter != null) {
      selectedCity = voter!.city;
    }

    await refreshElections();
    setState(() => isLoading = false);
  }

  Future<void> refreshElections() async {
    final list = await StorageService.getElections();
    final Map<String, bool> statusMap = {};

    if (voter != null) {
      for (var elec in list) {
        final voted = await StorageService.hasVoted(elec.id, voter!.mobile);
        statusMap[elec.id] = voted;
      }
    }

    setState(() {
      elections = list;
      votedStatusMap = statusMap;
    });
  }

  void handleLogout() async {
    await StorageService.setCurrentUser(null);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  // ── BALLOT NAVIGATION ──────────────────────────────────────────────────────
  void openBallot(ElectionModel election) {
    setState(() {
      activeBallotElection = election;
      viewMode = 'ballot';
    });
  }

  void closeBallot() {
    setState(() {
      activeBallotElection = null;
      viewMode = 'dashboard';
    });
    refreshElections();
  }

  // ── CAST VOTE ──────────────────────────────────────────────────────────────
  void handleCastVote(PartyModel party) {
    if (activeBallotElection == null || voter == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: const Color(0xFF1A2980).withOpacity(0.8)),
              const SizedBox(width: 8),
              const Text(
                "Confirm Your Vote",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Are you sure you want to cast your vote for:"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2980).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1A2980).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      getSymbolIcon(party.symbolName),
                      color: getSymbolColor(party.symbolName),
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            party.candidateName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            party.name,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Warning: This action is permanent and cannot be undone. To preserve your privacy, your identity is saved separately from your selection.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close confirm dialog
                await executeVote(party);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2980),
                foregroundColor: Colors.white,
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> executeVote(PartyModel party) async {
    setState(() => isVotingInProgress = true);

    // Cast vote securely (anonymous split mechanism)
    await StorageService.castVote(
      activeBallotElection!.id,
      voter!.mobile,
      party.name,
    );

    // Simulate a brief secure transaction delay (700ms)
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() => isVotingInProgress = false);

    // Show beautiful success overlay
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Vote Registered!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2980),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your cryptographic vote has been cast anonymously. Thank you for making your voice heard!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close success dialog
                      closeBallot();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2980),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("BACK TO PORTAL"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  String getElectionStatus(ElectionModel election) {
    final now = DateTime.now();
    if (now.isBefore(election.listingTime)) {
      return "Hidden";
    } else if (now.isBefore(election.startTime)) {
      return "Upcoming";
    } else if (now.isBefore(election.endTime)) {
      return "Active (Voting Open)";
    } else {
      return "Completed (Results Out)";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Upcoming":
        return Colors.blue;
      case "Active (Voting Open)":
        return Colors.green;
      case "Completed (Results Out)":
        return Colors.grey.shade700;
      default:
        return Colors.orange;
    }
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

  String formatAadhar(String rawAadhar) {
    if (rawAadhar.length != 12) return rawAadhar;
    return "XXXX-XXXX-${rawAadhar.substring(8)}";
  }

  String formatDateString(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} at "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  // ── MAIN BUILD ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xFF1A2980),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "E-Voting Portal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Secure Democratic Platform",
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: handleLogout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (viewMode == 'dashboard'
                ? buildVoterDashboard()
                : buildBallotView()),
    );
  }

  // ── VOTER DASHBOARD ────────────────────────────────────────────────────────
  Widget buildVoterDashboard() {
    // Filter elections based on selectedCity AND listingTime check
    final now = DateTime.now();
    final filteredElections = elections.where((elec) {
      final matchesCity = elec.city.toLowerCase() == selectedCity.toLowerCase();
      final isListed = now.isAfter(elec.listingTime);
      return matchesCity && isListed;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voter Profile Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      voter?.name ?? 'Registered Voter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Icon(
                      Icons.verified_user,
                      color: Colors.tealAccent,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge, color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      "Voter ID: ${voter?.voterId ?? 'N/A'}",
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.credit_card,
                      color: Colors.white70,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Aadhar: ${voter != null ? formatAadhar(voter!.aadharNumber) : 'N/A'}",
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Registered City: ${voter?.city ?? 'N/A'}",
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // City selector card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city, color: Color(0xFF1A2980)),
                  const SizedBox(width: 12),
                  const Text(
                    "Select Voting Jurisdiction: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCity,
                        style: const TextStyle(
                          color: Color(0xFF1A2980),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        items: cities
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCity = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "Elections in $selectedCity",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2980),
            ),
          ),
          const SizedBox(height: 10),

          // Elections List
          Expanded(
            child: filteredElections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No elections active or scheduled in this city.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshElections,
                    child: ListView.builder(
                      itemCount: filteredElections.length,
                      itemBuilder: (context, index) {
                        final elec = filteredElections[index];
                        final status = getElectionStatus(elec);
                        final col = getStatusColor(status);
                        final bool hasVotedInThis =
                            votedStatusMap[elec.id] ?? false;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        elec.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1A2980),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hasVotedInThis
                                            ? Colors.teal.shade50
                                            : col.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        hasVotedInThis ? "Voted ✓" : status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: hasVotedInThis
                                              ? Colors.teal.shade800
                                              : col,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Timelines
                                if (status == 'Upcoming') ...[
                                  Text(
                                    "Voting opens: ${formatDateString(elec.startTime)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ] else if (status ==
                                    'Active (Voting Open)') ...[
                                  Text(
                                    "Voting closes: ${formatDateString(elec.endTime)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    "Closed: ${formatDateString(elec.endTime)}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),

                                // Action Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${elec.parties.length} Contesting Candidates",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Button decision
                                    if (status == 'Upcoming') ...[
                                      ElevatedButton(
                                        onPressed: () =>
                                            showCandidatesManifesto(elec),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade100,
                                          foregroundColor: Colors.black87,
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          "View Manifesto",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ] else if (status ==
                                        'Active (Voting Open)') ...[
                                      if (hasVotedInThis) ...[
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              showCandidatesManifesto(elec),
                                          icon: const Icon(
                                            Icons.verified,
                                            size: 14,
                                          ),
                                          label: const Text(
                                            "My Ballot",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.teal.shade700,
                                            side: BorderSide(
                                              color: Colors.teal.shade200,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        ElevatedButton(
                                          onPressed: () => openBallot(elec),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1A2980,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 3,
                                          ),
                                          child: const Text(
                                            "Cast Vote",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ] else ...[
                                      // Completed
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ResultsDashboard(
                                                    electionId: elec.id,
                                                    electionTitle: elec.title,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.bar_chart,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "View Results",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF26D0CE,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── MANIFESTO PREVIEW DIALOG ────────────────────────────────────────────────
  void showCandidatesManifesto(ElectionModel election) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                election.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A2980),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Contesting Parties and Manifestos:",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: election.parties.length,
                  itemBuilder: (context, idx) {
                    final p = election.parties[idx];
                    return Card(
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          getSymbolIcon(p.symbolName),
                          color: getSymbolColor(p.symbolName),
                          size: 30,
                        ),
                        title: Text(
                          "${p.candidateName} (${p.name})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          p.details.isEmpty ? "No details provided" : p.details,
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── BALLOT VIEW ────────────────────────────────────────────────────────────
  Widget buildBallotView() {
    if (activeBallotElection == null) return const SizedBox();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1A2980),
                    ),
                    onPressed: closeBallot,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeBallotElection!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2980),
                          ),
                        ),
                        const Text(
                          "Cast Ballot - Choose One Candidate",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: activeBallotElection!.parties.length,
                  itemBuilder: (context, index) {
                    final p = activeBallotElection!.parties[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    getSymbolIcon(p.symbolName),
                                    color: getSymbolColor(p.symbolName),
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.candidateName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1A2980),
                                        ),
                                      ),
                                      Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            const Text(
                              "Candidate Manifesto:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.details.isEmpty
                                  ? "No details/manifesto provided by this candidate."
                                  : p.details,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton.icon(
                                onPressed: () => handleCastVote(p),
                                icon: const Icon(Icons.how_to_vote, size: 16),
                                label: const Text(
                                  "VOTE FOR CANDIDATE",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A2980),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Secure transaction progress spinner
        if (isVotingInProgress)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1A2980),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Recording Secure Vote...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2980),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Encrypting transaction securely...",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
