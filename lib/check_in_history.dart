import 'package:flutter/material.dart';

class CheckInHistoryPage extends StatelessWidget {
  const CheckInHistoryPage({super.key});

  // Widget riêng để xây dựng từng ô ngày trong lịch
  Widget _buildDayCell(String day, bool isChecked) {
    return Column(
      // Sửa lỗi Overflow: Căn giữa và giảm kích thước các thành phần.
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon Check (Nếu đã check-in) - Giảm size từ 28 xuống 20
        if (isChecked)
          const Icon(Icons.check_circle, color: Colors.green, size: 20)
        else
          // SizedBox giữ khoảng cách tương ứng với kích thước Icon
          const SizedBox(height: 20),

        // Ngày (Giảm font size từ 20 xuống 16 và cố định height)
        Text(
          day,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.0, // Đảm bảo chiều cao dòng không bị giãn nở
          ),
        ),
      ],
    );
  }

  // Widget xây dựng toàn bộ phần Lịch
  Widget _buildCalendar() {
    // Dữ liệu ngày (T2 bắt đầu từ ngày 1)
    const List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    // 31 ngày của Tháng 12/2025
    const List<String> days = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '29',
      '30',
      '31',
    ];

    // Trạng thái check-in (true = Đã check-in)
    const List<bool> checkInStatus = [
      true, true, true, true, true, true, false, // Ngày 1-7
      false, false, false, false, false, false, false, // Ngày 8-14
      false, false, false, false, false, false, false,
      false, false, false, false, false, false, false,
      false, false, false,
    ];

    return Column(
      children: [
        // Hàng Tiêu đề Ngày trong tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map(
                (day) => Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 10),

        // Lưới Ngày
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 18.0,
            crossAxisSpacing: 18.0,
            childAspectRatio: 1.0, // Tỷ lệ 1:1 cho mỗi ô
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final status = index < checkInStatus.length
                ? checkInStatus[index]
                : false;

            return _buildDayCell(day, status);
          },
        ),
      ],
    );
  }

  // Widget xây dựng Tỉ lệ tuân thủ và Thanh Progress
  Widget _buildComplianceSection(int percentage) {
    const Color activeColor = Color(0xFFFFA694); // Màu cam đậm
    const Color inactiveColor = Color(0x66FFD7C2); // Màu cam nhạt

    return Container(
      padding: const EdgeInsets.all(20),
      // Giảm padding ngang của Container để khớp với thiết kế.
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFCEBF), // Màu nền tổng thể cho section
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tỉ lệ tuân thủ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Thanh tiến trình
          Stack(
            children: [
              // Thanh nền (inactive)
              Container(
                width: double.infinity,
                height: 37,
                decoration: BoxDecoration(
                  color: inactiveColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // Thanh tiến trình (active)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * (percentage / 100),
                    height: 37,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- TIÊU ĐỀ ---
              const Center(
                child: Text(
                  'LỊCH SỬ CHECK-IN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- THÁNG ---
              const Text(
                'Tháng 12/2025',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // --- LỊCH ---
              _buildCalendar(),

              const SizedBox(height: 50),

              // --- TỈ LỆ TUÂN THỦ VÀ THANH PROGRESS ---
              _buildComplianceSection(80),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
