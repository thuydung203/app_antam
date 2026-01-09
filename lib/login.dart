import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'signup.dart';
import 'roleselection.dart';
import 'main_navigation.dart';
import 'parent_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignIn = true;

  // controllers để lấy text từ ô nhập
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  // form key để validate
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Không mở được link: $url');
    }
  }

  String _friendlyAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa.';
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Sai mật khẩu.';
        case 'invalid-credential':
          return 'Thông tin đăng nhập không đúng.';
        case 'too-many-requests':
          return 'Thử lại sau (quá nhiều lần).';
        case 'network-request-failed':
          return 'Lỗi mạng. Kiểm tra internet.';
        default:
          return e.message ?? 'Đăng nhập thất bại.';
      }
    }
    return 'Đăng nhập thất bại.';
  }

  Future<void> _handleSignIn() async {
    // validate form trước
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() => _isLoading = true);

    try {
      // Sử dụng AuthProvider để đăng nhập
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(email, password);

      if (!mounted) return;

      // Đợi một chút để AuthProvider load userModel
      int retry = 0;
      while (authProvider.userModel == null && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        retry++;
      }

      final userModel = authProvider.userModel;

      // Kiểm tra role và chuyển đến trang tương ứng
      if (userModel == null || userModel.role == 'none' || userModel.role == '') {
        // Chưa có role -> Chọn vai trò
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      } else if (userModel.role == 'child') {
        // Vai trò CON -> Vào app con
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else if (userModel.role == 'parent') {
        // Vai trò CHA MẸ -> Vào app cha mẹ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParentNavigation()),
        );
      } else {
        // Trường hợp không xác định -> Chọn lại vai trò
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = _friendlyAuthError(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F6),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo_removeBG.png", width: 500),
                  const SizedBox(height: 30),

                  // TAB SIGN IN / SIGN UP
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2DE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isSignIn = true),
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isSignIn = false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpPage()),
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

                  // EMAIL
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
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email_outlined),
                        hintText: "Email / Phone number",
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        final v = (value ?? "").trim();
                        if (v.isEmpty) return "Email không được để trống";
                        if (!v.contains("@")) return "Email không hợp lệ";
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
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
                    child: TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock_outline),
                        hintText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        final v = value ?? "";
                        if (v.length < 6) return "Mật khẩu phải >= 6 ký tự";
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SIGN IN BUTTON
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
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
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

                  const Text("Forgot Password?", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 20),

                  // OR LINE
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
      ),
    );
  }
}
