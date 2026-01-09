import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../models/checkup_model.dart';
import '../main.dart';
import '../alarm_clock.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Sử dụng MethodChannel để lấy timezone từ native
    const platform = MethodChannel('com.example.antam_app/timezone');
    String timeZoneName;
    try {
      timeZoneName = await platform.invokeMethod('getLocalTimezone');
    } on PlatformException {
      timeZoneName = 'UTC'; // Fallback nếu lỗi
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi người dùng nhấn vào thông báo
        debugPrint("Notification clicked: ${response.payload}");
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );

    // Request permissions for Android
    final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  void _handleNotificationTap(String payload) {
    // Payload expected format: "medicineId|medicineName|medicineTime"
    final parts = payload.split('|');
    if (parts.length >= 3) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmClockPage(
            medicineId: parts[0],
            reminderText: "Đến giờ uống: ${parts[1]}",
            alarmTime: parts[2],
          ),
        ),
      );
    }
  }

  Future<void> scheduleMedicineReminder(MedicineModel medicine) async {
    final int id = medicine.id.hashCode;
    final time = medicine.time;
    
    // Chuyển đổi sang múi giờ địa phương
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Nếu giờ đã qua, lên lịch cho ngày mai
    // Fix: Nếu chỉ vừa mới qua (trong vòng 1 phút), có thể do người dùng vừa tạo
    // -> Vẫn cho báo ngay (delay 3s) thay vì đẩy sang hôm sau
    if (scheduledDate.isBefore(now)) {
      if (now.difference(scheduledDate).inSeconds < 60) {
        // Vẫn coi là "hiện tại", set lịch after 3s để đảm bảo trigger
        scheduledDate = now.add(const Duration(seconds: 3));
      } else {
         scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    final String payload = "${medicine.id}|${medicine.name}|${time.format()}";

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicine_reminders',
      'Nhắc uống thuốc',
      channelDescription: 'Thông báo nhắc nhở uống thuốc cho cha mẹ',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Hiển thị AlarmClockPage ngay lập tức nếu Android cho phép
      category: AndroidNotificationCategory.alarm,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Upgraded: Use alarmClock for highest priority
    if (medicine.repeatDays.isEmpty) {
      // Một lần duy nhất
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Đến giờ uống thuốc rồi!',
        'Đã đến lúc uống: ${medicine.name}',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.alarmClock, // Changed to alarmClock
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Nhắc uống thuốc: ${medicine.name}',
        'Bạn có lịch uống ${medicine.name} (${medicine.dosage}) vào lúc ${time.format()}',
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.alarmClock, // Changed to alarmClock
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
    
    debugPrint("Scheduled notification for ${medicine.name} at ${time.format()} (ID: $id)");
  }

  Future<void> cancelReminder(String medicineId) async {
    await flutterLocalNotificationsPlugin.cancel(medicineId.hashCode);
    debugPrint("Cancelled notification for ID: $medicineId");
  }

  Future<void> cancelAllReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("Cancelled all notifications");
  }
  Future<void> scheduleCheckupReminder(CheckupModel checkup) async {
    // 1. Tạo ID thông báo dựa trên ID của checkup
    final int id = checkup.id.hashCode;
    
    // 2. Tính thời gian thông báo: Trước 12 tiếng
    // Checkup date là thời điểm khám, trừ đi 12h
    final DateTime checkupTime = checkup.date;
    DateTime scheduledTime = checkupTime.subtract(const Duration(hours: 12));

    // 3. Kiểm tra thời gian
    final now = DateTime.now();

    // Nếu thời gian thông báo đã qua rồi (ví dụ tạo lịch khám gấp trong vòng 12h tới)
    if (scheduledTime.isBefore(now)) {
       // Thông báo ngay sau 5 giây (để nhắc nhở ngay lập tức)
       scheduledTime = now.add(const Duration(seconds: 5));
    }

    // Chuyển sang TimeZone local
    final scheduledTZDate = tz.TZDateTime.from(scheduledTime, tz.local);

    final String payload = "checkup|${checkup.id}|${checkup.hospitalName}";

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'checkup_reminders',
      'Nhắc tái khám',
      channelDescription: 'Thông báo nhắc nhở lịch tái khám trước 12h',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.event,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Sắp đến giờ tái khám!',
      'Bạn có lịch khám tại ${checkup.hospitalName} vào lúc ${_formatTime(checkupTime)}',
      scheduledTZDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint("Scheduled checkup reminder for ${checkup.hospitalName} at ${scheduledTZDate.toString()}");
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ngày ${date.day}/${date.month}";
  }
  Future<void> cancelCheckupReminder(String checkupId) async {
    await flutterLocalNotificationsPlugin.cancel(checkupId.hashCode);
    debugPrint("Cancelled checkup reminder for ID: $checkupId");
  }
}
