import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FollowPage(),
    ),
  );
}

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
          actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),

      // ===== BODY =====
      body: Column(
        children: [
          const SizedBox(height: 10),

          // ===== LOGO =====
          Image.asset(
            "assets/images/logo_removeBG.png",
            width: 500,
          ),

          const SizedBox(height: 10),

          // ===== TITLE =====
          const Text(
            "BẠN ĐANG THEO DÕI:",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // ===== CARD CHA =====
          _personCard(
            image: "assets/images/parent.png",
            name: "Bố: Nguyễn Văn A",
            age: "Tuổi: 80",
          ),

          // ===== CARD MẸ =====
          _personCard(
            image: "assets/images/children.png",
            name: "Mẹ: Nguyễn Thị A",
            age: "Tuổi: 70",
          ),
        ],
      ),

      // ===== FLOATING ADD BUTTON =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EE7B7),
        onPressed: () {
          debugPrint("Thêm người theo dõi");
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ===== PERSON CARD =====
  Widget _personCard({
    required String image,
    required String name,
    required String age,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC1A8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // AVATAR
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Image.asset(image, width: 40),
          ),

          const SizedBox(width: 16),

          // INFO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                age,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
