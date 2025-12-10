import 'package:flutter/material.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  // Widget thanh điều hướng dưới cùng
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Home (Đã chọn)
          IconButton(
            icon: const Icon(Icons.home, size: 40, color: Colors.blue),
            onPressed: () {},
          ),

          // Dòng chia (Tạo hiệu ứng đường kẻ giữa các icon)
          Transform.rotate(
            angle: 1.55, // Xoay 90 độ
            child: Container(width: 59, height: 1, color: Colors.grey.shade400),
          ),

          // Icon Send (Chưa chọn)
          IconButton(
            icon: const Icon(Icons.send, size: 40, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'PARENT HOME',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          // Padding ngang 22 để khớp với Positioned(left: 22) ban đầu
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- HÌNH ẢNH GIA ĐÌNH ---
              // Sử dụng NetworkImage placeholder hoặc ảnh thật
              Container(
                width: 386, // Giữ kích thước cố định để khớp với thiết kế
                height: 386,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    // Sử dụng ảnh gia đình thật hoặc NetworkImage placeholder
                    image: NetworkImage("https://picsum.photos/386"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(
                height: 87,
              ), // Khoảng cách giữa ảnh và nút SOS (593 - 120 - 386 = 87)
              // --- NÚT SOS KHẨN CẤP (Red SOS Button) ---
              SizedBox(
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện SOS
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF94133), // Màu đỏ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SOS KHẨN CẤP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10), // Khoảng cách giữa 2 nút
              // --- NÚT GỌI (Green Call Button) ---
              SizedBox(
                width: double.infinity,
                height: 88,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện Gọi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF78EC46), // Màu xanh lá
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 48),
                ),
              ),

              const SizedBox(height: 50), // Khoảng trống trước Nav Bar
            ],
          ),
        ),
      ),

      // --- THANH ĐIỀU HƯỚNG DƯỚI (Bottom Navigation Bar) ---
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}
