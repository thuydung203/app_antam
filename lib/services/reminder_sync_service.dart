import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../models/medicine_model.dart';
import '../models/checkup_model.dart';
import 'package:flutter/foundation.dart';

class ReminderSyncService {
  static final ReminderSyncService _instance = ReminderSyncService._internal();
  factory ReminderSyncService() => _instance;
  ReminderSyncService._internal();

  StreamSubscription<QuerySnapshot>? _medicineSubscription;
  StreamSubscription<QuerySnapshot>? _checkupSubscription;

  Future<void> startSync(String userId) async {
    // Ngắt kết nối cũ nếu có
    await stopSync();

    debugPrint("Starting sync for user: $userId");

    // 1. Medicine Sync
    _medicineSubscription = FirebaseFirestore.instance
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      
      final prefs = await SharedPreferences.getInstance();
      final bool isEnabled = prefs.getBool('medicine_reminders_enabled') ?? true;

      if (!isEnabled) {
        // Only cancel medicine reminders if toggle off, keep checkups? 
        // Or assume general toggle off? 
        // For now, let's assume this toggle affects everything or just keep it simple.
        // await NotificationService().cancelAllReminders(); 
        // Let's modify logic: check toggle inside handling or ignore for now.
        return; 
      }
      
      for (var change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>;
        final medicine = MedicineModel.fromMap(data, change.doc.id);

        if (change.type == DocumentChangeType.removed) {
          await NotificationService().cancelReminder(medicine.id);
        } else {
          await NotificationService().scheduleMedicineReminder(medicine);
        }
      }
    });

    // 2. Checkup Sync (NEW)
    _checkupSubscription = FirebaseFirestore.instance
        .collection('checkups')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      
      for (var change in snapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>;
        final checkup = CheckupModel.fromMap(data, change.doc.id);

        if (change.type == DocumentChangeType.removed) {
          await NotificationService().cancelCheckupReminder(checkup.id);
        } else {
          // Added or Modified
          await NotificationService().scheduleCheckupReminder(checkup);
        }
      }
    });
  }

  Future<void> stopSync() async {
    await _medicineSubscription?.cancel();
    await _checkupSubscription?.cancel();
    _medicineSubscription = null;
    _checkupSubscription = null;
    // await NotificationService().cancelAllReminders(); // Should we clear alarms on logout? Yes.
  }
}
