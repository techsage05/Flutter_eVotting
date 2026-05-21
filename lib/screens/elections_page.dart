import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fragment_placeholder.dart';
import 'election_detail_screen.dart';

class ElectionsPage extends StatefulWidget {
  // Callback function to notify HomeScreen to hide/show the top AppBar and bottom navigation bar
  final Function(bool isSubView)? onViewChanged;

  const ElectionsPage({super.key, this.onViewChanged});

  @override
  State<ElectionsPage> createState() => _ElectionsPageState();
}

class _ElectionsPageState extends State<ElectionsPage> {
  // The list of elections that we will display and persist
  List<Map<String, String>> elections = [];
  bool isLoading = true;
  String selectedCity = "Vadodara";

  // Simple string to track current screen: 'list', 'details', 'add', 'edit'
  String currentView = 'list';
  
  // Track which election is being edited
  int editingIndex = 0;
  
  // Track which election details we are viewing
  String selectedDetailName = "";

  // Controllers for the input fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the saved election data when the screen starts
    loadElectionsFromStorage();
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is destroyed
    titleController.dispose();
    dateController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // ── LOAD DATA ──────────────────────────────────────────────────────────────
  // Load election list from SharedPreferences
  Future<void> loadElectionsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('elections_data');

    if (jsonString != null) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonString);
        List<Map<String, String>> loadedList = [];
        
        // Loop through and convert items back to Map<String, String>
        for (var item in jsonList) {
          loadedList.add({
            "title": item["title"].toString(),
            "date": item["date"].toString(),
            "city": item["city"].toString(),
          });
        }

        setState(() {
          elections = loadedList;
          isLoading = false;
        });
        return;
      } catch (e) {
        // If parsing fails, fall through to default list
      }
    }

    // Set default elections if there is no data in storage yet
    setState(() {
      elections = [
        {"title": "Vadodara City Election", "date": "20 May 2026", "city": "Vadodara"},
        {"title": "Ahmedabad Election", "date": "25 May 2026", "city": "Ahmedabad"},
        {"title": "Surat Election", "date": "30 May 2026", "city": "Surat"},
      ];
      isLoading = false;
    });
    
    // Save defaults to storage
    saveElectionsToStorage();
  }

  // ── SAVE DATA ──────────────────────────────────────────────────────────────
  // Save the current election list to SharedPreferences
  Future<void> saveElectionsToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(elections);
    await prefs.setString('elections_data', jsonString);
  }

  // ── NAVIGATION CONTROLLER ──────────────────────────────────────────────────
  // Switch between views and tell HomeScreen to hide/show its bars
  void changeView(String newView) {
    setState(() {
      currentView = newView;
    });
    
    // If it's anything other than the main list, hide the home screen bars
    if (widget.onViewChanged != null) {
      widget.onViewChanged!(newView != 'list');
    }
  }

  // ── ADD ACTION ─────────────────────────────────────────────────────────────
  void addNewElection() {
    String title = titleController.text.trim();
    String date = dateController.text.trim();
    String city = cityController.text.trim();

    if (title.isEmpty || date.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() {
      elections.add({
        "title": title,
        "date": date,
        "city": city,
      });
    });

    saveElectionsToStorage();
    changeView('list');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Election '$title' added successfully!")),
    );
  }

  // ── EDIT ACTION ────────────────────────────────────────────────────────────
  void updateElectionDetails() {
    String title = titleController.text.trim();
    String date = dateController.text.trim();
    String city = cityController.text.trim();

    if (title.isEmpty || date.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() {
      elections[editingIndex] = {
        "title": title,
        "date": date,
        "city": city,
      };
    });

    saveElectionsToStorage();
    changeView('list');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Election updated successfully!")),
    );
  }

  // ── DELETE ACTION ──────────────────────────────────────────────────────────
  void deleteElection(int index) {
    // Keep a copy of the deleted election in case user wants to Undo
    final deletedItem = elections[index];

    setState(() {
      elections.removeAt(index);
    });
    saveElectionsToStorage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted '${deletedItem["title"]}'"),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              elections.insert(index, deletedItem);
            });
            saveElectionsToStorage();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while reading from SharedPreferences
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A2980)),
        ),
      );
    }

    // Determine which fragment widget should be displayed
    Widget activeWidget;
    
    if (currentView == 'add') {
      activeWidget = buildAddView();
    } else if (currentView == 'edit') {
      activeWidget = buildEditView();
    } else if (currentView == 'details') {
      activeWidget = ElectionDetailScreen(
        electionName: selectedDetailName,
        onBack: () {
          changeView('list');
        },
      );
    } else {
      // Default to list view
      activeWidget = buildListView();
    }

    // Intercept physical android back button to go back to the main list
    return PopScope(
      canPop: currentView == 'list',
      onPopInvoked: (didPop) {
        if (didPop) return;
        changeView('list');
      },
      child: FragmentPlaceholder(
        child: activeWidget,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── BUILD LIST VIEW ──────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget buildListView() {
    // Filter the list based on the dropdown selected city
    List<Map<String, String>> filteredList = [];
    for (var item in elections) {
      if ((item["city"] ?? "Vadodara").toLowerCase() == selectedCity.toLowerCase()) {
        filteredList.add(item);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Dropdown card selector
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, color: Color(0xFF1A2980)),
                    const SizedBox(width: 12),
                    const Text(
                      "Select City: ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCity,
                          style: const TextStyle(
                            color: Color(0xFF1A2980),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Main List
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text(
                        "No elections found for this city.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final int realIndex = elections.indexOf(item);

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.how_to_vote),
                            ),
                            title: Text(
                              item["title"]!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Date: ${item["date"]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Populate inputs with current values
                                    titleController.text = item["title"]!;
                                    dateController.text = item["date"]!;
                                    cityController.text = item["city"] ?? "Vadodara";
                                    
                                    editingIndex = realIndex;
                                    changeView('edit');
                                  },
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteElection(realIndex);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              selectedDetailName = item["title"]!;
                              changeView('details');
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
        backgroundColor: const Color(0xFF1A2980),
        foregroundColor: Colors.white,
        onPressed: () {
          // Clear inputs before opening add screen
          titleController.clear();
          dateController.clear();
          cityController.text = selectedCity;
          
          changeView('add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── BUILD ADD VIEW ───────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget buildAddView() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A2980),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => changeView('list'),
        ),
        title: const Text(
          "Add New Election",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Election Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date (e.g. 20 May 2026)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "City"),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => changeView('list'),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: addNewElection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2980),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ── BUILD EDIT VIEW ──────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  Widget buildEditView() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A2980),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => changeView('list'),
        ),
        title: const Text(
          "Edit Election",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Election Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "City"),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => changeView('list'),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: updateElectionDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2980),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
