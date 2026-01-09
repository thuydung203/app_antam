import 'dart:async';
import 'dart:convert';
import 'package:antam_app/settings_page.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/create_medicine.dart';
import 'package:antam_app/create_checkup.dart';

import 'package:antam_app/paring.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'models/medicine_model.dart';
import 'models/checkup_model.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';

class ChildrenHomePage extends StatefulWidget {
  final Map<String, dynamic>? selectedPerson; 

  const ChildrenHomePage({super.key, this.selectedPerson});

  @override
  State<ChildrenHomePage> createState() => _ChildrenHomePageState();
}

class _ChildrenHomePageState extends State<ChildrenHomePage> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription? _sosSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningSOS();
  }

  @override
  void dispose() {
    _sosSubscription?.cancel();
    super.dispose();
  }

  void _startListeningSOS() {
    _sosSubscription = FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final diff = DateTime.now().difference(timestamp.toDate()).inMinutes;
          if (diff < 1) {
            _showSOSDialog(data['from'] ?? "Cha/Mẹ");
          }
        }
      }
    });
  }

  void _showSOSDialog(String name) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("CẢNH BÁO SOS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "$name đang cần trợ giúp khẩn cấp! Vui lòng liên hệ ngay lập tức.",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text("TÔI ĐÃ HIỂU", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    if (userModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // LOGIC HIỂN THỊ THÔNG MINH
    // 1. Nếu có người được chọn từ Following -> Hiện người đó
    // 2. Nếu không, lấy cha mẹ đầu tiên trong danh sách following
    // 3. Nếu chưa kết nối với ai -> Hiện placeholder
    
    Map<String, dynamic>? displayPerson;
    
    if (widget.selectedPerson != null) {
      // Trường hợp 1: Đã chọn người cụ thể
      displayPerson = widget.selectedPerson;
    } else if (userModel.following != null && userModel.following!.isNotEmpty) {
      // Trường hợp 2: Lấy cha mẹ đầu tiên trong danh sách
      displayPerson = userModel.following!.first;
    }
    
    // Nếu chưa có cha mẹ nào -> Hiển thị màn hình hướng dẫn kết nối
    if (displayPerson == null) {
      return _buildNoParentScreen();
    }

    final String displayName = displayPerson['name'] ?? "Chưa rõ";
    final String? avatarBase64 = displayPerson['avatar'];
    
    // Tính tuổi từ birthDate nếu có
    int displayAge = 0;
    if (displayPerson['birthDate'] != null) {
      final birthDate = (displayPerson['birthDate'] as Timestamp).toDate();
      final now = DateTime.now();
      displayAge = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        displayAge--;
      }
    } else if (displayPerson['age'] != null) {
      displayAge = displayPerson['age'];
    }

    final String targetUserId = displayPerson['uid'] ?? userModel.uid;
    debugPrint("ChildrenHomePage: viewing medicines for $targetUserId");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút back mặc định
        leading: widget.selectedPerson != null ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Chỉ hiện nút back khi xem người khác
        ) : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCheckupWarning(targetUserId),
            _buildDynamicWarning(targetUserId),
            _userInfo(displayName, avatarBase64, displayAge),

            _sectionHeader(
              title: "TRẠNG THÁI UỐNG THUỐC",
              onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMedicinePage(targetUserId: targetUserId))),
            ),
            
            StreamBuilder<List<MedicineModel>>(
              stream: _dbService.getMedicines(targetUserId), // Lấy thuốc của cha mẹ
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Lỗi tải dữ liệu: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final allMedicines = snapshot.data ?? [];
                
                // Lọc thuốc theo ngày trong tuần
                final now = DateTime.now();
                final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                final todayName = weekdayNames[now.weekday - 1];

                final medicines = snapshot.data ?? [];
                
                if (medicines.isEmpty) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Chưa có đơn thuốc nào.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }
                return Column(children: medicines.map((med) => _medicineCard(med, () => _dbService.deleteMedicine(med.id))).toList());
              },
            ),

            _sectionHeader(
              title: "LỊCH TÁI KHÁM",
              onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCheckupPage(targetUserId: targetUserId))),
            ),
            
            StreamBuilder<List<CheckupModel>>(
              stream: _dbService.getCheckups(targetUserId), // Lấy lịch khám của cha mẹ
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final checkups = snapshot.data ?? [];
                if (checkups.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("Chưa có lịch khám nào."));
                return Column(children: checkups.map((c) => _reExaminationCard(c, () => _dbService.deleteCheckup(c.id))).toList());
              },
            ),

            _sectionHeader(title: "LỊCH SỬ CHECK-IN"),
            _checkinCard(targetUserId),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _userInfo(String userName, String? avatarBase64, int age) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFC1A8),
            backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty) ? MemoryImage(base64Decode(avatarBase64)) : null,
            child: (avatarBase64 == null || avatarBase64.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(age > 0 ? "Tuổi: $age" : "Tuổi: --"),
            ],
          ),
          const Spacer(),
          _smallAvatar(avatarBase64),
        ],
      ),
    );
  }

  Widget _smallAvatar(String? avatarBase64) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFFFFC1A8),
      backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty) ? MemoryImage(base64Decode(avatarBase64)) : null,
      child: (avatarBase64 == null || avatarBase64.isEmpty) ? const Icon(Icons.person, size: 14, color: Colors.white) : null,
    );
  }

  Widget _buildCheckupWarning(String targetUserId) {
    return StreamBuilder<List<CheckupModel>>(
      stream: _dbService.getCheckups(targetUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final tomorrow = now.add(const Duration(hours: 24));

        // Tìm lịch khám trong 24h tới và chưa qua
        final upcomingCheckups = snapshot.data!.where((c) {
          return c.date.isAfter(now) && c.date.isBefore(tomorrow);
        }).toList();

        if (upcomingCheckups.isEmpty) {
          return const SizedBox.shrink();
        }

        final checkup = upcomingCheckups.first;
        final timeStr = DateFormat('HH:mm').format(checkup.date);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Màu xanh nhạt cho lịch khám
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Nhắc nhở! Cha mẹ có lịch khám tại ${checkup.hospitalName} vào lúc $timeStr.",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicWarning(String targetUserId) {
    return StreamBuilder<List<MedicineModel>>(
      stream: _dbService.getMedicines(targetUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Lọc thuốc theo ngày trong tuần
        final now = DateTime.now();
        final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final todayName = weekdayNames[now.weekday - 1];

        final todayMeds = snapshot.data!.where((m) {
          if (m.repeatDays.isEmpty) return true; // Hàng ngày
          return m.repeatDays.contains(todayName);
        }).toList();

        final unconfirmedMeds = todayMeds.where((m) => !m.isConfirmed).toList();

        if (unconfirmedMeds.isEmpty) {
          return const SizedBox.shrink();
        }

        // Ưu tiên hiển thị thuốc nào chưa uống
        final med = unconfirmedMeds.first;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6A7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Cảnh báo! Cha mẹ chưa xác nhận lịch uống thuốc ${med.name}.",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader({required String title, VoidCallback? onAdd, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (trailing != null) 
            trailing
          else if (onAdd != null) 
            IconButton(icon: const Icon(Icons.add, size: 26), onPressed: onAdd),
        ],
      ),
    );
  }

  Widget _medicineCard(MedicineModel med, VoidCallback onDelete) {
    String repeatText = med.repeatDays.isEmpty ? "Hằng ngày" : med.repeatDays.join(', ');
    String subText = "Liều: ${med.dosage} - ${med.time.format()} ($repeatText)";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(med.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(subText, style: const TextStyle(color: Colors.grey))])),
            Icon(med.isConfirmed ? Icons.check_circle : Icons.cancel, color: med.isConfirmed ? Colors.green : Colors.red, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _reExaminationCard(CheckupModel checkup, VoidCallback onDelete) {
    final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(checkup.date);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(checkup.hospitalName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(dateStr, style: const TextStyle(color: Colors.grey))])),
          ],
        ),
      ),
    );
  }

  Widget _checkinCard(String userId) {
    return StreamBuilder<List<CheckInModel>>(
      stream: _dbService.getCheckIns(userId, DateTime.now()),
      builder: (context, snapshot) {
        final checkins = snapshot.data ?? [];
        int percentage = 0;
        int daysPassed = DateTime.now().day;
        if (daysPassed > 0) {
          percentage = ((checkins.length / daysPassed) * 100).round();
          if (percentage > 100) percentage = 100;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: const Color(0x33FFA387),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA387)),
                      ),
                      Text("$percentage%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tuân thủ tháng này", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => CheckInHistoryPage(targetUserId: userId))
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA387), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      child: const Text("Xem chi tiết", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildNoParentScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Trang chủ", style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.family_restroom,
                size: 120,
                color: Color(0xFFFFA387),
              ),
              const SizedBox(height: 30),
              const Text(
                "Chưa kết nối với Cha/Mẹ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Bạn cần kết nối với cha mẹ để theo dõi sức khỏe của họ.\n\nHãy nhấn nút bên dưới để bắt đầu kết nối!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PairingExpiredPage()),
                    );
                  },
                  icon: const Icon(Icons.link, color: Colors.white),
                  label: const Text(
                    "KẾT NỐI VỚI CHA MẸ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA387),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
