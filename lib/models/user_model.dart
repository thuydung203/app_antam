import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? avatar;
  final String? phone;
  final String? address;
  final DateTime? birthDate; 
  final String? parentId;
  final List<String>? childrenIds;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.avatar,
    this.phone,
    this.address,
    this.birthDate,
    this.parentId,
    this.childrenIds,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'parent',
      name: data['name'],
      avatar: data['avatar'],
      phone: data['phone'],
      address: data['address'],
      birthDate: data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : null,
      parentId: data['parentId'],
      childrenIds: (data['childrenIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'latitude': latitude,
      'longitude': longitude,
      'age': age, // Vẫn lưu tuổi vào DB bằng cách gọi hàm get age bên dưới
    };
  }

  // Hàm tính tuổi tự động dựa trên birthDate
  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int ageResult = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      ageResult--;
    }
    return ageResult;
  }
}
