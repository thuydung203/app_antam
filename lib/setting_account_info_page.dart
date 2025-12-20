import 'package:flutter/material.dart';
// Import các trang để điều hướng
import 'package:antam_app/children_home.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/add_images.dart';
import 'package:antam_app/setting.dart'; // Giả sử file setting của bạn tên này

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  // Trang này thuộc luồng của Setting, nên chúng ta giữ index là 4
  final int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7f7),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông tin tài khoản",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 55, color: Colors.black54),
            ),

            const SizedBox(height: 12),

            const Text(
              "Nguyễn Văn A",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 30),

            // Số điện thoại
            _buildLabel("Số điện thoại"),
            _buildInputBox(
              value: "+8485248736",
              rightIcon: Icons.phone_in_talk,
            ),

            const SizedBox(height: 20),

            // Email
            _buildLabel("Email liên hệ"),
            _buildInputBox(value: "....@gmail.com", rightIcon: Icons.mail),

            const SizedBox(height: 20),

            // Địa chỉ
            _buildLabel("Địa chỉ khác"),
            _buildInputBox(value: "Số nhà 10, đường ABC, TP. Hà Nội"),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ===== BOTTOM NAV (Đã đồng bộ hoàn toàn) =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) {
            // Nếu đang ở Account Info (vốn thuộc Setting) mà nhấn lại Setting,
            // có thể quay về trang Setting chính
            Navigator.pop(context);
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
              Navigator.pop(context); // Quay lại trang Setting
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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInputBox({required String value, IconData? rightIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
          if (rightIcon != null) Icon(rightIcon, size: 25, color: Colors.green),
        ],
      ),
    );
  }
}
