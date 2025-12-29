import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import màn hình của bạn
import 'login.dart';
import 'signup.dart';
import 'roleselection.dart';
import 'parent_home.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    String? role = prefs.getString("role"); // 'child' hoặc 'parent'

    // Chờ 2 giây để hiển thị loading
    await Future.delayed(Duration(seconds: 1));

    // LẦN ĐẦU: CHƯA LOGIN → chuyển Login Page
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    // ĐÃ LOGIN → kiểm tra role đã lưu
    if (role == null) {
      // Nếu chưa chọn role thì đưa về Role Selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RoleSelectionPage()),
      );
      return;
    }

    // // Nếu role = child → vào Add Follow
    // if (role == "child") {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => AddFollowPage()),
    //   );
    //   return;
    // }

    // Nếu role = parent → vào Parent Home
    if (role == "parent") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ParentHomePage()),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 500,
              child: Image.asset(
                "assets/images/logo_removeBG.png",
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
