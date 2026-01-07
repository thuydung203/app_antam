import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String userId;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.userId,
  });

  factory LocationModel.fromMap(Map<String, dynamic> data) {
    return LocationModel(
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }
}
