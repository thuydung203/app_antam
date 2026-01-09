import 'package:antam_app/forgot_password.dart';
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

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
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
        case 'invalid-email': return 'Email không hợp lệ.';
        case 'user-disabled': return 'Tài khoản đã bị vô hiệu hóa.';
        case 'user-not-found': return 'Không tìm thấy tài khoản.';
        case 'wrong-password': return 'Sai mật khẩu.';
        default: return e.message ?? 'Đăng nhập thất bại.';
      }
    }
    return 'Đăng nhập thất bại.';
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(_emailCtrl.text.trim(), _passCtrl.text);

      if (!mounted) return;

      int retry = 0;
      while (authProvider.userModel == null && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        retry++;
      }

      final userModel = authProvider.userModel;

      if (userModel == null || userModel.role == 'none' || userModel.role == '') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionPage()));
      } else if (userModel.role == 'child') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
      } else if (userModel.role == 'parent') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ParentNavigation()));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyAuthError(e))));
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

                  // TAB ĐĂNG NHẬP / ĐĂNG KÝ
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
                              child: Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold, color: isSignIn ? Colors.black : Colors.black54)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => isSignIn = false);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isSignIn ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text("Đăng ký", style: TextStyle(fontWeight: FontWeight.bold, color: !isSignIn ? Colors.black : Colors.black54)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // EMAIL
                  _inputField(controller: _emailCtrl, hint: "Email", icon: Icons.email_outlined),
                  const SizedBox(height: 15),

                  // MẬT KHẨU
                  _inputField(
                    controller: _passCtrl, 
                    hint: "Mật khẩu", 
                    icon: Icons.lock_outline, 
                    isPass: true, 
                    obscure: _obscure,
                    onToggle: () => setState(() => _obscure = !_obscure)
                  ),

                  const SizedBox(height: 10),

                  // QUÊN MẬT KHẨU
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                      },
                      child: const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NÚT ĐĂNG NHẬP (Đã thu ngắn lại và không bo góc)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B4A),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Không bo góc
                    ),
                    onPressed: _isLoading ? null : _handleSignIn,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 20),

                  // DÒNG HOẶC
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 80, height: 1, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Hoặc"),
                      const SizedBox(width: 8),
                      Container(width: 80, height: 1, color: Colors.grey),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // MẠNG XÃ HỘI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(onTap: () => _openUrl("https://facebook.com"), child: Image.asset("assets/images/fb.png", width: 40)),
                      const SizedBox(width: 80),
                      GestureDetector(onTap: () => _openUrl("https://google.com"), child: Image.asset("assets/images/gg.png", width: 40)),
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPass = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPass && obscure,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          suffixIcon: isPass ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: onToggle) : null,
          border: InputBorder.none,
        ),
        validator: (v) => (v ?? "").isEmpty ? "Trường này không được để trống" : null,
      ),
    );
  }
}
