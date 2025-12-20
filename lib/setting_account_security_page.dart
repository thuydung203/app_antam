import 'package:flutter/material.dart';
// Import các trang để điều hướng
import 'package:antam_app/children_home.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/add_images.dart';
import 'package:antam_app/setting.dart';

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

  // Index cho Setting vẫn là 4
  final int _currentIndex = 4;

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

      // ===== BOTTOM NAV (Đã đồng bộ) =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) {
            Navigator.pop(context); // Quay lại trang Setting chính
            return;
          }

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
              debugPrint("Sang trang Navigation/GPS");
              break;
            case 4:
              Navigator.pop(context);
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Giảm vertical để cân đối với Switch
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
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
            const Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
