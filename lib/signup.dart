import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isSignIn = true; // trạng thái tab

  // HÀM MỞ LINK
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Không mở được link: $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // LOGO
                Image.asset("assets/images/logo_removeBG.png", width: 500),

                const SizedBox(height: 25),

                // TAB SIGN IN / SIGN UP
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE2DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // --- SIGN IN TAB ---
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);   // QUAY VỀ SIGN IN PAGE
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- SIGN UP TAB ---
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // FORM INPUTS
                _inputField(hint: "Full Name", icon: Icons.person_outline),
                const SizedBox(height: 12),

                _inputField(hint: "Email / Phone number", icon: Icons.email_outlined),
                const SizedBox(height: 12),

                _inputField(hint: "Password", icon: Icons.lock_outline, isPassword: true),
                const SizedBox(height: 12),

                _inputField(hint: "Confirm Password", icon: Icons.lock_outline, isPassword: true),
                const SizedBox(height: 20),

                // SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);  // QUAY VỀ SIGN IN
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // OR DIVIDER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 80, height: 1, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text("Or"),
                    const SizedBox(width: 8),
                    Container(width: 80, height: 1, color: Colors.grey),
                  ],
                ),

                const SizedBox(height: 15),

                // SOCIAL LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _openUrl("https://facebook.com"),
                      child: Image.asset("assets/images/fb.png", width: 40),
                    ),
                    const SizedBox(width: 80),
                    GestureDetector(
                      onTap: () => _openUrl("https://google.com"),
                      child: Image.asset("assets/images/gg.png", width: 40),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          suffixIcon: isPassword ? const Icon(Icons.visibility_outlined) : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
