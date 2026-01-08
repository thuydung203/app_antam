import 'package:antam_app/main_navigation.dart';
import 'package:antam_app/parent_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'login.dart';
import 'roleselection.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Chờ một chút để logo hiện ra và Firebase kịp khởi tạo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 1. Trường hợp chưa đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      // 2. Trường hợp đã đăng nhập -> Phải lấy được userModel từ DB
      int retry = 0;
      while (authProvider.userModel == null && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retry++;
      }

      final userModel = authProvider.userModel;

      // 3. Kiểm tra vai trò thực tế từ Database
      if (userModel == null || userModel.role == 'none' || userModel.role == '') {
        // Nếu chưa chọn vai trò hoặc không lấy được dữ liệu -> Vào trang chọn vai trò
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      } else {
        // 4. Đã có vai trò cố định -> Vào trang tương ứng
        if (userModel.role == "child") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else if (userModel.role == "parent") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ParentNavigation()),
          );
        } else {
          // Trường hợp phòng hờ giá trị không hợp lệ
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: Image.asset(
                "assets/images/logo_removeBG.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.favorite, size: 100, color: Color(0xFFFFA387)),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA387)),
            ),
          ],
        ),
      ),
    );
  }
}
