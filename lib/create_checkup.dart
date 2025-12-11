import 'package:flutter/material.dart';

class CreateCheckupPage extends StatelessWidget {
  const CreateCheckupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Sử dụng Stack và Positioned với kích thước cố định (428x926)
    // sẽ khiến giao diện bị vỡ (non-responsive) trên các thiết bị khác.
    return Scaffold(
      body: Container(
        width: 428,
        height: 926,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Color(0xFFFFCEBF),
        ), // Màu nền cam nhạt
        child: Stack(
          children: [
            // --- PHẦN BANNER TRÊN (Header) ---

            // Vùng màu hồng nhạt (Overlay)
            Positioned(
              left: 0,
              top: -25,
              child: Opacity(
                opacity: 0.70,
                child: Container(
                  width: 428,
                  height: 525,
                  decoration: ShapeDecoration(
                    color: const Color(0x00D9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
            ),

            // Text "An Tâm, Con"
            const Positioned(
              left: 25,
              top: 40,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'An Tâm, Con\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Xin chào, anh A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text "CREATE CHECKUP" (Header Title)
            const Positioned(
              left: 25,
              top: 10,
              child: Text(
                'CREATE CHECKUP',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            // Icon </>
            const Positioned(
              right: 10,
              top: 10,
              child: Icon(Icons.code, color: Colors.white),
            ),

            // --- PHẦN MODAL TRẮNG (Chức năng) ---
            Positioned(
              left: -10,
              top: 354,
              child: Container(
                width: 446,
                height: 613,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),

            // Icon Đóng (X)
            const Positioned(
              left: 30,
              top: 385,
              child: Icon(Icons.close, size: 38),
            ),

            // Icon Xác nhận (Tick)
            const Positioned(
              right: 30,
              top: 385,
              child: Icon(Icons.check, size: 38, color: Colors.green),
            ),

            // Icon Lịch (Calendar Icon)
            const Positioned(
              left: 149,
              top: 385,
              child: SizedBox(
                width: 130,
                height: 130,
                child: Center(
                  child: Icon(
                    Icons.calendar_month,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Tiêu đề "Tạo lịch hẹn / tái khám"
            const Positioned(
              left: 71,
              top: 524,
              child: Text(
                'Tạo lịch hẹn / tái khám',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Input Lịch hẹn
            Positioned(
              left: 45,
              top: 579,
              child: Container(
                width: 338,
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFCEBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 14, top: 16),
                  child: Opacity(
                    opacity: 0.50,
                    child: Text(
                      'Nhập lịch hẹn....',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- CỘT CHỌN GIỜ (Giống màn hình tạo thuốc) ---

            // Vùng chứa (để dễ dàng căn chỉnh sau này)
            Positioned(
              left: 51,
              top: 670,
              child: Container(
                width: 332,
                height: 30,
                decoration: ShapeDecoration(
                  color: const Color(0x00D9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            // Giờ - Phút - SA/CH (Không phải Picker thực tế, chỉ là Text)
            // Column 1 (Giờ)
            Positioned(
              left: 114,
              top: 643,
              child: _TimePickerColumn(
                top: '10',
                middle: '11',
                bottom: '12',
                isMiddleBold: true,
              ),
            ),
            // Column 2 (Phút)
            Positioned(
              left: 194,
              top: 643,
              child: _TimePickerColumn(
                top: '10',
                middle: '11',
                bottom: '12',
                isMiddleBold: true,
              ),
            ),
            // Column 3 (SA/CH)
            Positioned(
              left: 259,
              top: 643,
              child: _TimePickerColumn(
                top: 'CH',
                middle: 'SA',
                bottom: 'CH',
                isMiddleBold: true,
              ),
            ),

            // Icon mũi tên nhỏ (phần trống)
            const Positioned(
              left: 340,
              top: 816,
              child: Opacity(
                opacity: 0.30,
                child: Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget nhỏ để mô phỏng cột chọn giờ (Được định nghĩa lại ở đây để mã hoạt động độc lập)
class _TimePickerColumn extends StatelessWidget {
  final String top;
  final String middle;
  final String bottom;
  final bool isMiddleBold;

  const _TimePickerColumn({
    required this.top,
    required this.middle,
    required this.bottom,
    this.isMiddleBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top - Nhạt
        Text(
          top,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w100,
          ),
        ),
        // Middle - Đậm
        const SizedBox(height: 5),
        Text(
          middle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontFamily: 'Inter',
            fontWeight: isMiddleBold ? FontWeight.w600 : FontWeight.w100,
          ),
        ),
        // Bottom - Nhạt
        const SizedBox(height: 5),
        Text(
          bottom,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }
}
