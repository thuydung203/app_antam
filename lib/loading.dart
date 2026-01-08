import 'package:antam_app/main_navigation.dart';
import 'package:antam_app/parent_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // Hide the conflicting AuthProvider
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
    // Chờ 2 giây để hiển thị logo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Lấy AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 1. Kiểm tra Firebase Auth xem có user đang đăng nhập không
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // CHƯA ĐĂNG NHẬP -> Về trang Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      // ĐÃ ĐĂNG NHẬP -> Kiểm tra dữ liệu UserModel từ Firestore
      // AuthProvider của bạn đã có logic tải userModel trong hàm _init()
      
      // Đợi một chút để AuthProvider load xong dữ liệu từ Firestore
      int retry = 0;
      while (authProvider.userModel == null && retry < 5) {
        await Future.delayed(const Duration(milliseconds: 500));
        retry++;
      }

      final userModel = authProvider.userModel;

      if (userModel == null) {
        // Nếu đã có Firebase User nhưng không lấy được dữ liệu Firestore
        // Có thể là chưa chọn Role sau khi đăng ký
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      } else {
        // Đã có đầy đủ thông tin -> Vào trang tương ứng với Role
        if (userModel.role == "child") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ParentNavigation()),
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
