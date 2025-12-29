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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "SETTING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                  backgroundColor: Color(0xFFFFC1A8),
                  child: Icon(Icons.person, size: 45, color: Colors.white),
                ),
                SizedBox(width: 20),
                Text(
                  "Nguyễn Văn A",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),

            const SizedBox(height: 25),

            // Container menu
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.info_outline, "Thông tin tài khoản"),
                  _buildMenuItem(Icons.lock_outline, "Bảo mật"),
                  _buildMenuItem(Icons.language, "Ngôn ngữ"),
                  _buildMenuItem(Icons.notifications_none, "Thông báo"),
                  _buildMenuItem(Icons.switch_account_outlined, "Đổi vai trò"),
                  _buildMenuItem(Icons.logout, "Đăng xuất", showDivider: false, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo 1 item của menu
  Widget _buildMenuItem(IconData icon, String title, {bool showDivider = true, Color color = Colors.black87}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 0.5),
          ),
      ],
    );
  }
}
