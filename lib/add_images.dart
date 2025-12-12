import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đăng Ký Tài Khoản Demo',
      theme: ThemeData(
        // Màu chủ đạo là màu tím đậm như trong hình
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      home: const RegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum Gender { male, female, other }

class _RegisterScreenState extends State<RegisterScreen> {
  // Biến trạng thái để lưu trữ giá trị của Radio và Checkbox
  Gender? _selectedGender = Gender.male;
  bool _agreedToTerms = false;
  
  // Key để quản lý Form và thực hiện Validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Chiều cao Appbar lớn hơn
        child: AppBar(
          automaticallyImplyLeading: false, // Loại bỏ nút back mặc định
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đăng Ký Tài Khoản',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.person_add_alt, size: 30, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Tạo tài khoản để bắt đầu trải nghiệm',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              // Đặt khoảng cách giữa các trường và cho phép cuộn
              children: [
                const SizedBox(height: 20),

                // 1. Họ & tên
                _buildLabel('Họ & tên'),
                _buildTextField(hintText: 'Nguyễn Văn A'),
                
                // 2. Email
                _buildLabel('Email'),
                _buildTextField(hintText: 'example@email.com', keyboardType: TextInputType.emailAddress),

                // 3. Số điện thoại
                _buildLabel('Số điện thoại'),
                _buildTextField(hintText: '0987654321', keyboardType: TextInputType.phone),

                // 4. Mật khẩu
                _buildLabel('Mật khẩu'),
                _buildTextField(hintText: 'Ít nhất 6 ký tự', obscureText: true),

                // 5. Xác nhận mật khẩu
                _buildLabel('Xác nhận mật khẩu'),
                _buildTextField(hintText: 'Nhập lại mật khẩu', obscureText: true),

                // 6. Ngày sinh
                _buildLabel('Ngày sinh'),
                _buildDateField(),

                // 7. Giới tính (Radio Buttons)
                _buildLabel('Giới tính'),
                _buildGenderRadioButtons(),

                // 8. Điều khoản sử dụng (Checkbox)
                _buildTermsCheckbox(),

                const SizedBox(height: 30),

                // 9. Nút Đăng ký
                _buildRegisterButton(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.white,
        filled: true,
      ),
      // Giả lập validation đơn giản
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng điền thông tin này';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'dd/mm/yyyy',
        fillColor: Colors.white,
        filled: true,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
      ),
      onTap: () async {
        // Giả lập chức năng chọn ngày
        await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
      },
    );
  }

  Widget _buildGenderRadioButtons() {
    return Column(
      children: Gender.values.map((Gender gender) {
        String label = '';
        switch (gender) {
          case Gender.male:
            label = 'Nam';
            break;
          case Gender.female:
            label = 'Nữ';
            break;
          case Gender.other:
            label = 'Khác';
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<Gender>(
                value: gender,
                groupValue: _selectedGender,
                activeColor: Colors.deepPurple,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              Text(label),
              const SizedBox(width: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          Checkbox(
            value: _agreedToTerms,
            activeColor: Colors.deepPurple,
            onChanged: (bool? value) {
              setState(() {
                _agreedToTerms = value!;
              });
            },
          ),
          const Text('Tôi đồng ý với điều khoản sử dụng'),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate() && _agreedToTerms) {
          // Xử lý logic đăng ký thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký đang được xử lý...')),
          );
        } else if (!_agreedToTerms) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đồng ý với điều khoản.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text(
        'Đăng Ký',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}