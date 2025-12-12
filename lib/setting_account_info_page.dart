import 'package:flutter/material.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7f7),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            _buildInputBox(
              value: "....@gmail.com",
              rightIcon: Icons.mail,
            ),

            const SizedBox(height: 20),

            // Địa chỉ
            _buildLabel("Địa chỉ khác"),
            _buildInputBox(
              value: "Số nhà 10, đường ABC, TP. Hà Nội",
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 30),
            Icon(Icons.bar_chart, size: 30),
            Icon(Icons.image, size: 30),
            Icon(Icons.navigation, size: 30),
            Icon(Icons.settings, size: 30, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // Label tiêu đề
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Ô hiển thị thông tin
  Widget _buildInputBox({required String value, IconData? rightIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          if (rightIcon != null)
            Icon(rightIcon, size: 25, color: Colors.green),
        ],
      ),
    );
  }
}
