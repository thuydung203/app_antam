import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddFollowerPage extends StatelessWidget {
  const AddFollowerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddFollowerScreen();
  }
}

class AddFollowerScreen extends StatefulWidget {
  const AddFollowerScreen({super.key});

  @override
  State<AddFollowerScreen> createState() => _AddFollowerScreenState();
}

class _AddFollowerScreenState extends State<AddFollowerScreen> {
  final Color _primaryColor = const Color(0xFF3C4043);
  final Color _placeholderColor = const Color(0xFFA19A9A);
  final Color _buttonColor = const Color(0xFFFFA694);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSaving = false;

  // Hàm chọn ngày sinh và tính tuổi
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1970),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        // Tính tuổi
        int age = DateTime.now().year - picked.year;
        if (DateTime.now().month < picked.month || 
           (DateTime.now().month == picked.month && DateTime.now().day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  // Hàm xử lý lưu vào Firestore
  Future<void> _handleSave() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.userModel;

    if (_nameController.text.isEmpty || _accountController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dbService = DatabaseService();
      
      // Tạo map dữ liệu người theo dõi mới
      final Map<String, dynamic> followerData = {
        'name': _nameController.text.trim(),
        'relationship': _relationshipController.text.trim(),
        'birthDate': _selectedDate,
        'age': int.parse(_ageController.text),
        'accountEmail': _accountController.text.trim(),
        'addedBy': user?.uid,
        'createdAt': DateTime.now(),
      };

      // Lưu vào collection 'following_list' (Danh sách những người người dùng đang theo dõi)
      await dbService.updateUserInfo(user!.uid, {
        'following': [followerData] // Đây là ví dụ, thực tế nên dùng arrayUnion
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm người thân thành công!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextFieldRow({
    required String label,
    String? placeholder,
    required TextEditingController controller,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x49B2A5A5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                keyboardType: keyboardType,
                style: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(color: _placeholderColor, fontSize: 18, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  suffixIcon: suffixIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEECE9),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  _buildTextFieldRow(
                    label: 'Họ và tên:',
                    placeholder: 'Nguyễn Văn A',
                    controller: _nameController,
                  ),
                  _buildTextFieldRow(
                    label: 'Quan hệ:',
                    placeholder: 'Bố/Mẹ/Ông/Bà...',
                    controller: _relationshipController,
                  ),
                  _buildTextFieldRow(
                    label: 'Ngày sinh:',
                    placeholder: 'Chọn ngày sinh',
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  ),
                  _buildTextFieldRow(
                    label: 'Số tuổi:',
                    placeholder: '??',
                    controller: _ageController,
                    readOnly: true,
                  ),
                  _buildTextFieldRow(
                    label: 'Tài khoản:',
                    placeholder: 'Email tài khoản',
                    controller: _accountController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 40),
                  _buildAddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      color: const Color(0xFFFFCEBF).withValues(alpha: 0.4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 25),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("THÔNG TIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFFF5F5F5),
                  child: Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: _buttonColor,
                  radius: 20,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      child: _isSaving 
        ? const CircularProgressIndicator(color: Colors.black)
        : const Text(
            'Thêm người thân',
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
    );
  }
}
