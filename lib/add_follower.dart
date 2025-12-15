import 'package:flutter/material.dart';

void main() {
  // Đã đổi tên class trong runApp
  runApp(const AddFollowerPage());
}

// Đã đổi tên class từ AddFollowerApp thành AddFollowerPage
class AddFollowerPage extends StatelessWidget {
  const AddFollowerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thêm Người Theo Dõi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFFEECE9), // Màu nền hồng nhạt
      ),
      home: const AddFollowerScreen(),
    );
  }
}

// Màn hình chính đã được chuyển sang StatefulWidget (giữ nguyên tên)
class AddFollowerScreen extends StatefulWidget {
  const AddFollowerScreen({super.key});

  @override
  State<AddFollowerScreen> createState() => _AddFollowerScreenState();
}

class _AddFollowerScreenState extends State<AddFollowerScreen> {
  // Màu sắc chủ đạo (Giữ nguyên)
  final Color _primaryColor = const Color(0xFF3C4043);
  final Color _placeholderColor = const Color(0xFFA19A9A);
  final Color _buttonColor = const Color(0xFFFFA694);

  // Khai báo Controllers để quản lý dữ liệu đầu vào
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  // Hàm hiển thị Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Chọn Ngày Sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _buttonColor, // Màu chủ đạo của picker
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Cập nhật trường Ngày sinh
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        // Tính toán và cập nhật trường Tuổi (giả định)
        final int age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  // Widget Helper cho các trường nhập liệu
  Widget _buildTextFieldRow({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap, // Thêm onTap cho trường readOnly
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Nhãn
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Ô nhập liệu
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x49B2A5A5).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: controller, // Sử dụng Controller
                readOnly: readOnly,
                keyboardType: keyboardType,
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: _placeholderColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: suffixIcon,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                onTap: onTap, // Sử dụng onTap đã truyền vào
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng Controller khi widget bị hủy
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
            // --- Header và Ảnh đại diện ---
            _buildHeader(context),

            // --- Form Nhập liệu ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  // Họ và tên
                  _buildTextFieldRow(
                    label: 'Họ và tên:',
                    placeholder: 'Nguyen Văn A',
                    controller: _nameController,
                  ),
                  // Quan hệ
                  _buildTextFieldRow(
                    label: 'Quan hệ:',
                    placeholder: 'Bố/Mẹ',
                    controller: _relationshipController,
                  ),
                  // Ngày sinh
                  _buildTextFieldRow(
                    label: 'Ngày sinh:',
                    placeholder: 'xx/yy/zzzz',
                    readOnly: true,
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 20,
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  // Số tuổi
                  _buildTextFieldRow(
                    label: 'Số tuổi:',
                    placeholder: '??',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                  // Tài khoản
                  _buildTextFieldRow(
                    label: 'Tài khoản:',
                    placeholder: 'email',
                    controller: _accountController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 60),

                  // --- Nút Thêm người theo dõi ---
                  _buildAddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget cho Header (Giữ nguyên giao diện)
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      color: const Color(0x70FFCEBF),
      child: Column(
        children: [
          // App Bar (Mũi tên và Tìm kiếm)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.search, color: Colors.black, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Ảnh đại diện
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueGrey, width: 2),
              color: Colors.white,
              image: const DecorationImage(
                image: NetworkImage(
                  "https://via.placeholder.com/150/F5F5F5/808080?text=Profile",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget cho Nút
  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        // Lấy dữ liệu từ Controllers khi nút được nhấn
        debugPrint('Tên: ${_nameController.text}');
        debugPrint('Quan hệ: ${_relationshipController.text}');
        debugPrint('Ngày sinh: ${_dobController.text}');
        debugPrint('Tuổi: ${_ageController.text}');
        debugPrint('Tài khoản: ${_accountController.text}');
        // Thêm logic xử lý API/lưu dữ liệu tại đây
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(289, 67),
      ),
      child: const Text(
        'Thêm người theo dõi',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
