import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/election_model.dart';

class StorageService {
  static const String _usersKey = 'evotting_users';
  static const String _electionsKey = 'evotting_elections';
  static const String _sessionKey = 'evotting_current_user';
  static const String _votersListKey = 'evotting_voted_voters'; // Format: "electionId_voterMobile"
  static const String _votesListKey = 'evotting_anonymous_votes'; // Format: "electionId_partyName"

  // Initialize and Seed Mock Data if empty
  static Future<void> initAndSeed() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Seed Users if none exist
    if (!prefs.containsKey(_usersKey)) {
      final defaultUsers = [
        UserModel(
          name: "Admin Hitesh",
          mobile: "9999999999",
          voterId: "ADM1234567",
          aadharNumber: "123456789012",
          city: "Vadodara",
          role: "admin",
        ),
        UserModel(
          name: "Voter Hitesh",
          mobile: "8888888888",
          voterId: "VOT1234567",
          aadharNumber: "987654321098",
          city: "Vadodara",
          role: "voter",
        ),
        UserModel(
          name: "Ahmedabad Voter",
          mobile: "7777777777",
          voterId: "VOT7777777",
          aadharNumber: "777777777777",
          city: "Ahmedabad",
          role: "voter",
        ),
      ];
      await saveUsers(defaultUsers);
    }

