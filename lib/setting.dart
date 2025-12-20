import 'package:flutter/material.dart';
// Đảm bảo các đường dẫn import này đúng với cấu trúc project của bạn
import 'package:antam_app/children_home.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/add_images.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Ở trang Setting, index đang hoạt động là 4
  final int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7f7),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SETTING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),

      // ===== BODY =====
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Avatar + Name
            const Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, size: 45, color: Colors.black54),
                ),
                SizedBox(width: 20),
                Text(
                  "Nguyễn Văn A",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Container menu
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.info, "Thông tin tài khoản"),
                  _buildMenuItem(Icons.lock, "Bảo mật"),
                  _buildMenuItem(Icons.language, "Ngôn ngữ"),
                  _buildMenuItem(Icons.notifications, "Thông báo"),
                  _buildMenuItem(Icons.switch_account, "Đổi vai trò"),
                  _buildMenuItem(Icons.logout, "Đăng xuất", showDivider: false),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV (Đồng bộ với các trang khác) =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildrenHomePage(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckInHistoryPage(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddImage()),
              );
              break;
            case 3:
              debugPrint("Chuyển hướng sang trang GPS/Định vị");
              break;
            case 4:
              // Đang ở trang Setting
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.image, size: 28), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }

  // Widget tạo 1 item của menu
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: () => debugPrint("Nhấn vào $title"),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 0.5),
            ),
        ],
      ),
    );
  }
}
