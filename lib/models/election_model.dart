class PartyModel {
  final String name;
  final String candidateName;
  final String symbolName; // Name of symbol icon (e.g. 'lotus', 'hand', 'broom', 'elephant', 'cycle', etc.)
  final String details;

  PartyModel({
    required this.name,
    required this.candidateName,
    required this.symbolName,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'candidateName': candidateName,
        'symbolName': symbolName,
        'details': details,
      };

  factory PartyModel.fromJson(Map<String, dynamic> json) => PartyModel(
        name: json['name'] as String,
        candidateName: json['candidateName'] as String,
        symbolName: json['symbolName'] as String,
        details: json['details'] as String,
      );
}

class ElectionModel {
  final String id;
  final String title;
  final String city;
  final DateTime listingTime;
  final DateTime startTime;
  final DateTime endTime;
  final List<PartyModel> parties;

  ElectionModel({
    required this.id,
    required this.title,
    required this.city,
    required this.listingTime,
    required this.startTime,
    required this.endTime,
    required this.parties,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'city': city,
        'listingTime': listingTime.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'parties': parties.map((p) => p.toJson()).toList(),
      };

  factory ElectionModel.fromJson(Map<String, dynamic> json) => ElectionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        city: json['city'] as String,
        listingTime: DateTime.parse(json['listingTime'] as String),
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        parties: (json['parties'] as List<dynamic>)
            .map((p) => PartyModel.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
