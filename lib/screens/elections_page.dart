import 'package:flutter/material.dart';

import 'election_detail_screen.dart';

class ElectionsPage extends StatelessWidget {
  const ElectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> elections = [
      {"title": "Vadodara City Election", "date": "20 May 2026"},

      {"title": "Ahmedabad Election", "date": "25 May 2026"},

      {"title": "Surat Election", "date": "30 May 2026"},
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),

      child: Column(
        children: [
          /// Dropdown
          Row(
            children: [
              const Text(
                "Select City:",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 10),

              DropdownButton<String>(
                value: "Vadodara",

                items: const [
                  DropdownMenuItem(value: "Vadodara", child: Text("Vadodara")),

                  DropdownMenuItem(
                    value: "Ahmedabad",
                    child: Text("Ahmedabad"),
                  ),

                  DropdownMenuItem(value: "Surat", child: Text("Surat")),
                ],

                onChanged: (value) {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Election List
          Expanded(
            child: ListView.builder(
              itemCount: elections.length,

              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.how_to_vote)),

                    title: Text(
                      elections[index]["title"]!,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text("Date: ${elections[index]["date"]}"),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "Edit") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Edit Clicked")),
                          );
                        }

                        if (value == "Delete") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Delete Clicked")),
                          );
                        }
                      },

                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "Edit", child: Text("Edit")),

                        const PopupMenuItem(
                          value: "Delete",
                          child: Text("delete"),
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
    );
  }
}
