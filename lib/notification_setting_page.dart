import 'package:antam_app/services/reminder_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationPage> {
  bool _isMedicationReminderEnabled = true;
  bool _isNotificationEnabled = true;
  bool _isNotificationAndVibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMedicationReminderEnabled = prefs.getBool('medicine_reminders_enabled') ?? true;
      _isNotificationEnabled = prefs.getBool('is_notification_enabled') ?? true;
      _isNotificationAndVibrationEnabled = prefs.getBool('is_notification_vibration_enabled') ?? true;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_notification_enabled', value);
    setState(() {
      _isNotificationEnabled = value;
    });
  }

  Future<void> _toggleNotificationAndVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_notification_vibration_enabled', value);
    setState(() {
      _isNotificationAndVibrationEnabled = value;
    });
  }

  Future<void> _toggleMedicationReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('medicine_reminders_enabled', value);
    setState(() {
      _isMedicationReminderEnabled = value;
    });
    
    // Re-trigger sync based on current user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (value) {
        ReminderSyncService().startSync(user.uid);
      } else {
        ReminderSyncService().stopSync();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh tiêu đề (AppBar)
      appBar: AppBar(
        // Màu nền thường là trong suốt hoặc trắng để phù hợp với giao diện
        backgroundColor: Colors.white, 
        elevation: 0, // Bỏ đổ bóng
        title: const Text('Thông báo', style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      // Thân trang (Body)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Tiêu đề: Tùy chọn nội dung
            const Text(
              'Tùy chọn nội dung',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Nhóm tùy chọn nội dung
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), 
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Bật thông báo
                  _buildSwitchTile(
                    title: 'Bật thông báo',
                    value: _isNotificationEnabled,
                    onChanged: _toggleNotification,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // 2. Bật thông báo & Rung
                  _buildSwitchTile(
                    title: 'Bật thông báo & Rung',
                    value: _isNotificationAndVibrationEnabled,
                    onChanged: _toggleNotificationAndVibration,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề: Cảnh báo An toàn & Ưu tiên
            const Text(
              'Cảnh báo An toàn & Ưu tiên',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Nhóm cảnh báo
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildSwitchTile(
                title: 'Lời nhắc uống thuốc',
                value: _isMedicationReminderEnabled,
                onChanged: _toggleMedicationReminder,
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề: Thông báo Hệ thống & Hoạt động
            const Text(
              'Thông báo Hệ thống & Hoạt động',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // Phần trống cho Thông báo Hệ thống (giống như hình ảnh)
            Container(
              height: 100, // Chiều cao ước tính theo hình
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              // Bạn có thể thêm nội dung chi tiết ở đây nếu cần
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tiện ích để tạo nhanh các SwitchListTile
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.blue, // Màu xanh dương cho nút bật
      // Bỏ qua padding mặc định để kiểm soát lề tốt hơn
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), 
    );
  }
}

// --- Ví dụ cách chạy (Bạn có thể bỏ qua phần này nếu đã có MyApp) ---
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationSettingPage(), 
    );
  }
}
*/
