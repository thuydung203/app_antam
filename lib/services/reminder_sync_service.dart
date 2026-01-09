import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../models/medicine_model.dart';
import 'package:flutter/foundation.dart';

class ReminderSyncService {
  static final ReminderSyncService _instance = ReminderSyncService._internal();
  factory ReminderSyncService() => _instance;
  ReminderSyncService._internal();

  StreamSubscription<QuerySnapshot>? _subscription;

  Future<void> startSync(String userId) async {
    // Ngắt kết nối cũ nếu có
    await stopSync();

    debugPrint("Starting sync for user: $userId");

    _subscription = FirebaseFirestore.instance
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      
      final prefs = await SharedPreferences.getInstance();
      final bool isEnabled = prefs.getBool('medicine_reminders_enabled') ?? true;

      if (!isEnabled) {
        await NotificationService().cancelAllReminders();
        return;
      }

      // Khi có thay đổi trong Firestore, cập nhật lại toàn bộ nhắc nhở local
      // (Cách tiếp cận đơn giản: Cancel all và Re-schedule, hoặc so sánh thay đổi)
      // Để tránh spam, ta có thể chỉ xử lý những doc bị thay đổi.
      
      for (var change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>;
        final medicine = MedicineModel.fromMap(data, change.doc.id);

        if (change.type == DocumentChangeType.removed) {
          await NotificationService().cancelReminder(medicine.id);
        } else {
          // added hoặc modified
          // Chỉ nhắc nhở những thuốc CHƯA xác nhận uống (hoặc nhắc hàng ngày bất kể trạng thái?)
          // Thông thường nhắc uống thuốc là nhắc theo giờ cố định.
          await NotificationService().scheduleMedicineReminder(medicine);
        }
      }
    });
  }

  Future<void> stopSync() async {
    await _subscription?.cancel();
    _subscription = null;
    await NotificationService().cancelAllReminders();
  }
}
