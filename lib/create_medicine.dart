import 'package:flutter/material.dart';

class CreateMedicinePage extends StatelessWidget {
  const CreateMedicinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Sử dụng Stack và Positioned với kích thước cố định (428x926)
    // sẽ khiến giao diện bị vỡ (non-responsive) trên các thiết bị khác.
    return Scaffold(
      body: Container(
        width: 428,
        height: 926,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCEBF),
        ), // Màu nền cam nhạt
        child: Stack(
          children: [
            // Phần trên (Top Banner) - Ảnh nền
            Positioned(
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
            // Tiêu đề
            const Positioned(
              left: 25,
              top: 10,
              child: Text(
                'CREATE MEDICINE',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Icon </>
            const Positioned(
              right: 10,
              top: 10,
              child: Icon(Icons.code, color: Colors.white),
            ),

            // Phần dưới (Modal/Container Trắng)
            Positioned(
              left: -10,
              top: 354,
              child: Container(
                width: 446,
                height: 613,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),

            // Icon Đóng (X)
            const Positioned(
              left: 30,
              top: 380,
              child: Icon(Icons.close, size: 38),
            ),
            // Icon Xác nhận (Tick)
            const Positioned(
              right: 30,
              top: 380,
              child: Icon(Icons.check, size: 38, color: Colors.green),
            ),

            // Icon Tạo lịch uống thuốc (Viên thuốc)
            Positioned(
              left: 170, // Căn giữa
              top: 425,
              child: Stack(
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  // Thêm icon '+' nhỏ ở góc để mô phỏng "thêm"
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_circle,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tiêu đề "Tạo lịch uống thuốc"
            const Positioned(
              left: 85,
              top: 524,
              child: Text(
                'Tạo lịch uống thuốc',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Input Tên thuốc
            Positioned(
              left: 48,
              top: 574,
              child: Container(
                width: 332,
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFCEBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Nhập tên thuốc...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // --- CỘT CHỌN GIỜ ---

            // Vùng chứa (để dễ dàng căn chỉnh sau này)
            Positioned(
              left: 47,
              top: 676,
              child: Container(
                width: 332,
                height: 30,
                // Màu nền tạm thời cho vùng đang chọn
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
              left: 110,
              top: 649,
              child: _TimePickerColumn(
                top: '10',
                middle: '11',
                bottom: '12',
                isMiddleBold: true,
              ),
            ),
            // Column 2 (Phút)
            Positioned(
              left: 190,
              top: 649,
              child: _TimePickerColumn(
                top: '10',
                middle: '11',
                bottom: '12',
                isMiddleBold: true,
              ),
            ),
            // Column 3 (SA/CH)
            Positioned(
              left: 255,
              top: 649,
              child: _TimePickerColumn(
                top: '',
                middle: 'SA',
                bottom: 'CH',
                isMiddleBold: true,
              ),
            ),

            // --- CÁC THIẾT LẬP KHÁC ---

            // Lặp lại
            const Positioned(
              left: 63,
              top: 812,
              child: Text(
                'Lặp lại',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              left: 243,
              top: 812,
              child: Opacity(
                opacity: 0.40,
                child: Text(
                  'Ngày thường',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            // Icon mũi tên (Ngày thường)
            const Positioned(
              left: 340,
              top: 816,
              child: Opacity(
                opacity: 0.30,
                child: Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),

            // Âm thanh
            const Positioned(
              left: 63,
              top: 853,
              child: Text(
                'Âm thanh',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              left: 273,
              top: 853,
              child: Opacity(
                opacity: 0.40,
                child: Text(
                  'Ting ting',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            // Icon mũi tên (Âm thanh)
            const Positioned(
              left: 339,
              top: 857,
              child: Opacity(
                opacity: 0.30,
                child: Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),

            // Dòng kẻ phân cách
            Positioned(
              left: 59,
              top: 842,
              child: Opacity(
                opacity: 0.20,
                child: Container(width: 320, height: 1, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget nhỏ để mô phỏng cột chọn giờ
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
