import 'package:flutter/material.dart';

class CreateMedicinePage extends StatefulWidget {
  const CreateMedicinePage({Key? key}) : super(key: key);

  @override
  State<CreateMedicinePage> createState() => _CreateMedicinePageState();
}

class _CreateMedicinePageState extends State<CreateMedicinePage> {
  // 1. Dữ liệu trạng thái cần lưu
  TextEditingController _medicineNameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedDays = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
  ]; // Mặc định là Ngày thường
  String _selectedSound = 'Ting ting';

  final List<String> _daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> _soundOptions = ['Ting ting', 'Chuông báo', 'Mặc định'];

  // Hàm hiển thị Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: false), // Dùng 12h AM/PM
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

  // Hàm hiển thị Date Picker (Dùng cho Lịch)
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

  // Hàm hiển thị Dialog chọn ngày lặp lại (Thứ 2 - Chủ nhật)
  void _showRepeatDayPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn ngày lặp lại'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateInDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _daysOfWeek.map((day) {
                    bool isSelected = _selectedDays.contains(day);
                    return CheckboxListTile(
                      title: Text(day),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setStateInDialog(() {
                          if (value == true) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Xong'),
              onPressed: () {
                setState(() {}); // Cập nhật trạng thái của widget chính
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm hiển thị Dialog chọn âm thanh
  void _showSoundPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn âm thanh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _soundOptions.map((sound) {
              return RadioListTile<String>(
                title: Text(sound),
                value: sound,
                groupValue: _selectedSound,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSound = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Chuyển đổi List<String> ngày thành chuỗi hiển thị
  String get _repeatDayText {
    if (_selectedDays.isEmpty) return 'Không lặp lại';
    if (_selectedDays.length == 5 &&
        _selectedDays.contains('T2') &&
        _selectedDays.contains('T6') &&
        !_selectedDays.contains('T7') &&
        !_selectedDays.contains('CN')) {
      return 'Ngày thường';
    }
    if (_selectedDays.length == 7) return 'Hàng ngày';
    return _selectedDays.join(', ');
  }

  // Định dạng ngày hiển thị (DD/MM/YYYY)
  String get _formattedDate {
    return '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Layout Builder để responsive hơn
    return Scaffold(
      body: Column(
        children: [
          // 1. Top Banner (An Tâm, Con)
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
                        'CREATE MEDICINE',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Icon(Icons.code, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'An Tâm, Con\n',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'Xin chào, anh A',
                          style: TextStyle(
                            color: Colors.white,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Đóng/Xác nhận
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.close, size: 38),
                        Icon(Icons.check, size: 38, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Icon và Tiêu đề
                    Column(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Tạo lịch uống thuốc',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Tên thuốc
                    TextField(
                      controller: _medicineNameController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tên thuốc...',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
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
                    ),
                    const SizedBox(height: 30),

                    // --- CHỌN LỊCH (Ngày & Giờ) ---

                    // Chọn Ngày
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
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
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: Colors.black.withOpacity(0.2)),

                    // Chọn Giờ (Picker mô phỏng trong Figma được thay bằng Text & Time Picker)
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: Colors.black.withOpacity(0.2)),
                    const SizedBox(height: 20),

                    // --- THIẾT LẬP KHÁC ---

                    // Lặp lại (Repeat)
                    ListTile(
                      title: const Text(
                        'Lặp lại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _repeatDayText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      onTap: _showRepeatDayPicker,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(color: Colors.black.withOpacity(0.2)),

                    // Âm thanh (Sound)
                    ListTile(
                      title: const Text(
                        'Âm thanh',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedSound,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      onTap: _showSoundPicker,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(color: Colors.black.withOpacity(0.2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
