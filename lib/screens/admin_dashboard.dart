import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<ElectionModel> elections = [];
  bool isLoading = true;
  UserModel? adminUser;

  // View control: 'list' or 'form'
  String viewMode = 'list';
  ElectionModel? editingElection; // null if adding new election

  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  
  DateTime? listingTime;
  DateTime? startTime;
  DateTime? endTime;
  
  List<PartyModel> tempParties = [];

  // Candidate Dialog Controllers
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController candidateNameController = TextEditingController();
  final TextEditingController candidateDetailsController = TextEditingController();
  String selectedSymbol = 'lotus';

  final List<Map<String, dynamic>> symbolOptions = [
    {'id': 'lotus', 'name': 'Lotus', 'icon': Icons.brightness_high, 'color': Colors.orange},
    {'id': 'hand', 'name': 'Hand', 'icon': Icons.front_hand, 'color': Colors.blue},
    {'id': 'broom', 'name': 'Broom', 'icon': Icons.cleaning_services, 'color': Colors.brown},
    {'id': 'elephant', 'name': 'Elephant', 'icon': Icons.cruelty_free, 'color': Colors.blueGrey},
    {'id': 'cycle', 'name': 'Bicycle', 'icon': Icons.directions_bike, 'color': Colors.green},
    {'id': 'star', 'name': 'Star', 'icon': Icons.star, 'color': Colors.yellow.shade700},
  ];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => isLoading = true);
    await StorageService.initAndSeed();
    adminUser = await StorageService.getCurrentUser();
    elections = await StorageService.getElections();
    setState(() => isLoading = false);
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

  // ── FORM SWITCHING ─────────────────────────────────────────────────────────
  void openForm({ElectionModel? election}) {
    setState(() {
      editingElection = election;
      if (election != null) {
        titleController.text = election.title;
        cityController.text = election.city;
        listingTime = election.listingTime;
        startTime = election.startTime;
        endTime = election.endTime;
        tempParties = List.from(election.parties);
      } else {
        titleController.clear();
        cityController.clear();
        
        final now = DateTime.now();
        listingTime = now.subtract(const Duration(minutes: 1)); // Listed immediately by default
        startTime = now.add(const Duration(hours: 1));
        endTime = now.add(const Duration(days: 1));
        tempParties = [];
      }
      viewMode = 'form';
    });
  }

  void closeForm() {
    setState(() {
      viewMode = 'list';
      editingElection = null;
    });
  }

  // ── DATE/TIME PICKERS ──────────────────────────────────────────────────────
  Future<void> pickDateTime(String field) async {
    final now = DateTime.now();
    DateTime initialDate = now;
    if (field == 'listing' && listingTime != null) initialDate = listingTime!;
    if (field == 'start' && startTime != null) initialDate = startTime!;
    if (field == 'end' && endTime != null) initialDate = endTime!;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (field == 'listing') listingTime = combined;
          if (field == 'start') startTime = combined;
          if (field == 'end') endTime = combined;
        });
      }
    }
  }

  // ── CANDIDATE DIALOG ───────────────────────────────────────────────────────
  void showCandidateDialog({int? index}) {
    if (index != null) {
      final p = tempParties[index];
      partyNameController.text = p.name;
      candidateNameController.text = p.candidateName;
      candidateDetailsController.text = p.details;
      selectedSymbol = p.symbolName;
    } else {
      partyNameController.clear();
      candidateNameController.clear();
      candidateDetailsController.clear();
      selectedSymbol = 'lotus';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                index == null ? "Add Party & Candidate" : "Edit Party & Candidate",
                style: const TextStyle(color: Color(0xFF1A2980), fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: partyNameController,
                      decoration: const InputDecoration(labelText: "Party Name (e.g. BJP, Congress)"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: candidateNameController,
                      decoration: const InputDecoration(labelText: "Candidate Name"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: candidateDetailsController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "Candidate Manifesto/Details"),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Select Party Symbol:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: symbolOptions.map((option) {
                        final bool isSel = selectedSymbol == option['id'];
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedSymbol = option['id'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF1A2980) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isSel ? const Color(0xFF1A2980) : Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(option['icon'], size: 16, color: isSel ? Colors.white : option['color']),
                                const SizedBox(width: 4),
                                Text(
                                  option['name'],
                                  style: TextStyle(color: isSel ? Colors.white : Colors.black87, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final party = partyNameController.text.trim();
                    final cand = candidateNameController.text.trim();
                    final details = candidateDetailsController.text.trim();

                    if (party.isEmpty || cand.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill in Party and Candidate names")),
                      );
                      return;
                    }

                    final newParty = PartyModel(
                      name: party,
                      candidateName: cand,
                      symbolName: selectedSymbol,
                      details: details,
                    );

                    setState(() {
                      if (index == null) {
                        tempParties.add(newParty);
                      } else {
                        tempParties[index] = newParty;
                      }
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2980), foregroundColor: Colors.white),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── SAVE / UPDATE ELECTION ────────────────────────────────────────────────
  void handleSaveElection() async {
    final title = titleController.text.trim();
    final city = cityController.text.trim();

    if (title.isEmpty || city.isEmpty) {
      showSnackBar("Please fill in the title and city fields", Colors.redAccent);
      return;
    }
    if (listingTime == null || startTime == null || endTime == null) {
      showSnackBar("Please select listing, start, and end times", Colors.redAccent);
      return;
    }
    if (startTime!.isBefore(listingTime!)) {
      showSnackBar("Start time cannot be before listing time", Colors.redAccent);
      return;
    }
    if (endTime!.isBefore(startTime!)) {
      showSnackBar("Result/End time cannot be before start time", Colors.redAccent);
      return;
    }
    if (tempParties.isEmpty) {
      showSnackBar("Please add at least one candidate party", Colors.redAccent);
      return;
    }

    if (editingElection == null) {
      // Add New Election
      final newElec = ElectionModel(
        id: "elec_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        city: city,
        listingTime: listingTime!,
        startTime: startTime!,
        endTime: endTime!,
        parties: tempParties,
      );
      await StorageService.addElection(newElec);
      showSnackBar("Election '$title' added successfully!", Colors.green);
    } else {
      // Update Existing Election
      final updatedElec = ElectionModel(
        id: editingElection!.id,
        title: title,
        city: city,
        listingTime: listingTime!,
        startTime: startTime!,
        endTime: endTime!,
        parties: tempParties,
      );
      await StorageService.updateElection(updatedElec);
      showSnackBar("Election '$title' updated successfully!", Colors.green);
    }

    closeForm();
    loadDashboardData();
  }

  // ── DELETE WITH UNDO ───────────────────────────────────────────────────────
  void handleDeleteElection(ElectionModel election) async {
    final int deletedIndex = elections.indexOf(election);
    
    // Save locally
    setState(() {
      elections.remove(election);
    });
    await StorageService.deleteElection(election.id);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deleted '${election.title}'"),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "Undo",
            textColor: Colors.tealAccent,
            onPressed: () async {
              setState(() {
                elections.insert(deletedIndex, election);
              });
              await StorageService.addElection(election);
              loadDashboardData();
            },
          ),
        ),
      );
    }
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  String getElectionStatus(ElectionModel election) {
    final now = DateTime.now();
    if (now.isBefore(election.listingTime)) {
      return "Hidden (Draft)";
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

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  IconData getSymbolIcon(String symName) {
    final opt = symbolOptions.firstWhere((o) => o['id'] == symName, orElse: () => symbolOptions.first);
    return opt['icon'] as IconData;
  }

  Color getSymbolColor(String symName) {
    final opt = symbolOptions.firstWhere((o) => o['id'] == symName, orElse: () => symbolOptions.first);
    return opt['color'] as Color;
  }

  // ── BUILD DASHBOARD ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xFF1A2980),
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("E-Voting Portal Administrator", style: TextStyle(color: Colors.white70, fontSize: 11)),
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
          : (viewMode == 'list' ? buildElectionList() : buildElectionForm()),
      floatingActionButton: viewMode == 'list'
          ? FloatingActionButton.extended(
              onPressed: () => openForm(),
              backgroundColor: const Color(0xFF1A2980),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text("New Election"),
            )
          : null,
    );
  }

  // ── LIST VIEW ──────────────────────────────────────────────────────────────
  Widget buildElectionList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome admin info
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${adminUser?.name ?? 'Admin'}!",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Create and manage city elections, customize timelines, add competing parties, and observe final results.",
                  style: TextStyle(color: Colors.white85, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            "Configured Elections",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2980)),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: elections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.ballot_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text("No elections found.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => openForm(),
                          child: const Text("Create one now", style: TextStyle(color: Color(0xFF26D0CE), fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      final elec = elections[index];
                      final status = getElectionStatus(elec);
                      final col = getStatusColor(status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.white,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: col.withOpacity(0.1),
                            child: Icon(Icons.how_to_vote, color: col),
                          ),
                          title: Text(
                            elec.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.location_on, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(elec.city, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(status, style: TextStyle(fontSize: 10, color: col, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  buildTimeRow("Listing Time", elec.listingTime),
                                  buildTimeRow("Voting Starts", elec.startTime),
                                  buildTimeRow("Voting Ends (Results)", elec.endTime),
                                  const SizedBox(height: 12),
                                  
                                  const Text("Candidates & Parties:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: elec.parties.map((p) {
                                      return Chip(
                                        avatar: Icon(getSymbolIcon(p.symbolName), size: 14, color: getSymbolColor(p.symbolName)),
                                        label: Text("${p.candidateName} (${p.name})", style: const TextStyle(fontSize: 11)),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: Colors.grey.shade50,
                                      );
                                    }).toList(),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => openForm(election: elec),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text("Edit Details"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                          side: const BorderSide(color: Colors.blue),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () => handleDeleteElection(elec),
                                        icon: const Icon(Icons.delete, size: 16),
                                        label: const Text("Delete"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeRow(String label, DateTime dt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54)),
          Text(
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} at "
            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ── FORM VIEW ──────────────────────────────────────────────────────────────
  Widget buildElectionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2980)),
                onPressed: closeForm,
              ),
              Text(
                editingElection == null ? "Create New Election" : "Edit Election Details",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2980)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Election Title",
                      hintText: "e.g., Vadodara Municipal Election 2026",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "Applicable City",
                      hintText: "e.g., Vadodara",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TIMINGS CARD
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Election Timelines", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2980))),
                  const SizedBox(height: 12),
                  buildTimePickerRow("Listing Time (Visible to Voters)", listingTime, 'listing'),
                  const Divider(height: 20),
                  buildTimePickerRow("Voting Start Time (Ballots Open)", startTime, 'start'),
                  const Divider(height: 20),
                  buildTimePickerRow("Voting End/Result Time (Ballots Close)", endTime, 'end'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // PARTIES / CANDIDATES CARD
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text("Candidates & Parties", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2980))),
                      TextButton.icon(
                        onPressed: () => showCandidateDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add Candidate"),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF26D0CE)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  tempParties.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              "No candidates added yet. Please add at least one.",
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tempParties.length,
                          itemBuilder: (context, index) {
                            final p = tempParties[index];
                            return ListTile(
                              leading: Icon(getSymbolIcon(p.symbolName), color: getSymbolColor(p.symbolName), size: 28),
                              title: Text("${p.candidateName} (${p.name})"),
                              subtitle: Text(
                                p.details.isEmpty ? "No manifesto listed" : p.details,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                    onPressed: () => showCandidateDialog(index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        tempParties.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: closeForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("CANCEL"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: handleSaveElection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2980),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 3,
                  ),
                  child: Text(editingElection == null ? "CREATE ELECTION" : "SAVE CHANGES"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget buildTimePickerRow(String label, DateTime? value, String type) {
    String dtText = "Not Selected";
    if (value != null) {
      dtText = "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} at "
          "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(dtText, style: TextStyle(color: value == null ? Colors.redAccent : Colors.black54, fontSize: 12)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => pickDateTime(type),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A2980).withOpacity(0.08),
            foregroundColor: const Color(0xFF1A2980),
            elevation: 0,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text("Select"),
        ),
      ],
    );
  }
}
