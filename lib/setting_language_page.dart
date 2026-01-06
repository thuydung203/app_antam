import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFDF7F7),
        title: const Text(
          "Ngôn ngữ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "NGÔN NGỮ ƯU TIÊN",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 15),

            // --- Box tiếng Việt ---
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE8E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Tiếng Việt",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      "Ngôn ngữ của iPhone",
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),

                  Container(
                    height: 1,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),

                  // ---- Thêm ngôn ngữ ----
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 15),
                    child: Text(
                      "Thêm ngôn ngữ...",
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, size: 28, color: Colors.grey),
            Icon(Icons.bar_chart, size: 28, color: Colors.grey),
            Icon(Icons.image, size: 28, color: Colors.grey),
            Icon(Icons.navigation, size: 28, color: Colors.grey),
            Icon(Icons.settings, size: 30, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
