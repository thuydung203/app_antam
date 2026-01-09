import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  final String id;
  final String name;
  final String dosage;
  final TimeOfDayModel time; // Storing time as simplified object/string
  final String userId; // Child or Parent ID who takes it
  final List<String> repeatDays;
  final String sound;
  final bool isConfirmed; // Trạng thái xác nhận của cha mẹ (True: Đã uống, False: Chưa/Không)
  final DateTime? confirmedAt; // Thời gian xác nhận gần nhất

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.userId,
    this.repeatDays = const [],
    this.sound = 'Mặc định',
    this.isConfirmed = false,
    this.confirmedAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime? confirmedAt = data['confirmedAt'] is Timestamp 
        ? (data['confirmedAt'] as Timestamp).toDate() 
        : null;

    bool isConfirmed = data['isConfirmed'] ?? false;
    
    // Logic reset daily: Nếu đã uống nhưng ngày xác nhận không phải hôm nay -> Reset hiển thị là chưa uống
    if (isConfirmed && confirmedAt != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final confirmedDate = DateTime(confirmedAt.year, confirmedAt.month, confirmedAt.day);
      if (confirmedDate.isBefore(today)) {
        isConfirmed = false;
      }
    }

    return MedicineModel(
      id: id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      time: TimeOfDayModel.fromMap(data['time'] ?? {}),
      userId: data['userId'] ?? '',
      repeatDays: List<String>.from(data['repeatDays'] ?? []),
      sound: data['sound'] ?? 'Mặc định',
      isConfirmed: isConfirmed,
      confirmedAt: confirmedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'time': time.toMap(),
      'userId': userId,
      'repeatDays': repeatDays,
      'sound': sound,
      'isConfirmed': isConfirmed,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
    };
  }
}

class TimeOfDayModel {
  final int hour;
  final int minute;

  TimeOfDayModel({required this.hour, required this.minute});

  factory TimeOfDayModel.fromMap(Map<String, dynamic> data) {
    return TimeOfDayModel(
      hour: data['hour'] ?? 0,
      minute: data['minute'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
