class UserModel {
  final String name;
  final String mobile;
  final String voterId;
  final String aadharNumber;
  final String city;
  final String role; // 'voter' or 'admin'

  UserModel({
    required this.name,
    required this.mobile,
    required this.voterId,
    required this.aadharNumber,
    required this.city,
    required this.role,
  });

  // Convert a UserModel to a Map for JSON serialization
  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'voterId': voterId,
        'aadharNumber': aadharNumber,
        'city': city,
        'role': role,
      };

  // Create a UserModel from a Map
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        voterId: json['voterId'] as String,
        aadharNumber: json['aadharNumber'] as String,
        city: json['city'] as String,
        role: json['role'] as String,
      );
}
