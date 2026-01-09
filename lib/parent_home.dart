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

  void _scheduleDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _dailyResetTimer = Timer(timeUntilMidnight, () async {
      await _resetMedicineConfirmations();
      _scheduleDailyReset();
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

  Future<void> _handleSOS(BuildContext context) async {
    const String childPhoneNumber = "0123456789"; 
    final Uri launchUri = Uri(scheme: 'tel', path: childPhoneNumber);
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      await FirebaseFirestore.instance.collection('sos_alerts').add({
        'from': user?.name ?? "Cha/Mẹ",
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    }
  }

  Future<void> _handleCheckIn(String medicineId) async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('medicines').doc(medicineId).update({
      'isConfirmed': true,
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allMedicinesSnapshot = await FirebaseFirestore.instance
        .collection('medicines')
        .where('userId', isEqualTo: user.uid)
        .get();

    final todayMedicines = allMedicinesSnapshot.docs.where((doc) {
      final data = doc.data();
      final repeatDays = List<String>.from(data['repeatDays'] ?? []);
      if (repeatDays.isEmpty) return true;
      final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final todayName = weekdayNames[now.weekday - 1];
      return repeatDays.contains(todayName);
    }).toList();

    final confirmedCount = todayMedicines.where((doc) {
      final data = doc.data();
      return data['isConfirmed'] == true;
    }).length;

    if (todayMedicines.isNotEmpty && confirmedCount == todayMedicines.length) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;

    // LẤY ID CỦA NGƯỜI CON ĐẦU TIÊN TRONG DANH SÁCH FOLLOWING ĐỂ HIỆN ẢNH
    String? firstChildId;
    if (user?.following != null && user!.following!.isNotEmpty) {
      firstChildId = user.following!.first['uid'];
    }

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
              // Sử dụng ID người con tìm được từ danh sách following
              _buildSlideshow(firstChildId),

              const SizedBox(height: 30),

              _buildCheckInButton(user?.uid),

              const SizedBox(height: 10),
              _buildLargeButton(
                title: 'SOS KHẨN CẤP',
                color: const Color(0xFFF94133),
                onPressed: () => _handleSOS(context),
              ),

              const SizedBox(height: 15),
              
              _buildLargeButton(
                title: 'GỌI CON',
                color: const Color(0xFF78EC46),
                icon: Icons.call,
                onPressed: () => _handleSOS(context), 
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton(String? parentId) {
    if (parentId == null) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medicines')
          .where('userId', isEqualTo: parentId)
          .where('isConfirmed', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final medDoc = snapshot.data!.docs.first;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: () => _handleCheckIn(medDoc.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA387),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("BẤM VÀO ĐÂY ĐỂ BÁO", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("ĐÃ UỐNG ${medDoc['name']}", style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSlideshow(String? childId) {
    if (childId == null || childId.isEmpty) {
      return Container(
        height: 350,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("Chưa có ảnh gia đình nào được tải lên", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('images')
          .where('userId', isEqualTo: childId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Container(height: 350, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("Đang chờ ảnh từ con...")));
        
        _timer?.cancel(); // Tránh tạo nhiều timer chồng chéo
        _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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
