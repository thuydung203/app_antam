import 'package:antam_app/signup.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'signup.dart'; // nhớ import trang đăng ký của bạn

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo_removeBG.png",
                  width: 500,
                ),

                const SizedBox(height: 30),

                // ---------------- TAB SIGN IN / SIGN UP ----------------
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE2DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // -------- TAB SIGN IN --------
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isSignIn = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSignIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSignIn ? Colors.black : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // -------- TAB SIGN UP --------
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isSignIn = false);

                            // điều hướng sang trang SignUp
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isSignIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !isSignIn ? Colors.black : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------- EMAIL INPUT ----------------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.email_outlined),
                      hintText: "Email / Phone number",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ---------------- PASSWORD INPUT ----------------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock_outline),
                      hintText: "Password",
                      suffixIcon: Icon(Icons.visibility_outlined),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- SIGN IN BUTTON ----------------
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
                      "SIGN IN",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- OR LINE ----------------
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

                const SizedBox(height: 25),

                // ---------------- SOCIAL LOGIN ----------------
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
}
