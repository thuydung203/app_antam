import 'package:antam_app/main_navigation.dart';
import 'package:antam_app/parent_home.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String selectedRole = "";
  String pressedRole = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset("assets/images/logo_removeBG.png", width: 500, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 100)),
            const SizedBox(height: 20),
            const Text(
              "CHỌN VAI TRÒ",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedRoleButton(
                  image: "assets/images/children.png",
                  title: "CON",
                  value: "child",
                ),
                const SizedBox(width: 40),
                _buildAnimatedRoleButton(
                  image: "assets/images/parent.png",
                  title: "CHA MẸ",
                  value: "parent",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRoleButton({
    required String image,
    required String title,
    required String value,
  }) {
    bool isSelected = selectedRole == value;
    bool isPressed = pressedRole == value;

    return Column(
      children: [
        AnimatedScale(
          scale: isPressed ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 110,
            height: 110,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  pressedRole = value;
                });

                await Future.delayed(const Duration(milliseconds: 120));

                if (!mounted) return;

                setState(() {
                  pressedRole = "";
                  selectedRole = value;
                });

                if (value == "child") {
                  Navigator.push( // Sử dụng push để có thể quay lại
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                  );
                } else if (value == "parent") {
                  Navigator.push( // Sử dụng push để có thể quay lại
                    context,
                    MaterialPageRoute(builder: (context) => const ParentHomePage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                elevation: isSelected ? 8 : 4,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF1CB5B4)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Image.asset(image, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
