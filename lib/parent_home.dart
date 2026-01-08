import 'dart:async';
import 'dart:convert';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:antam_app/image_gallery.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Hàm xử lý SOS
  Future<void> _handleSOS(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.userModel;
    
    // 1. Giả định lấy số điện thoại người con từ database
    // Trong thực tế, bạn cần lưu phone của người con vào userModel hoặc một bảng liên kết
    const String childPhoneNumber = "0123456789"; // Thay bằng số thật hoặc lấy từ DB

    // 2. Kích hoạt cuộc gọi GSM (Không cần data)
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: childPhoneNumber,
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể thực hiện cuộc gọi GSM")),
        );
      }
    }

    // 3. Gửi thông báo khẩn cấp lên Firestore (Cần data - để app con hiện cảnh báo)
    try {
      await FirebaseFirestore.instance.collection('sos_alerts').add({
        'from': user?.name ?? "Cha/Mẹ",
        'fromId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      debugPrint("Lỗi gửi tín hiệu SOS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- SLIDESHOW ẢNH GIA ĐÌNH ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('images')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 386,
                      height: 386,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      width: 386,
                      height: 386,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage("https://picsum.photos/386"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(child: Text("Chưa có ảnh nào")),
                    );
                  }

                  _timer ??= Timer.periodic(const Duration(seconds: 3), (Timer timer) {
                    if (_currentPage < docs.length - 1) {
                      _currentPage++;
                    } else {
                      _currentPage = 0;
                    }

                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        _currentPage,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  });

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ImageGalleryPage()),
                      );
                    },
                    child: SizedBox(
                      width: 386,
                      height: 386,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: docs.length,
                          onPageChanged: (index) => _currentPage = index,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final String base64Str = data['base64String'] ?? '';
                            return Image.memory(
                              base64Decode(base64Str),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 87),
              
              // --- NÚT SOS KHẨN CẤP ---
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: () => _handleSOS(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF94133),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SOS KHẨN CẤP',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              
              // --- NÚT GỌI ---
              SizedBox(
                width: double.infinity,
                height: 88,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic nút gọi bình thường có thể dùng lại tel: nhưng số khác
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF78EC46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 48),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
