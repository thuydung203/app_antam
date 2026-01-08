import 'dart:async';
import 'dart:convert';
import 'package:antam_app/settings_page.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/create_medicine.dart';
import 'package:antam_app/create_checkup.dart';
import 'package:antam_app/following.dart';
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

    // LOGIC HIỂN THỊ THÔNG MINH
    // Nếu có người được chọn từ Following -> Hiện người đó
    // Nếu không (lần đầu đăng ký) -> Hiện chính mình
    final String displayName = widget.selectedPerson != null 
        ? widget.selectedPerson!['name'] 
        : (userModel?.name ?? "Người dùng");
    
    final int displayAge = widget.selectedPerson != null 
        ? widget.selectedPerson!['age'] 
        : (userModel?.age ?? 0);

    final String? avatarBase64 = widget.selectedPerson != null 
        ? widget.selectedPerson!['avatar'] 
        : userModel?.avatar;

    if (userModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            _warningCard(),
            _userInfo(displayName, avatarBase64, displayAge),

            _sectionHeader(
              title: "TRẠNG THÁI UỐNG THUỐC",
              onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMedicinePage())),
            ),
            
            StreamBuilder<List<MedicineModel>>(
              stream: _dbService.getMedicines(userModel.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final medicines = snapshot.data ?? [];
                if (medicines.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("Chưa có đơn thuốc nào."));
                return Column(children: medicines.map((med) => _medicineCard(med, () => _dbService.deleteMedicine(med.id))).toList());
              },
            ),

            _sectionHeader(
              title: "LỊCH TÁI KHÁM",
              onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCheckupPage())),
            ),
            
            StreamBuilder<List<CheckupModel>>(
              stream: _dbService.getCheckups(userModel.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final checkups = snapshot.data ?? [];
                if (checkups.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("Chưa có lịch khám nào."));
                return Column(children: checkups.map((c) => _reExaminationCard(c, () => _dbService.deleteCheckup(c.id))).toList());
              },
            ),

            _sectionHeader(title: "LỊCH SỬ CHECK-IN"),
            _checkinCard(),
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

  Widget _warningCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFE6A7), borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Expanded(child: Text("Cảnh báo! Cha mẹ chưa xác nhận lịch uống thuốc Huyết áp sáng.", style: TextStyle(fontSize: 14)))]),
      ),
    );
  }

  Widget _sectionHeader({required String title, VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (onAdd != null) IconButton(icon: const Icon(Icons.add, size: 26), onPressed: onAdd),
        ],
      ),
    );
  }

  Widget _medicineCard(MedicineModel med, VoidCallback onDelete) {
    String subText = "Liều: ${med.dosage} - ${med.time.format()}";
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

  Widget _checkinCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const CircularProgressIndicator(value: 1, strokeWidth: 8, valueColor: AlwaysStoppedAnimation(Color(0xFFFFA387))),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tuân thủ tháng này", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInHistoryPage())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA387), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text("Xem chi tiết", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
