import 'dart:async';
import 'dart:convert';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:antam_app/image_gallery.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/medicine_model.dart';
import 'models/checkin_model.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  Timer? _dailyResetTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleDailyReset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dailyResetTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Reset trạng thái isConfirmed về false vào đầu ngày mới
  void _scheduleDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _dailyResetTimer = Timer(timeUntilMidnight, () async {
      await _resetMedicineConfirmations();
      _scheduleDailyReset(); // Lên lịch cho ngày tiếp theo
    });
  }

  Future<void> _resetMedicineConfirmations() async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    final medicinesSnapshot = await FirebaseFirestore.instance
        .collection('medicines')
        .where('userId', isEqualTo: user.uid)
        .where('isConfirmed', isEqualTo: true)
        .get();

    for (var doc in medicinesSnapshot.docs) {
      await doc.reference.update({'isConfirmed': false});
    }
  }

  // FR2.2 & FR3.3: Xử lý cuộc gọi SOS GSM
  Future<void> _handleSOS(BuildContext context) async {
    const String childPhoneNumber = "0123456789"; // Số điện thoại người con
    final Uri launchUri = Uri(scheme: 'tel', path: childPhoneNumber);
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
      // Gửi tín hiệu lên Firebase để app Con hiện cảnh báo
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      await FirebaseFirestore.instance.collection('sos_alerts').add({
        'from': user?.name ?? "Cha/Mẹ",
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    }
  }

  // FR2.3: Xử lý xác nhận uống thuốc và tự động check-in
  Future<void> _handleCheckIn(String medicineId) async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    // 1. Xác nhận thuốc này đã uống
    await FirebaseFirestore.instance.collection('medicines').doc(medicineId).update({
      'isConfirmed': true,
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    // 2. Kiểm tra xem đã uống đủ tất cả thuốc trong ngày chưa
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Lấy tất cả thuốc của user trong ngày hôm nay
    final allMedicinesSnapshot = await FirebaseFirestore.instance
        .collection('medicines')
        .where('userId', isEqualTo: user.uid)
        .get();
    
    final todayMedicines = allMedicinesSnapshot.docs.where((doc) {
      final data = doc.data();
      final repeatDays = List<String>.from(data['repeatDays'] ?? []);
      
      // Kiểm tra xem thuốc này có lịch uống hôm nay không
      if (repeatDays.isEmpty) return true; // Nếu không có lịch lặp, coi như mỗi ngày
      
      final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final todayName = weekdayNames[now.weekday - 1];
      
      return repeatDays.contains(todayName);
    }).toList();
    
    // Đếm số thuốc đã xác nhận
    final confirmedCount = todayMedicines.where((doc) {
      final data = doc.data();
      return data['isConfirmed'] == true;
    }).length;
    
    // 3. Nếu đã uống đủ tất cả thuốc → Tự động tạo check-in
    if (todayMedicines.isNotEmpty && confirmedCount == todayMedicines.length) {
      // Tạo check-in cho hôm nay
      final checkInData = CheckInModel(
        id: '${user.uid}_${today.year}-${today.month}-${today.day}',
        userId: user.uid,
        date: today,
        status: true,
      );
      
      await FirebaseFirestore.instance
          .collection('checkins')
          .doc(checkInData.id)
          .set(checkInData.toMap());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Đã uống đủ thuốc hôm nay! Check-in thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã xác nhận uống thuốc! ($confirmedCount/${todayMedicines.length})"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              // FR4.1: SLIDESHOW ẢNH (Giúp giảm cô đơn)
              _buildSlideshow(),

              const SizedBox(height: 30),

              // FR2.3: NÚT CHECK-IN THÔNG MINH (Chỉ hiện khi có thuốc chưa uống)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medicines')
                    .where('userId', isEqualTo: user?.uid)
                    .where('isConfirmed', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final medDoc = snapshot.data!.docs.first;
                    final medName = medDoc['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: () => _handleCheckIn(medDoc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA387), // Màu cam thương hiệu
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("BẤM VÀO ĐÂY ĐỂ BÁO", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("ĐÃ UỐNG $medName", style: const TextStyle(color: Colors.white, fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // FR2.2: NÚT SOS KHẨN CẤP
              _buildLargeButton(
                title: 'SOS KHẨN CẤP',
                color: const Color(0xFFF94133),
                onPressed: () => _handleSOS(context),
              ),

              const SizedBox(height: 15),
              
              // FR2.4: NÚT GỌI CON
              _buildLargeButton(
                title: 'GỌI CON',
                color: const Color(0xFF78EC46),
                icon: Icons.call,
                onPressed: () => _handleSOS(context), // Có thể đổi sang số gọi bình thường
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideshow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('images').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("Đang chờ ảnh từ con...")));
        
        _timer ??= Timer.periodic(const Duration(seconds: 5), (Timer timer) {
          if (_currentPage < docs.length - 1) _currentPage++; else _currentPage = 0;
          if (_pageController.hasClients) {
            _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
          }
        });

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ImageGalleryPage())),
          child: SizedBox(
            height: 350,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                itemCount: docs.length,
                onPageChanged: (index) => _currentPage = index,
                itemBuilder: (context, index) {
                  final String base64Str = docs[index]['base64String'] ?? '';
                  return Image.memory(base64Decode(base64Str), fit: BoxFit.cover, gaplessPlayback: true);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLargeButton({required String title, required Color color, required VoidCallback onPressed, IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 40), const SizedBox(width: 15)],
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
