import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/checkup_model.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';

class CreateCheckupPage extends StatefulWidget {
  final String? targetUserId;
  const CreateCheckupPage({super.key, this.targetUserId});

  @override
  State<CreateCheckupPage> createState() => _CreateCheckupPageState();
}

class _CreateCheckupPageState extends State<CreateCheckupPage> {
  // 1. Dữ liệu trạng thái cần lưu
  // KEY để quản lý và xác thực Form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _checkupNameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  // Hàm xử lý khi nhấn nút XÁC NHẬN
  Future<void> _submitForm() async {
    // Kích hoạt validation
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).firebaseUser;
      if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập lại')),
          );
          return;
      }

      // Tạo Combined DateTime từ Date và Time đã chọn
      final checkupDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newCheckup = CheckupModel(
        id: '', 
        hospitalName: _checkupNameController.text.trim(),
        date: checkupDate,
        result: '', // Mặc định rỗng
        userId: widget.targetUserId ?? user.uid,
      );

      try {
        await DatabaseService().addCheckup(newCheckup);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Đã thêm lịch tái khám')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } else {
      // Form không hợp lệ
      debugPrint('Vui lòng điền đầy đủ thông tin.');
    }
  }

  // Hàm hiển thị Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Hàm hiển thị Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Định dạng ngày hiển thị (DD/MM/YYYY)
  String get _formattedDate {
    return '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Top Banner (Header) - Giữ nguyên
          Container(
            padding: const EdgeInsets.only(
              top: 40,
              left: 25,
              right: 25,
              bottom: 20,
            ),
            color: const Color(0xFFFFCEBF),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CREATE CHECKUP',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      Icon(Icons.code, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'An Tâm, Con\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'Xin chào, anh A',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Content (Modal White)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  // Bọc nội dung bằng Form
                  key: _formKey, // Gán key để quản lý Form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Đóng/Xác nhận (Icon nhấn được) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nút ĐÓNG (X)
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 38,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Nút XÁC NHẬN (V) - Gọi hàm submitForm()
                          InkWell(
                            onTap: _submitForm,
                            borderRadius: BorderRadius.circular(50),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.check,
                                size: 38,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Icon và Tiêu đề
                      Column(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Tạo lịch hẹn / tái khám',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Tên lịch hẹn (ĐÃ CHUYỂN THÀNH TextFormField VÀ THÊM VALIDATION)
                      TextFormField(
                        controller: _checkupNameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập lịch hẹn...',
                          hintStyle: TextStyle(
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFCEBF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                        ),
                        // Thêm Validation
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên lịch hẹn.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // --- CHỌN LỊCH (Ngày & Giờ) ---

                      // Chọn Ngày (Picker)
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ngày',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formattedDate,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Colors.black.withValues(alpha: 0.2)),

                      // Chọn Giờ (Picker)
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Thời gian',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Colors.black.withValues(alpha: 0.2)),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
