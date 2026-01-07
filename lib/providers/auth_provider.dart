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

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> signUp(String email, String password, String role, String name) async {
    UserCredential? cred = await _authService.signUpWithEmailAndPassword(email, password);
    if (cred != null && cred.user != null) {
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: role,
        name: name,
      );
      await _dbService.createUser(newUser);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
