import 'dart:convert';
import 'package:antam_app/main_navigation.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatelessWidget {
  const FollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    
    // Lấy danh sách những người đang theo dõi từ UserModel
    final List<dynamic> followingList = user?.following ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút back mặc định về RoleSelection
        title: const Text("DANH SÁCH THEO DÕI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Image.asset("assets/images/logo_removeBG.png", width: 300),
          const SizedBox(height: 10),
          const Text("BẠN ĐANG THEO DÕI:", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          
          Expanded(
            child: followingList.isEmpty 
              ? const Center(child: Text("Bạn chưa theo dõi ai.\nHãy nhấn nút + để thêm người thân.", textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (context, index) {
                    final person = followingList[index] as Map<String, dynamic>;
                    return _personCard(
                      context: context,
                      image: person['avatar'] != null ? "" : "assets/images/parent.png",
                      name: person['name'] ?? "Chưa rõ",
                      age: "Tuổi: ${person['age'] ?? '--'}",
                      personData: person,
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _personCard({
    required BuildContext context,
    required String image,
    required String name,
    required String age,
    required Map<String, dynamic> personData,
  }) {
    final String? avatarBase64 = personData['avatar'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation(selectedPerson: personData)),
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
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: (avatarBase64 != null && avatarBase64.isNotEmpty) 
                  ? MemoryImage(base64Decode(avatarBase64)) 
                  : null,
              child: (avatarBase64 == null || avatarBase64.isEmpty) 
                  ? Image.asset(image, width: 40) 
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(age, style: const TextStyle(fontSize: 14)),
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
