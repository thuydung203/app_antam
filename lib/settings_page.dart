import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        title: const Text("Cài đặt", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFILE CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFFFC1A8),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userModel?.name ?? "Người dùng",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userModel?.email ?? "Email chưa cập nhật",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE2DE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          userModel?.role.toUpperCase() ?? "UNKNOWN",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SETTINGS GROUPS
          _buildSectionHeader("Tài khoản"),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: "Chỉnh sửa thông tin",
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.notifications_none,
            title: "Thông báo",
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: "Đổi mật khẩu",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _buildSectionHeader("Ứng dụng"),
          _buildSettingItem(
            icon: Icons.language,
            title: "Ngôn ngữ",
            trailing: "Tiếng Việt",
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: "Trợ giúp & Hỗ trợ",
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: "Về chúng tôi",
            onTap: () {},
          ),

          const SizedBox(height: 40),

          // LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                authProvider.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: const BorderSide(color: Colors.redAccent, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text("Đăng xuất", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 15),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              if (trailing != null)
                Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
