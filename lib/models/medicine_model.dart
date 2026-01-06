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

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.userId,
    this.repeatDays = const [],
    this.sound = 'Mặc định',
    this.isConfirmed = false,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> data, String id) {
    return MedicineModel(
      id: id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      time: TimeOfDayModel.fromMap(data['time'] ?? {}),
      userId: data['userId'] ?? '',
      repeatDays: List<String>.from(data['repeatDays'] ?? []),
      sound: data['sound'] ?? 'Mặc định',
      isConfirmed: data['isConfirmed'] ?? false,
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
