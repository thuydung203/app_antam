import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 500,   // chỉnh số này để ảnh TO lên
              child: Image.asset(
                "assets/images/logo_removeBG.png",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 8),   // khoảng cách sát
            const Text(
              'KẾT NỐI YÊU THƯƠNG',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

    );
  }
}
