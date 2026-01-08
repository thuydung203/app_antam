import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'roleselection.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // HÀM MỞ LINK
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Không mở được link: $url');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      // Đã sửa: Chỉ truyền 3 tham số theo định nghĩa mới của AuthProvider
      await Provider.of<AuthProvider>(context, listen: false).signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
      );

      if (!mounted) return;

      // Đăng ký thành công -> Vào trang chọn vai trò (RoleSelectionPage)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        (route) => false,
      );

    } catch (e) {
       if (!mounted) return;
       String msg = "Đăng ký thất bại.";
       if (e is FirebaseAuthException) {
         if (e.code == 'email-already-in-use') {
           msg = 'Email này đã được sử dụng.';
         } else if (e.code == 'weak-password') {
           msg = 'Mật khẩu quá yếu.';
         } else {
           msg = e.message ?? msg;
         }
       }
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
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
                  _inputField(
                    controller: _nameCtrl,
                    hint: "Full Name", 
                    icon: Icons.person_outline,
                    validator: (v) => v!.trim().isEmpty ? "Cần nhập tên" : null,
                  ),
                  const SizedBox(height: 12),

                  _inputField(
                    controller: _emailCtrl,
                    hint: "Email", 
                    icon: Icons.email_outlined,
                    validator: (v) {
                      if (v!.trim().isEmpty) return "Cần nhập email";
                      if (!v.contains('@')) return "Email sai định dạng";
                      return null;
                    }
                  ),
                  const SizedBox(height: 12),

                  _inputField(
                    controller: _passCtrl,
                    hint: "Password", 
                    icon: Icons.lock_outline, 
                    isPassword: true,
                    showPass: _obscurePass,
                    onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                    validator: (v) => v!.length < 6 ? "Mật khẩu phải >= 6 ký tự" : null,
                  ),
                  const SizedBox(height: 12),

                  _inputField(
                    controller: _confirmPassCtrl,
                    hint: "Confirm Password", 
                    icon: Icons.lock_outline, 
                    isPassword: true,
                    showPass: _obscureConfirm,
                    onTogglePass: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v != _passCtrl.text) return "Mật khẩu không khớp";
                      return null;
                    },
                  ),
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
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool showPass = false,
    VoidCallback? onTogglePass,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && showPass,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
          suffixIcon: isPassword ? IconButton(
            icon: Icon(showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: onTogglePass,
          ) : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
