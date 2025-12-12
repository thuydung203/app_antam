import 'package:flutter/material.dart';

class SettingSecurityLoginPage extends StatefulWidget {
  const SettingSecurityLoginPage({super.key});

  @override
  State<SettingSecurityLoginPage> createState() =>
      _SettingSecurityLoginPageState();
}

class _SettingSecurityLoginPageState extends State<SettingSecurityLoginPage> {
  // Trạng thái các Switch
  bool isChangePassword = true;
  bool isBiometricLogin = false;
  bool isLoginAlert = true;
  bool isDeviceManagement = true;
  bool isLoginHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bảo mật và Đăng nhập",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ----------------- Đăng nhập & mật khẩu -------------------
            _buildSectionTitle("Đăng nhập và Mật khẩu"),
            _buildSwitchTile(
              title: "Đổi mật khẩu",
              value: isChangePassword,
              onChanged: (val) => setState(() => isChangePassword = val),
            ),
            _buildNavigationTile(
              title: "Đăng nhập bằng sinh trắc học",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ----------------- Bảo mật nâng cao -------------------
            _buildSectionTitle("Bảo mật nâng cao"),
            _buildSwitchTile(
              title: "Cảnh báo đăng nhập mới",
              value: isLoginAlert,
              onChanged: (val) => setState(() => isLoginAlert = val),
            ),

            const SizedBox(height: 20),

            // ----------------- Hoạt động của tài khoản -------------------
            _buildSectionTitle("Hoạt động của tài khoản"),
            _buildSwitchTile(
              title: "Quản lý thiết bị đăng nhập",
              value: isDeviceManagement,
              onChanged: (val) => setState(() => isDeviceManagement = val),
            ),
            _buildSwitchTile(
              title: "Lịch sử đăng nhập",
              value: isLoginHistory,
              onChanged: (val) => setState(() => isLoginHistory = val),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tiêu đề nhóm
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style:
            const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Ô có switch
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Switch(
            value: value,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }

  // Ô điều hướng (có mũi tên)
  Widget _buildNavigationTile({
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15)),
            const Icon(Icons.arrow_forward_ios, size: 17),
          ],
        ),
      ),
    );
  }
}
