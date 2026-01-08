import 'package:antam_app/models/checkin_model.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CheckInHistoryPage extends StatefulWidget {
  const CheckInHistoryPage({super.key});

  @override
  State<CheckInHistoryPage> createState() => _CheckInHistoryPageState();
}

class _CheckInHistoryPageState extends State<CheckInHistoryPage> {
  final DatabaseService _dbService = DatabaseService();
  DateTime _currentMonth = DateTime.now();

  Widget _buildDayCell(int day, bool isChecked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isChecked)
          const Icon(Icons.check_circle, color: Colors.green, size: 20)
        else
          const SizedBox(height: 20),
        Text(
          day.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(List<CheckInModel> checkins) {
    const List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    
    DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map(
                (day) => Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 18.0,
            crossAxisSpacing: 18.0,
            childAspectRatio: 1.0,
          ),
          itemCount: daysInMonth + (firstWeekday - 1),
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox.shrink();
            }
            int day = index - (firstWeekday - 2);
            bool isChecked = checkins.any((c) => 
              c.date.day == day && 
              c.date.month == _currentMonth.month && 
              c.date.year == _currentMonth.year
            );
            return _buildDayCell(day, isChecked);
          },
        ),
      ],
    );
  }

  Widget _buildComplianceSection(int percentage) {
    const Color activeColor = Color(0xFFFFA694);
    const Color inactiveColor = Color(0x66FFD7C2);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFCEBF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tỉ lệ tuân thủ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 37,
                decoration: BoxDecoration(
                  color: inactiveColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * (percentage / 100),
                    height: 37,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;
    
    // ĐÃ SỬA: Lấy ID người thân đầu tiên từ danh sách following thay vì parentIds
    String targetId = user?.uid ?? "";
    if (user?.role == 'child' && user?.following != null && user!.following!.isNotEmpty) {
      targetId = user.following!.first['uid'] ?? user.uid;
    }

    final monthStr = DateFormat('MM/yyyy').format(_currentMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<CheckInModel>>(
        stream: _dbService.getCheckIns(targetId, _currentMonth),
        builder: (context, snapshot) {
          final checkins = snapshot.data ?? [];
          int percentage = 0;
          if (_currentMonth.month == DateTime.now().month && _currentMonth.year == DateTime.now().year) {
             int daysPassed = DateTime.now().day;
             if (daysPassed > 0) {
               percentage = ((checkins.length / daysPassed) * 100).round();
               if (percentage > 100) percentage = 100;
             }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'LỊCH SỬ CHECK-IN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Tháng $monthStr',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCalendar(checkins),
                  const SizedBox(height: 50),
                  _buildComplianceSection(percentage),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
