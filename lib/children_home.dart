import 'package:flutter/material.dart';
// import 'package:antam_app/create_medicine.dart'; // Đảm bảo file này tồn tại

class ChildrenHomePage extends StatefulWidget {
  const ChildrenHomePage({Key? key}) : super(key: key);

  @override
  State<ChildrenHomePage> createState() => _ChildrenHomePageState();
}

class _ChildrenHomePageState extends State<ChildrenHomePage> {
  int _currentIndex = 0;

  // Danh sách các trang để chuyển đổi khi nhấn BottomNavigationBar
  final List<Widget> _pages = [
    const HomeMainContent(), // Trang chủ (Nội dung chính bạn đã viết)
    const Center(child: Text("Trang Thống Kê")),
    const Center(child: Text("Trang Thư Viện Ảnh")),
    const Center(child: Text("Trang Tin Nhắn")),
    const Center(child: Text("Trang Cài Đặt")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),

      // Sử dụng IndexedStack để giữ trạng thái các trang (không bị load lại từ đầu)
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed, // Cố định vị trí cho 5 items
        selectedItemColor: Colors.blue, // Màu khi được chọn
        unselectedItemColor: Colors.grey, // Màu khi không chọn
        showSelectedLabels: false, // Ẩn text để giao diện sạch hơn
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
          BottomNavigationBarItem(icon: Icon(Icons.send, size: 28), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}

// Tách nội dung chính của trang Home ra một Widget riêng để code sạch sẽ hơn
class HomeMainContent extends StatelessWidget {
  const HomeMainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _warningCard(),
            _userInfo(),

            _sectionHeader(
              context,
              title: "TRẠNG THÁI UỐNG THUỐC",
              onAdd: () {
                debugPrint("Mở trang thêm thuốc");
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateMedicinePage()));
              },
            ),
            _medicineCard("Thuốc huyết áp", "Đã uống lúc 08:00", true),
            _medicineCard("Thuốc tiểu đường", "Chưa uống", false),

            _sectionHeader(
              context,
              title: "LỊCH TÁI KHÁM",
              onAdd: () => debugPrint("Thêm lịch tái khám"),
            ),
            _reExaminationCard(),

            _sectionHeader(context, title: "LỊCH SỬ CHECK-IN"),
            _checkinCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS (WIDGETS) =================

  Widget _warningCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE6A7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Cảnh báo! Cha mẹ chưa xác nhận lịch uống thuốc Huyết áp sáng.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFFFC1A8),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bố: Nguyễn Văn A",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Tuổi: 80"),
            ],
          ),
          const Spacer(),
          _smallAvatar(Colors.blue),
          Transform.translate(
            offset: const Offset(-10, 0),
            child: _smallAvatar(Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _smallAvatar(Color color) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: color.withOpacity(0.5),
      child: const Icon(Icons.person, size: 14, color: Colors.white),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 26),
              onPressed: onAdd,
            ),
        ],
      ),
    );
  }

  Widget _medicineCard(String name, String status, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(color: done ? Colors.green : Colors.grey),
                ),
              ],
            ),
            Icon(
              done ? Icons.check_circle : Icons.cancel,
              color: done ? Colors.green : Colors.red,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reExaminationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const [
            Icon(Icons.calendar_month, color: Colors.blue),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hẹn khám tim mạch",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Thứ 2, 8/12/2025"),
              ],
            ),
            Spacer(),
            Icon(Icons.favorite, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _checkinCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA387)),
                  ),
                  const Text(
                    "100%",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tuân thủ tháng này",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA387),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Xem chi tiết",
                      style: TextStyle(color: Colors.white),
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
}
