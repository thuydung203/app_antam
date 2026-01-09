import 'package:flutter/material.dart';
import 'package:antam_app/services/auth_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() =>
      _SettingSecurityLoginPageState();
}

class _SettingSecurityLoginPageState extends State<SecurityPage> {
  final AuthService _authService = AuthService();
  
  // Trạng thái các Switch
  bool isBiometricLogin = false;
  bool isLoginAlert = true;
  bool isDeviceManagement = true;
  bool isLoginHistory = true;

  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Hàm hiển thị hộp thoại đổi mật khẩu
  void _showChangePasswordDialog() {
    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu hiện tại"),
              ),
              TextField(
                controller: _newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              ),
              TextField(
                controller: _confirmPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newPassCtrl.text != _confirmPassCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mật khẩu mới không khớp")),
                );
                return;
              }
              
              try {
                await _authService.changePassword(
                  _currentPassCtrl.text,
                  _newPassCtrl.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đổi mật khẩu thành công!")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text("Lưu thay đổi"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

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
            // SỬA: Chuyển "Đổi mật khẩu" thành nút nhấn điều hướng
            _buildNavigationTile(
              title: "Đổi mật khẩu",
              onTap: _showChangePasswordDialog,
            ),
            
            _buildNavigationTile(
              title: "Đăng nhập bằng sinh trắc học",
              onTap: () {},
            ),
          ],
        ),
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

  Widget _buildNavigationTile({
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Sửa từ symmetric(bottom: 12) thành only(bottom: 12)
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
