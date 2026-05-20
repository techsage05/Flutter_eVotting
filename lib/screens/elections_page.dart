import 'package:flutter/material.dart';
import 'election_detail_screen.dart';

class ElectionsPage extends StatefulWidget {
  const ElectionsPage({super.key});

  @override
  State<ElectionsPage> createState() => _ElectionsPageState();
}

class _ElectionsPageState extends State<ElectionsPage> {
  // Simple list of elections
  List<Map<String, String>> elections = [
    {"title": "Vadodara City Election", "date": "20 May 2026", "city": "Vadodara"},
    {"title": "Ahmedabad Election", "date": "25 May 2026", "city": "Ahmedabad"},
    {"title": "Surat Election", "date": "30 May 2026", "city": "Surat"},
  ];

  String selectedCity = "Vadodara";

  // Simple controllers for text input fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // Function to show Add dialog
  void showAddDialog() {
    titleController.clear();
    dateController.clear();
    cityController.text = "Vadodara"; // default city

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Election"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Election Title"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date (e.g. 20 May 2026)"),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  elections.add({
                    "title": titleController.text,
                    "date": dateController.text,
                    "city": cityController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Function to show Edit dialog
  void showEditDialog(int index) {
    titleController.text = elections[index]["title"]!;
    dateController.text = elections[index]["date"]!;
    cityController.text = elections[index]["city"] ?? "Vadodara";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Election"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Election Title"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  elections[index] = {
                    "title": titleController.text,
                    "date": dateController.text,
                    "city": cityController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete election
  void deleteElection(int index) {
    setState(() {
      elections.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Simple select city dropdown row
            Row(
              children: [
                const Text(
                  "Select City: ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedCity,
                  items: const [
                    DropdownMenuItem(value: "Vadodara", child: Text("Vadodara")),
                    DropdownMenuItem(value: "Ahmedabad", child: Text("Ahmedabad")),
                    DropdownMenuItem(value: "Surat", child: Text("Surat")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCity = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Elections list view
            Expanded(
              child: ListView.builder(
                itemCount: elections.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.how_to_vote),
                      ),
                      title: Text(
                        elections[index]["title"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Date: ${elections[index]["date"]} | City: ${elections[index]["city"] ?? ''}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showEditDialog(index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteElection(index);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElectionDetailScreen(
                              electionName: elections[index]["title"]!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


