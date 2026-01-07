import 'package:antam_app/setting_account_info_page.dart';
import 'package:flutter/material.dart';
import 'package:antam_app/setting_account_security_page.dart';
import 'package:antam_app/setting_language_page.dart';
import 'package:antam_app/notification_setting_page.dart';
import 'package:antam_app/roleselection.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/login.dart';

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
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFFFC1A8),
                  child: Icon(Icons.person, size: 45, color: Colors.white),
                ),
                SizedBox(width: 20),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final userName = auth.userModel?.name ?? "Người dùng";
                    return Text(
                      userName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.info_outline, 
                    title: "Thông tin tài khoản",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountInfoPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: "Bảo mật",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecurityPage()),
                        );
                      }
                  ),
                  _buildMenuItem(
                      icon: Icons.language,
                      title: "Ngôn ngữ",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LanguagePage()),
                        );
                      }
                  ),
                  _buildMenuItem(
                      icon: Icons.notifications_none,
                      title: "Thông báo",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationPage()),
                          );
                      }
                  ),
                  _buildMenuItem(
                      icon: Icons.switch_account_outlined,
                      title: "Đổi vai trò",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RoleSelectionPage()),
                        );
                      }),
                  _buildMenuItem(
                    icon: Icons.logout, 
                    title: "Đăng xuất", 
                    color: Colors.red,
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false).signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo 1 item của menu
  Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
        ),
      ],
    );
  }
}
