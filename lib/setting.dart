import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7f7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          "SETTING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Avatar + Name
            Row(
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, size: 45, color: Colors.black54),
                ),
                SizedBox(width: 20),
                Text(
                  "Nguyễn Văn A",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            ),

            const SizedBox(height: 25),

            // Container menu
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
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

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 30),
            Icon(Icons.bar_chart, size: 30),
            Icon(Icons.image, size: 30),
            Icon(Icons.navigation, size: 30),
            Icon(Icons.settings, size: 30, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // Widget tạo 1 item của menu
  Widget _buildMenuItem(IconData icon, String title, {bool showDivider = true}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 26, color: Colors.black87),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}
