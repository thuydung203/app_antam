import 'dart:async';
import 'dart:convert';
import 'package:antam_app/parent_setting.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:antam_app/image_gallery.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/medicine_model.dart';
import 'models/checkup_model.dart';
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

  // HÀM XỬ LÝ GỌI (GSM) - CÓ THÊM KIỂM TRA VÀ THÔNG BÁO
  Future<void> _makeCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Con chưa cập nhật số điện thoại!")),
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể mở trình gọi điện.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Lỗi gọi điện: $e");
    }
  }

  // HÀM XỬ LÝ SOS (Gửi cảnh báo + Gọi)
  Future<void> _handleSOS(BuildContext context, String? childPhone) async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    
    // Gửi tín hiệu SOS lên Firebase
    await FirebaseFirestore.instance.collection('sos_alerts').add({
      'from': user?.name ?? "Cha/Mẹ",
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active',
    });

    // Thực hiện cuộc gọi
    await _makeCall(context, childPhone);
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

    String? idToTrack = user?.childId;
    if ((idToTrack == null || idToTrack.isEmpty) && user?.following != null && user!.following!.isNotEmpty) {
      idToTrack = user.following!.first['uid'];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('ANTÂM', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentSettingPage())),
          ),
        ],
      ),
      body: idToTrack == null 
        ? const Center(child: Text("Đang chờ kết nối với con..."))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(idToTrack).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
              
              final childData = snapshot.data?.data() as Map<String, dynamic>?;
              final String? childPhone = childData?['phone'];

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Column(
                    children: [
                      _buildSlideshow(idToTrack),
                      const SizedBox(height: 30),
                      _buildCheckInButton(user?.uid),
                      const SizedBox(height: 10),
                      
                      // NÚT SOS: Gọi số điện thoại của con (Real-time)
                      _buildLargeButton(
                        title: 'SOS KHẨN CẤP', 
                        color: const Color(0xFFF94133), 
                        onPressed: () => _handleSOS(context, childPhone)
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // NÚT GỌI CON: Gọi số điện thoại của con (Real-time)
                      _buildLargeButton(
                        title: 'GỌI CON', 
                        color: const Color(0xFF78EC46), 
                        icon: Icons.call, 
                        onPressed: () => _makeCall(context, childPhone)
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            }
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
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("Kết nối với con để xem ảnh gia đình", style: TextStyle(color: Colors.grey))),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('images')
          .where('userId', isEqualTo: childId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 350, child: Center(child: CircularProgressIndicator()));
        final List<QueryDocumentSnapshot> docs = snapshot.data?.docs.toList() ?? [];
        if (docs.isEmpty) return Container(height: 350, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text("Đang chờ ảnh từ con...")));

        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        _timer?.cancel(); 
        _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
          if (_currentPage < docs.length - 1) _currentPage++; else _currentPage = 0;
          if (_pageController.hasClients) {
            _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
          }
        });

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ImageGalleryPage(childId: childId))),
          child: SizedBox(
            height: 350,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                itemCount: docs.length,
                onPageChanged: (index) => _currentPage = index,
                itemBuilder: (context, index) {
                  final String base64Str = (docs[index].data() as Map<String, dynamic>)['base64String'] ?? '';
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
