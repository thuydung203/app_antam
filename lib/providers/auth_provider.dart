import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  User? _firebaseUser;
  UserModel? _userModel;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      
      // Hủy subscription cũ nếu có
      await _userSubscription?.cancel();

      if (user != null) {
        // Lắng nghe thay đổi dữ liệu Real-time từ Firestore
        _userSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>, user.uid);
            notifyListeners();
          }
        });
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // Các hàm cập nhật khác (giữ nguyên hoặc tối ưu)
  Future<void> reloadUserModel() async {
    if (_firebaseUser != null) {
      _userModel = await _dbService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String role) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'role': role});
    }
  }

  Future<void> updateName(String newName) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'name': newName});
    }
  }

  Future<void> updatePhone(String newPhone) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'phone': newPhone});
    }
  }

  Future<void> updateAddress(String newAddress) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'address': newAddress});
    }
  }

  Future<void> updateBirthDate(DateTime date) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'birthDate': date});
    }
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> signUp(String email, String password, String name) async {
    UserCredential? cred = await _authService.signUpWithEmailAndPassword(email, password);
    if (cred != null && cred.user != null) {
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: 'none',
        name: name,
      );
      await _dbService.createUser(newUser);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
