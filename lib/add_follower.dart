import 'package:flutter/material.dart';

void main() {
  runApp(const AddFollowerPage());
}

class AddFollowerPage extends StatelessWidget {
  const AddFollowerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thêm Người Theo Dõi',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFFEECE9), // Màu nền hồng nhạt
      ),
      home: const AddFollowerScreen(),
    );
  }
}

// Màn hình chính
class AddFollowerScreen extends StatelessWidget {
  const AddFollowerScreen({super.key});

  // Màu sắc chủ đạo
  final Color _primaryColor = const Color(0xFF3C4043);
  final Color _placeholderColor = const Color(0xFFA19A9A);
  final Color _buttonColor = const Color(0xFFFFA694);

  // Helper Widget cho các trường nhập liệu
  Widget _buildTextFieldRow({
    required String label,
    required String placeholder, // Đổi tên thành placeholder
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
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
                readOnly: readOnly,
                keyboardType: keyboardType,
                // **ĐIỀU CHỈNH QUAN TRỌNG:**
                // initialValue: '', // Giá trị ban đầu là rỗng
                style: TextStyle(
                  color: _primaryColor, // Chữ nhập vào sẽ là màu đen
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  // SỬ DỤNG HINT TEXT cho chữ chìm
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: _placeholderColor, // Màu chữ chìm
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
                onTap: readOnly && suffixIcon != null
                    ? () {
                        // Logic cho Date Picker
                        print('Mở Date Picker');
                        // Ví dụ: showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEECE9),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Header và Ảnh đại diện ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              color: const Color(0x70FFCEBF), // Màu nền hồng nhạt
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
            ),

            // --- Form Nhập liệu ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: <Widget>[
                  // Họ và tên
                  _buildTextFieldRow(
                    label: 'Họ và tên:',
                    placeholder: 'Nguyen Văn A',
                  ),
                  // Quan hệ
                  _buildTextFieldRow(label: 'Quan hệ:', placeholder: 'Bố/Mẹ'),
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
                    keyboardType: TextInputType.number,
                  ),
                  // Tài khoản
                  _buildTextFieldRow(
                    label: 'Tài khoản:',
                    placeholder: 'email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 60),

                  // --- Nút Thêm người theo dõi ---
                  ElevatedButton(
                    onPressed: () {
                      print('Thêm người theo dõi đã được nhấn');
                      // Logic xử lý thêm người theo dõi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
