import 'package:antam_app/create_medicine.dart';
import 'package:flutter/material.dart';

class ChildrenHomePage extends StatefulWidget {
  const ChildrenHomePage({Key? key}) : super(key: key);

  @override
  State<ChildrenHomePage> createState() => _ChildrenHomePageState();
}

class _ChildrenHomePageState extends State<ChildrenHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Column(
          children: [
            _warningCard(),
            _userInfo(),

            _sectionHeader(
              title: "TRẠNG THÁI UỐNG THUỐC",
              onAdd: () {
                debugPrint("Thêm thuốc");
              },
            ),
            _medicineCard("Thuốc huyết áp", "Đã uống lúc 08:00", true),
            _medicineCard("Thuốc tiểu đường", "Chưa uống", false),

            _sectionHeader(
              title: "LỊCH TÁI KHÁM",
              onAdd: () {
                debugPrint("Thêm lịch tái khám");
              },
            ),
            _reExaminationCard(),

            _sectionHeader(title: "LỊCH SỬ CHECK-IN"),
            _checkinCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
            // đang ở home
              break;
            case 1:
              debugPrint("Sang thống kê");
              break;
            case 2:
              debugPrint("Sang thư viện ảnh");
              break;
            case 3:
              debugPrint("Sang tin nhắn");
              break;
            case 4:
              debugPrint("Sang cài đặt");
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }

  // ================= COMPONENTS =================

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
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFC1A8),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bố: Nguyễn Văn A",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tuổi: 80"),
            ],
          ),
          const Spacer(),
          _smallAvatar(),
          Transform.translate(offset: const Offset(-10, 0), child: _smallAvatar()),
        ],
      ),
    );
  }

  Widget _smallAvatar() {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: Color(0xFFFFC1A8),
      child: Icon(Icons.person, size: 14, color: Colors.white),
    );
  }

  Widget _sectionHeader({required String title, VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
            IconButton(
              icon: const Icon(Icons.add, size: 26),
              onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateMedicinePage()
                  ),
                );
              },
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
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(status),
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
            Icon(Icons.calendar_month),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hẹn khám tim mạch",
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFFFA387)),
                  ),
                  const Text(
                    "100%",
                    style:
                    TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tuân thủ tháng này",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA387),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Xem chi tiết",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
