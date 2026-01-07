class UserModel {
  final String uid;
  final String email;
  final String role; // 'parent' or 'child'
  final String? name;
  final String? parentId; // If child
  final List<String>? childrenIds; // If parent
  final double? latitude;
  final double? longitude;
  final int? age;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.parentId,
    this.childrenIds,
    this.latitude,
    this.longitude,
    this.age,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'parent',
      name: data['name'],
      parentId: data['parentId'],
      childrenIds: (data['childrenIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      age: data['age'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'latitude': latitude,
      'longitude': longitude,
      'age': age,
    };
  }
}
