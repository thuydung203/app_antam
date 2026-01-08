import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String id;
  final String base64String; // Lưu chuỗi ảnh thay vì URL
  final DateTime createdAt;
  final String userId;

  ImageModel({
    required this.id,
    required this.base64String,
    required this.createdAt,
    required this.userId,
  });

  factory ImageModel.fromMap(Map<String, dynamic> data, String id) {
    return ImageModel(
      id: id,
      base64String: data['base64String'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'base64String': base64String,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }
}
