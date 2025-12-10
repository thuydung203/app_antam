import 'package:flutter/material.dart';

class ChildrenHomePage extends StatelessWidget {
  const ChildrenHomePage({Key? key}) : super(key: key);

  // --- HÀM XÂY DỰNG WIDGET CHÍNH ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F8), // Màu nền tổng thể

      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "CHILDREN HOME",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BACK ICON
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Icon(
                Icons.arrow_back_ios,
                size: 28,
                color: Colors.black,
              ), // Đổi sang arrow_back_ios cho đúng phong cách UI
            ),

            // CẢNH BÁO
            _warningCard(),

            // AVATAR + INFO
            _userInfo(),

            // TRẠNG THÁI UỐNG THUỐC
            _sectionHeader("TRẠNG THÁI UỐNG THUỐC"),
            _medicineCard("Thuốc huyết áp", "Đã uống lúc 08:00", true),
            _medicineCard("Thuốc tiểu đường", "Chưa uống", false),

            // LỊCH TÁI KHÁM
            _sectionHeader("LỊCH TÁI KHÁM"),
            _reExaminationCard(),

            // CHECK-IN
            _sectionHeader("LỊCH SỬ CHECK-IN"),
            _checkinCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  // --------------------------------------------------------
  // WIDGETS
  // --------------------------------------------------------

  Widget _warningCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0C2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.error,
              color: Color(0xE5ED3333),
              size: 20,
            ), // Dùng màu đỏ đậm theo thiết kế trước đó
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Cảnh báo! Cha mẹ chưa xác nhận lịch uống thuốc Huyết áp sáng.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD2D2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 28, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Text info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Bố: Nguyễn Văn A",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text("Tuổi: 80", style: TextStyle(fontSize: 14)),
            ],
          ),

          const Spacer(),

          // Người giám sát
          Row(
            children: [
              _smallAvatar(),
              Transform.translate(
                offset: const Offset(-10, 0),
                child: _smallAvatar(),
              ),
              // Bỏ bớt avatar thứ 3 hoặc chồng lên nhau chính xác hơn
              // Transform.translate(
              //   offset: Offset(-20, 0),
              //   child: _smallAvatar(),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD2D2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 16, color: Colors.white),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          // Chỉ hiển thị icon + cho TRẠNG THÁI UỐNG THUỐC và LỊCH TÁI KHÁM
          if (text == "TRẠNG THÁI UỐNG THUỐC" || text == "LỊCH TÁI KHÁM")
            const Icon(Icons.add, size: 26),
        ],
      ),
    );
  }

  Widget _medicineCard(String name, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 14)),
              ],
            ),
            Icon(
              done ? Icons.check_circle : Icons.cancel,
              color: done ? Colors.green : Colors.red,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reExaminationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 30, color: Colors.black87),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hẹn khám tim mạch",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text("Thứ 2, 8/12/2025", style: TextStyle(fontSize: 14)),
              ],
            ),

            const Spacer(),
            const Icon(Icons.favorite, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // SỬA ĐỔI _checkinCard để vòng tròn TO hơn và đúng style
  // ---------------------------
  Widget _checkinCard() {
    const double circleSize = 120.0; // Tăng kích thước vòng tròn (theo yêu cầu)
    const double strokeWidth = 8.0; // Độ dày viền
    const Color progressColor = Color(0xFFFFA387); // Màu cam/hồng nhạt

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vòng tròn đẹp hơn (Stack 2 lớp)
            SizedBox(
              width: circleSize,
              height: circleSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lớp 1: CircularProgressIndicator (Tạo viền tiến độ)
                  CircularProgressIndicator(
                    value: 1, // 100%
                    strokeWidth: strokeWidth,
                    backgroundColor: Colors.transparent, // Không có nền
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      progressColor,
                    ),
                  ),

                  // Lớp 2: Container/Text (Tạo nền trắng và viền mỏng bên ngoài)
                  Container(
                    width: circleSize - strokeWidth,
                    height: circleSize - strokeWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: progressColor.withOpacity(
                          0.5,
                        ), // Viền mỏng bên ngoài
                        width: 5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "100%",
                        style: TextStyle(
                          fontSize: 28, // Font to hơn
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Text + Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tuân thủ tháng này",
                    style: TextStyle(
                      fontSize: 20, // Tăng font size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progressColor, // Màu cam nhạt
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Bo góc nhiều hơn
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Xem chi tiết",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ), // Tăng font size
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      elevation: 10,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 32), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, size: 28),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.image, size: 28), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.send, size: 28), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 28),
          label: '',
        ),
      ],
    );
  }
}
