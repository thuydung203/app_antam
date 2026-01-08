import 'package:cloud_firestore/cloud_firestore.dart';

class FollowerModel {
  final String id;
  final String name;
  final String relationship;
  final DateTime birthDate;
  final int age;
  final String accountEmail; // Tài khoản (email) của người được theo dõi
  final String addedBy; // ID của người con (người thực hiện thêm)

  FollowerModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.birthDate,
    required this.age,
    required this.accountEmail,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'birthDate': Timestamp.fromDate(birthDate),
      'age': age,
      'accountEmail': accountEmail,
      'addedBy': addedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory FollowerModel.fromMap(Map<String, dynamic> data, String id) {
    return FollowerModel(
      id: id,
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      age: data['age'] ?? 0,
      accountEmail: data['accountEmail'] ?? '',
      addedBy: data['addedBy'] ?? '',
    );
  }
}
