import 'package:flutter/material.dart';
// Import file trang chủ của bạn để Navigator có thể nhận diện
import 'package:antam_app/children_home.dart';

class CheckInHistoryPage extends StatefulWidget {
  const CheckInHistoryPage({Key? key}) : super(key: key);

  @override
  State<CheckInHistoryPage> createState() => _CheckInHistoryPageState();
}

class _CheckInHistoryPageState extends State<CheckInHistoryPage> {
  // Ở trang Check-in, index đang hoạt động là 1 (Bar Chart)
  final int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('CHECK-IN', style: TextStyle(color: Colors.grey)),
        centerTitle: false,
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
              _buildCalendar(),
              const SizedBox(height: 50),
              _buildComplianceSection(80),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ===== BOTTOM NAV (Giống file Children Home) =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex)
            return; // Nếu đang ở chính trang này thì không làm gì

          switch (index) {
            case 0:
              // Chuyển hướng về trang chủ
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildrenHomePage(),
                ),
              );
              break;
            case 1:
              // Đang ở trang này rồi
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

  // ================= COMPONENTS =================

  Widget _buildDayCell(String day, bool isChecked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isChecked)
          const Icon(Icons.check_circle, color: Colors.green, size: 20)
        else
          const SizedBox(height: 20),
        Text(
          day,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    const List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
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
    const List<bool> checkInStatus = [
      true,
      true,
      true,
      true,
      true,
      true,
      false,
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map(
                (day) => Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 18.0,
            crossAxisSpacing: 18.0,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final status = index < checkInStatus.length
                ? checkInStatus[index]
                : false;
            return _buildDayCell(days[index], status);
          },
        ),
      ],
    );
  }

  Widget _buildComplianceSection(int percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFCEBF),
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
                style: TextStyle(fontSize: 26, fontFamily: 'Inter'),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 37,
            backgroundColor: const Color(0x66FFD7C2),
            color: const Color(0xFFFFA694),
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }
}
