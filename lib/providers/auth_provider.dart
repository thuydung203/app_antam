import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// AuthProvider: Quản lý trạng thái đăng nhập và thông tin người dùng trong toàn bộ ứng dụng.
/// Sử dụng ChangeNotifier để thông báo cho UI cập nhật khi có thay đổi.
class AuthProvider with ChangeNotifier {
  // Service xử lý xác thực Firebase Auth (Đăng ký, Đăng nhập, Đăng xuất)
  final AuthService _authService = AuthService();
  
  // Service xử lý dữ liệu Firestore (Lưu/Lấy thông tin User)
  final DatabaseService _dbService = DatabaseService();

  // Biến lưu User của Firebase Auth (chứa uid, email cơ bản)
  User? _firebaseUser;
  
  // Biến lưu Model User tùy chỉnh của App (chứa role, name, phone, address...)
  UserModel? _userModel;

  // Getter để UI có thể truy cập dữ liệu (nhưng không sửa trực tiếp biến private)
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;

  // Trạng thái loading: True khi đang kiểm tra đăng nhập lần đầu
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Constructor: Khởi tạo và lắng nghe thay đổi trạng thái đăng nhập ngay khi Provider được tạo
  AuthProvider() {
    _init();
  }

  // Hàm khởi tạo lắng nghe sự kiện từ Firebase Auth
  void _init() {
    // authStateChanges trả về Stream báo hiệu khi user đăng nhập hoặc đăng xuất
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      
      if (user != null) {
        // Nếu đã đăng nhập -> Lấy thông tin chi tiết từ Firestore
        _userModel = await _dbService.getUser(user.uid);
      } else {
        // Nếu chưa đăng nhập hoặc đã đăng xuất -> Xóa thông tin userModel
        _userModel = null;
      }
      
      // Đã tải xong -> Tắt loading
      _isLoading = false;
      
      // Thông báo cho các widget đang lắng nghe (Consumer/Provider.of) để rebuild
      notifyListeners();
    });
  }

  // Hàm tải lại thông tin User từ Firestore (dùng khi vừa cập nhật profile xong)
  Future<void> reloadUserModel() async {
    if (_firebaseUser != null) {
      _userModel = await _dbService.getUser(_firebaseUser!.uid);
      notifyListeners(); // Cập nhật UI với dữ liệu mới
    }
  }

  // Cập nhật vai trò người dùng (Parent/Child) và lưu vào Firestore
  Future<void> updateUserRole(String role) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'role': role});
      await reloadUserModel(); // Tải lại để app biết role mới ngay lập tức
    }
  }

  // Cập nhật Tên hiển thị
  Future<void> updateName(String newName) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'name': newName});
      await reloadUserModel();
    }
  }

  // Cập nhật Số điện thoại
  Future<void> updatePhone(String newPhone) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'phone': newPhone});
      await reloadUserModel();
    }
  }

  // Cập nhật Địa chỉ
  Future<void> updateAddress(String newAddress) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'address': newAddress});
      await reloadUserModel();
    }
  }

  // Cập nhật Ngày sinh
  Future<void> updateBirthDate(DateTime date) async {
    if (_firebaseUser != null) {
      await _dbService.updateUserInfo(_firebaseUser!.uid, {'birthDate': date});
      await reloadUserModel();
    }
  }

  // Xử lý Đăng nhập
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    // Lưu ý: Không cần notifyListeners ở đây vì _init() đã lắng nghe authStateChanges
  }

  // Xử lý Đăng ký tài khoản mới
  Future<void> signUp(String email, String password, String name) async {
    // 1. Tạo tài khoản trên Firebase Auth
    UserCredential? cred = await _authService.signUpWithEmailAndPassword(email, password);
    
    // 2. Nếu tạo thành công -> Lưu thông tin bổ sung vào Firestore
    if (cred != null && cred.user != null) {
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: 'none', // Mặc định chưa có vai trò (sẽ chọn ở màn RoleSelection)
        name: name,
      );
      await _dbService.createUser(newUser);
    }
  }

  // Xử lý Đăng xuất
  Future<void> signOut() async {
    await _authService.signOut();
    // notifyListeners() sẽ được gọi tự động nhờ _init()
  }
}
