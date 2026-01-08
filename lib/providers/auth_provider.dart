import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  User? _firebaseUser;
  UserModel? _userModel;

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
      if (user != null) {
        _userModel = await _dbService.getUser(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> reloadUserModel() async {
    if (_firebaseUser != null) {
      _userModel = await _dbService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  // Cập nhật vai trò vĩnh viễn
  Future<void> updateUserRole(String role) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'role': role});
      await reloadUserModel();
    }
  }

  Future<void> updateName(String newName) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'name': newName});
      await reloadUserModel();
    }
  }

  Future<void> updatePhone(String newPhone) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'phone': newPhone});
      await reloadUserModel();
    }
  }

  Future<void> updateAddress(String newAddress) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'address': newAddress});
      await reloadUserModel();
    }
  }

  Future<void> updateBirthDate(DateTime date) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'birthDate': date});
      await reloadUserModel();
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
        role: 'none', // Mặc định chưa có vai trò
        name: name,
      );
      await _dbService.createUser(newUser);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
