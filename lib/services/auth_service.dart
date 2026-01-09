import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error: ${e.code}');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error: ${e.code}');
      rethrow;
    }
  }

  // Chức năng đổi mật khẩu
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw "Không tìm thấy thông tin người dùng";

    try {
      // 1. Xác thực lại người dùng bằng mật khẩu hiện tại (Bắt buộc trong Firebase)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Cập nhật mật khẩu mới
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error changePassword: ${e.code}');
      if (e.code == 'wrong-password') throw "Mật khẩu hiện tại không đúng";
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
