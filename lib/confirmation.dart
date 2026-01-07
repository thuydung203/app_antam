import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  // Thông điệp xác nhận tùy chỉnh
  final String confirmationMessage;
  
  const ConfirmationPage({
    super.key,
    this.confirmationMessage = 'HOÀN TẤT! CON ĐÃ NHẬN ĐƯỢC THÔNG BÁO. CẢM ƠN MẸ ❤️',
  });

  @override
  Widget build(BuildContext context) {
    // Kích thước màn hình hiện tại
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Thanh tiêu đề (AppBar)
      appBar: AppBar(
        title: const Text(
          'Confirmation', 
          style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Bỏ đổ bóng
        // Không cần nút back vì đây là trang cuối của một luồng
        automaticallyImplyLeading: false, 
      ),
      
      // Thân trang (Body)
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            // Căn giữa theo chiều dọc
            mainAxisAlignment: MainAxisAlignment.center,
            // Căn các thành phần vào giữa
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: <Widget>[
              // Tiêu đề chính
              const Text(
                'XÁC NHẬN THÀNH CÔNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),

              // Biểu tượng dấu tích lớn
              Container(
                width: size.width * 0.3,
                height: size.width * 0.3,
                decoration: const BoxDecoration(
                  color: Colors.green, // Màu nền xanh lá
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 80, 
                ),
              ),
              const SizedBox(height: 50),

              // Thông báo tùy chỉnh (Khung màu hồng)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 230, 230, 1), // Màu hồng nhạt/be
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Text(
                  confirmationMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade800, // Màu chữ xanh lá đậm
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              
              // Đẩy các thành phần lên giữa màn hình
              const Spacer(), 
            ],
          ),
        ),
      ),
      
      // Thanh điều hướng dưới cùng (Bottom Navigation Bar)
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
  
  // Hàm xây dựng Bottom Navigation Bar
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 60, 
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, true), // Icon Home đang hoạt động
          const VerticalDivider(width: 1, color: Colors.grey),
          _buildNavBarItem(Icons.send, false), // Icon Send không hoạt động
        ],
      ),
    );
  }
  
  // Hàm xây dựng từng Item trong NavBar
  Widget _buildNavBarItem(IconData icon, bool isActive) {
    return Expanded(
      child: IconButton(
        icon: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.blue : Colors.grey.shade400,
        ),
        onPressed: () {
          // Thêm logic điều hướng tại đây
        },
      ),
    );
  }
}

// --- Ví dụ cách sử dụng trong hàm main ---
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Hiển thị trang xác nhận
      home: ConfirmationPage(), 
    );
  }
}
*/
