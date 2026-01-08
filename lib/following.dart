import 'package:antam_app/add_follower.dart';
import 'package:antam_app/main_navigation.dart';
import 'package:flutter/material.dart';

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
            context: context,
            image: "assets/images/parent.png",
            name: "Bố: Nguyễn Văn A",
            age: "Tuổi: 80",
            personData: {
              "name": "Bố: Nguyễn Văn A",
              "age": 80,
              "avatar": null,
            },
          ),

          // ===== CARD MẸ =====
          _personCard(
            context: context,
            image: "assets/images/children.png",
            name: "Mẹ: Nguyễn Thị A",
            age: "Tuổi: 70",
            personData: {
              "name": "Mẹ: Nguyễn Thị A",
              "age": 70,
              "avatar": null,
            },
          ),
        ],
      ),

      // ===== FLOATING ADD BUTTON =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6EE7B7),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFollowerPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ===== PERSON CARD (KHÔI PHỤC GIAO DIỆN CŨ) =====
  Widget _personCard({
    required BuildContext context,
    required String image,
    required String name,
    required String age,
    required Map<String, dynamic> personData,
  }) {
    return InkWell(
      onTap: () {
        // ĐIỀU HƯỚNG VÀO HỆ THỐNG TAB VỚI DỮ LIỆU NGƯỜI ĐƯỢC CHỌN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(selectedPerson: personData),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
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

            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
