import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/auth_provider.dart';
import 'confirmation.dart';

class AlarmClockPage extends StatelessWidget {

  final String alarmTime;
  final String reminderText;
  final String? medicineId;

  const AlarmClockPage
  ({
    super.key,
    this.alarmTime = '08:00', // Giờ báo thức mặc định
    this.reminderText = 'Đến giờ uống thuốc', // Thông báo mặc định
    this.medicineId,
  });

  @override
  Widget build(BuildContext context) {
    // Kích thước màn hình hiện tại
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm clock', 
          style: TextStyle(color: Colors.blue, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0, 
        // Icon code snippet ở góc phải (chỉ mang tính minh họa UI)
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.code, color: Colors.grey),
          ),
        ],
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: <Widget>[
              // --- 1. Khu vực Đồng hồ mô phỏng ---
              SizedBox(
                width: size.width * 0.5,
                height: size.width * 0.5,
                // Sử dụng CustomPaint để vẽ hình đồng hồ mô phỏng
                child: CustomPaint(
                  painter: ClockPainter(
                    // Lựa chọn màu xanh dương nhạt cho đường viền
                    borderColor: Colors.lightBlue.shade300, 
                  ),
                  child: const Center(
                    child: SizedBox.shrink(), // Không có nội dung bên trong
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. Giờ báo thức ---
              Text(
                alarmTime,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // --- 3. Thông báo nhắc nhở ---
              Text(
                reminderText,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 60),

              // --- 4. Nút Hành động "ĐÃ UỐNG THUỐC" (Màu vàng) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (medicineId != null) {
                      final userId = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
                      if (userId != null) {
                        await DatabaseService().confirmMedicineIntake(medicineId!, userId);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ConfirmationPage()),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Xác nhận đã uống thuốc!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700, // Màu vàng đậm
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'ĐÃ UỐNG THUỐC',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- 5. Nút Hành động "Dừng" (Màu xám) ---
              SizedBox(
                width: size.width * 0.4, // Kích thước nhỏ hơn nút trên
                child: TextButton(
                  onPressed: () {
                    // Xử lý khi nhấn Dừng/Tắt báo thức
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã dừng báo thức.')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade300, 
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Dừng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              
              const Spacer(), 
            ],
          ),
        ),
      ),
      
      // --- 6. Thanh điều hướng dưới cùng (Bottom Navigation Bar) ---
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
  
  // Hàm xây dựng Bottom Navigation Bar (tương tự như các trang trước)
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
          _buildNavBarItem(Icons.home, true), 
          const VerticalDivider(width: 1, color: Colors.grey),
          _buildNavBarItem(Icons.send, false), 
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

// Custom Painter để vẽ hình Đồng hồ mô phỏng đơn giản
class ClockPainter extends CustomPainter {
  final Color borderColor;

  ClockPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vẽ Vòng tròn ngoài (border)
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3; 

    canvas.drawCircle(center, radius, paintBorder);

    // Vẽ Kim đồng hồ (giả lập vị trí 8:00)
    final paintHand = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    // Kim giờ (hướng 8 giờ)
    final hourX = center.dx + 0.3 * radius * cos(270 * pi / 180 + (8 / 12) * 2 * pi);
    final hourY = center.dy + 0.3 * radius * sin(270 * pi / 180 + (8 / 12) * 2 * pi);
    canvas.drawLine(center, Offset(hourX, hourY), paintHand);

    // Kim phút (hướng 12 giờ)
    final minuteX = center.dx + 0.5 * radius * cos(270 * pi / 180);
    final minuteY = center.dy + 0.5 * radius * sin(270 * pi / 180);
    canvas.drawLine(center, Offset(minuteX, minuteY), paintHand);

    // Dấu chấm ở giữa
    canvas.drawCircle(center, 4, Paint()..color = borderColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
  
  // Import cần thiết cho toán học
  // import 'dart:math'; 
}

// Lưu ý: Thêm "import 'dart:math';" vào đầu file để sử dụng hàm sin, cos, pi cho ClockPainter