    // 2. Seed Elections if none exist
    if (!prefs.containsKey(_electionsKey)) {
      final now = DateTime.now();
      final defaultElections = [
        // Active Election in Vadodara (Listed yesterday, started 2 hours ago, ends tomorrow)
        ElectionModel(
          id: "elec_vadodara_active",
          title: "Vadodara Municipal Corporation Election",
          city: "Vadodara",
          listingTime: now.subtract(const Duration(days: 1)),
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.add(const Duration(days: 1)),
          parties: [
            PartyModel(
              name: "Bharatiya Janata Party",
              candidateName: "Rajesh Patel",
              symbolName: "lotus",
              details: "Focusing on smart city infrastructure, clean water supply, and digital governance for Vadodara.",
            ),
            PartyModel(
              name: "Indian National Congress",
              candidateName: "Suresh Sharma",
              symbolName: "hand",
              details: "Prioritizing affordable healthcare, improving municipal schools, and expanding public parks.",
            ),
            PartyModel(
              name: "Aam Aadmi Party",
              candidateName: "Amit Verma",
              symbolName: "broom",
              details: "Advocating for free primary health clinics, zero-bill solar electricity initiatives, and corruption-free local governance.",
            ),
          ],
        ),
        // Upcoming Election in Ahmedabad (Listed yesterday, starts tomorrow, ends in 3 days)
        ElectionModel(
          id: "elec_ahmedabad_upcoming",
          title: "Ahmedabad North Assembly Election",
          city: "Ahmedabad",
          listingTime: now.subtract(const Duration(days: 1)),
          startTime: now.add(const Duration(days: 1)),
          endTime: now.add(const Duration(days: 3)),
          parties: [
            PartyModel(
              name: "Bharatiya Janata Party",
              candidateName: "Kirit Solanki",
              symbolName: "lotus",
              details: "Promoting industrial growth corridor, Metro Phase 3 extensions, and riverfront beautification.",
            ),
            PartyModel(
              name: "Indian National Congress",
              candidateName: "Hasmukh Patel",
              symbolName: "hand",
              details: "Pledging unemployment allowance for youth, traffic decongestion, and clean lake redevelopment.",
            ),
          ],
        ),
        // Ended Election in Surat (Listed 5 days ago, started 4 days ago, ended yesterday)
        ElectionModel(
          id: "elec_surat_completed",
          title: "Surat Textile Zone Council",
          city: "Surat",
          listingTime: now.subtract(const Duration(days: 5)),
          startTime: now.subtract(const Duration(days: 4)),
          endTime: now.subtract(const Duration(days: 1)),
          parties: [
            PartyModel(
              name: "Bharatiya Janata Party",
              candidateName: "Vinod Kapadia",
              symbolName: "lotus",
              details: "Aims to establish high-speed logistics hub and tax rebate for textile exporters.",
            ),
            PartyModel(
              name: "Aam Aadmi Party",
              candidateName: "Ramnik Patel",
              symbolName: "broom",
              details: "Working for textile worker insurance, subsidised solar plants, and labor welfare centres.",
            ),
          ],
        ),
      ];
      await saveElections(defaultElections);

      // Seed some mock anonymous votes for the completed Surat Election (so Results are immediately testable)
      // Say BJP gets 12 votes, AAP gets 8 votes (Total 20 votes, BJP wins by margin of 4)
      final mockVoted = <String>[];
      final mockVotes = <String>[];
      for (int i = 0; i < 20; i++) {
        final mockMobile = "90000000${i.toString().padLeft(2, '0')}";
        mockVoted.add("elec_surat_completed_$mockMobile");
        // 12 votes BJP, 8 votes AAP
        if (i < 12) {
          mockVotes.add("elec_surat_completed_Bharatiya Janata Party");
        } else {
          mockVotes.add("elec_surat_completed_Aam Aadmi Party");
        }
      }
      await prefs.setStringList(_votersListKey, mockVoted);
      await prefs.setStringList(_votesListKey, mockVotes);
    }
  }

  // ── USER METHODS ───────────────────────────────────────────────────────────
  static Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((j) => UserModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, jsonString);
  }

  static Future<UserModel?> getUserByMobile(String mobile) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.mobile == mobile);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> registerUser(UserModel user) async {
    final users = await getUsers();
    if (users.any((u) => u.mobile == user.mobile)) {
      return false; // User already exists with this mobile number
    }
    users.add(user);
    await saveUsers(users);
    return true;
  }

  // ── SESSION MANAGEMENT ─────────────────────────────────────────────────────
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static Future<void> setCurrentUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    }
  }

  // ── ELECTION METHODS ──────────────────────────────────────────────────────
  static Future<List<ElectionModel>> getElections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_electionsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((j) => ElectionModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<void> saveElections(List<ElectionModel> elections) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(elections.map((e) => e.toJson()).toList());
    await prefs.setString(_electionsKey, jsonString);
  }

  static Future<void> addElection(ElectionModel election) async {
    final elections = await getElections();
    elections.add(election);
    await saveElections(elections);
  }

  static Future<void> updateElection(ElectionModel election) async {
    final elections = await getElections();
    final index = elections.indexWhere((e) => e.id == election.id);
    if (index != -1) {
      elections[index] = election;
      await saveElections(elections);
    }
  }

  static Future<void> deleteElection(String electionId) async {
    final elections = await getElections();
    elections.removeWhere((e) => e.id == electionId);
    await saveElections(elections);
  }

  // ── VOTING METHODS ─────────────────────────────────────────────────────────
  // Check if a voter has voted in a specific election
  static Future<bool> hasVoted(String electionId, String voterMobile) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_votersListKey) ?? [];
    return list.contains("${electionId}_$voterMobile");
  }

  // Cast a vote: Register voter and cast anonymous vote in decoupled manner
  static Future<void> castVote(String electionId, String voterMobile, String partyName) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Record that this voter has voted (to prevent voting again)
    final votersList = prefs.getStringList(_votersListKey) ?? [];
    final registrationRecord = "${electionId}_$voterMobile";
    if (!votersList.contains(registrationRecord)) {
      votersList.add(registrationRecord);
      await prefs.setStringList(_votersListKey, votersList);
    }

    // 2. Cast anonymous vote (only linked to electionId and party, NOT the voter)
    final votesList = prefs.getStringList(_votesListKey) ?? [];
    votesList.add("${electionId}_$partyName");
    await prefs.setStringList(_votesListKey, votesList);
  }

  // Get total votes cast in an election (optionally grouped by party)
  static Future<Map<String, int>> getVotesForElection(String electionId) async {
    final prefs = await SharedPreferences.getInstance();
    final votesList = prefs.getStringList(_votesListKey) ?? [];
    final Map<String, int> counts = {};

    for (var vote in votesList) {
      final prefix = "${electionId}_";
      if (vote.startsWith(prefix)) {
        final partyName = vote.substring(prefix.length);
        counts[partyName] = (counts[partyName] ?? 0) + 1;
      }
    }
    return counts;
  }
}
