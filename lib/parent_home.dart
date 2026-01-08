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

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
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

  // FR2.3: Xử lý xác nhận uống thuốc
  Future<void> _handleCheckIn(String medicineId) async {
    await FirebaseFirestore.instance.collection('medicines').doc(medicineId).update({
      'isConfirmed': true,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã báo cho con: Bố/Mẹ đã uống thuốc!")),
      );
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
