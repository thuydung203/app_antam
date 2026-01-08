import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String userId;
  final DateTime date;
  final bool status;

  CheckInModel({
    required this.id,
    required this.userId,
    required this.date,
    this.status = true,
  });

  factory CheckInModel.fromMap(Map<String, dynamic> data, String id) {
    return CheckInModel(
      id: id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}
