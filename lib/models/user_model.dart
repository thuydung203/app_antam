class UserModel {
  final String uid;
  final String email;
  final String role; // 'parent' or 'child'
  final String? name;
  final String? parentId; // If child
  final List<String>? childrenIds; // If parent

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.parentId,
    this.childrenIds,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'parent',
      name: data['name'],
      parentId: data['parentId'],
      childrenIds: (data['childrenIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'parentId': parentId,
      'childrenIds': childrenIds,
    };
  }
}
