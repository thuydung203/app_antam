import 'package:flutter/material.dart';
// Import các file cần thiết để điều hướng
import 'package:antam_app/children_home.dart';
import 'package:antam_app/check_in_history.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  // Ở trang Ảnh, index đang hoạt động là 2 (Icon Image/Photo)
  final int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ===== TOP INFO =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/parent.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + Age
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bố: Nguyễn Văn A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tuổi: 80',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Chọn',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.more_horiz, size: 26),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ===== GRID IMAGES =====
            Expanded(
              // Thêm Expanded để GridView có thể cuộn nếu quá dài
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: 20,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/parent.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ===== ADD IMAGE BUTTON =====
            GestureDetector(
              onTap: () => debugPrint('Thêm ảnh'),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 26),
              ),
            ),

            // ===== FOOTER INFO =====
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '23 ảnh, 4 video\nDo Nguyễn Văn B tạo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV (Đã đồng bộ với Home và Check-in) =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildrenHomePage(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckInHistoryPage(),
                ),
              );
              break;
            case 2:
              // Đang ở trang ảnh
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
        showSelectedLabels: false,
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
