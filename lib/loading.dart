import 'package:antam_app/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import màn hình
import 'login.dart';
import 'roleselection.dart';
import 'parent_home.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Giả sử mặc định là chưa login để test, bạn có thể sửa lại logic này sau
      bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
      String? role = prefs.getString("role"); // 'child' hoặc 'parent'

      // Chờ 2 giây để hiển thị logo
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 1. Nếu chưa đăng nhập -> Về trang Login
      if (!isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      // 2. Nếu đã đăng nhập nhưng chưa chọn vai trò -> Về trang Role Selection
      if (role == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
        return;
      }

      // 3. Nếu vai trò là CON -> Vào hệ thống tab chính
      if (role == "child") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
        return;
      }

      // 4. Nếu vai trò là CHA MẸ -> Vào trang chủ cha mẹ
      if (role == "parent") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParentHomePage()),
        );
        return;
      }
    } catch (e) {
      debugPrint("Lỗi loading: $e");
      // Nếu có lỗi, mặc định về trang Login cho an toàn
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
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
              width: 250, // Chỉnh lại kích thước logo cho vừa phải
              child: Image.asset(
                "assets/images/logo_removeBG.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite, size: 100, color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA387)),
            ),
          ],
        ),
      ),
    );
  }
}
