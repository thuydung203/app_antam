import 'package:flutter/material.dart';

class LocationStatusPage extends StatelessWidget {
  const LocationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar nhỏ giống Figma
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Icon định vị
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF2EC8B8), // xanh bg như hình
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Đang bật định vị",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),

            // Nút Tắt
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Tắt",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, true),
            const VerticalDivider(width: 1, color: Colors.grey),
            _navItem(Icons.send, false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, bool selected) {
    return Expanded(
      child: IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          size: 28,
          color: selected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
