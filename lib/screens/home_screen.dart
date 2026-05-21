import 'package:flutter/material.dart';

import 'elections_page.dart';
import 'results_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool _hideBars = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),

      appBar: _hideBars
          ? null
          : AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: const Color(0xFF1A2980),
              title: const Text(
                "E-Voting System",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

      body: selectedIndex == 0
          ? ElectionsPage(
              onViewChanged: (isSubView) {
                setState(() {
                  _hideBars = isSubView;
                });
              },
            )
          : (selectedIndex == 1 ? const ResultsPage() : const SettingsPage()),

      bottomNavigationBar: _hideBars
          ? null
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF1A2980),
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.how_to_vote),
                  label: "Elections",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: "Results",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            ),
    );
  }
}
