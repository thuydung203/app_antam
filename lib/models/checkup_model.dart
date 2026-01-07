import 'package:cloud_firestore/cloud_firestore.dart';

class CheckupModel {
  final String id;
  final String hospitalName;
  final DateTime date;
  final String result;
  final String userId;

  CheckupModel({
    required this.id,
    required this.hospitalName,
    required this.date,
    required this.result,
    required this.userId,
  });

  factory CheckupModel.fromMap(Map<String, dynamic> data, String id) {
    return CheckupModel(
      id: id,
      hospitalName: data['hospitalName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      result: data['result'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospitalName': hospitalName,
      'date': Timestamp.fromDate(date),
      'result': result,
      'userId': userId,
    };
  }
}
