import 'package:antam_app/settings_page.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/create_medicine.dart';
import 'package:antam_app/create_checkup.dart';
import 'package:antam_app/following.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'models/medicine_model.dart';
import 'models/checkup_model.dart';
import 'models/checkin_model.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';

class ChildrenHomePage extends StatefulWidget {
  const ChildrenHomePage({super.key});

  @override
  State<ChildrenHomePage> createState() => _ChildrenHomePageState();
}

class _ChildrenHomePageState extends State<ChildrenHomePage> {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _parentModel;
  bool _isLoadingParent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParentInfo();
    });
  }

  Future<void> _loadParentInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel?.parentId != null) {
      if (mounted) setState(() => _isLoadingParent = true);
      final parent = await _dbService.getUser(userModel!.parentId!);
      if (mounted) {
        setState(() {
          _parentModel = parent;
          _isLoadingParent = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy user hiện tại từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.firebaseUser;
    final userModel = authProvider.userModel;

    // Nếu chưa đăng nhập hoặc không có thông tin
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FollowPage()),
            );
          }
        ),
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Column(
          children: [
            _warningCard(),
            _userInfo(
              _isLoadingParent 
                ? "Đang tải..." 
                : (_parentModel?.name ?? "Chưa kết nối cha mẹ"),
              _parentModel?.age,
            ),

            // --- MEDICINES SECTION ---
            _sectionHeader(
              title: "TRẠNG THÁI UỐNG THUỐC",
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateMedicinePage()),
                );
              },
            ),
            
            // StreamBuilder for Medicines
            StreamBuilder<List<MedicineModel>>(
              stream: _dbService.getMedicines(userModel?.parentId ?? user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Lỗi: ${snapshot.error}");
                }
                final medicines = snapshot.data ?? [];
                
                if (medicines.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Chưa có đơn thuốc nào."),
                  );
                }

                return Column(
                  children: medicines.map((med) {
                    return _medicineCard(med, () async {
                      // Confirm dialog
                      bool confirm = await showDialog(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xóa thuốc này?"),
                          content: Text("Bạn có chắc muốn xóa: ${med.name}?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
                          ],
                        )
                      ) ?? false;
                      
                      if (confirm) {
                         await _dbService.deleteMedicine(med.id);
                      }
                    });
                  }).toList(),
                );
              },
            ),

            // --- CHECKUPS SECTION ---
            _sectionHeader(
              title: "LỊCH TÁI KHÁM",
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateCheckupPage()),
                );
              },
            ),
            
            // StreamBuilder for Checkups
            StreamBuilder<List<CheckupModel>>(
              stream: _dbService.getCheckups(userModel?.parentId ?? user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Lỗi: ${snapshot.error}");
                }
                final checkups = snapshot.data ?? [];

                if (checkups.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Chưa có lịch khám nào."),
                  );
                }

                // Lấy lịch khám gần nhất
                return Column(
                  children: checkups.map((c) => _reExaminationCard(c, () async {
                      bool confirm = await showDialog(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xóa lịch khám này?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
                          ],
                        )
                      ) ?? false;
                      if (confirm) await _dbService.deleteCheckup(c.id);
                  })).toList(),
                );
              },
            ),

            _sectionHeader(title: "LỊCH SỬ CHECK-IN"),
            StreamBuilder<List<CheckInModel>>(
              stream: _dbService.getCheckIns(userModel?.parentId ?? user.uid, DateTime.now()),
              builder: (context, snapshot) {
                int percentage = 0;
                if (snapshot.hasData) {
                  final checkins = snapshot.data!;
                  final now = DateTime.now();
                  final daysInMonth = now.day; // Number of days passed in current month
                  if (daysInMonth > 0) {
                    percentage = ((checkins.length / daysInMonth) * 100).round();
                    if (percentage > 100) percentage = 100;
                  }
                }
                return _checkinCard(percentage);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================
  Widget _warningCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE6A7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Cảnh báo! Cha mẹ chưa xác nhận lịch uống thuốc Huyết áp sáng.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo(String parentName, int? parentAge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFC1A8),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parentName.contains("Đang tải") ? parentName : "Bố: $parentName", 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              Text("Tuổi: ${parentAge ?? "--"}"),
            ],
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                     Icon(Icons.settings, color: Colors.black54),
                     SizedBox(width: 8),
                     Text("Cài đặt"),
                  ],
                ),
              )
            ],
            child: _smallAvatar(),
          ),
        ],
      ),
    );
  }

  Widget _smallAvatar() {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: Color(0xFFFFC1A8),
      child: Icon(Icons.person, size: 14, color: Colors.white),
    );
  }

  Widget _sectionHeader({required String title, VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add, size: 26),
              onPressed: onAdd,
            ),
        ],
      ),
    );
  }

  Widget _medicineCard(MedicineModel med, VoidCallback onDelete) {
    // Format repeat days
    String subText = "Liều: ${med.dosage} - ${med.time.format()}";
    if (med.repeatDays.isNotEmpty) {
      if (med.repeatDays.length == 7) {
        subText += " (Hàng ngày)";
      } else {
        subText += " (${med.repeatDays.join(',')})";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onLongPress: onDelete, // Xóa khi nhấn giữ
        onTap: () async {
            // Tạm thời cho phép toggle trạng thái khi nhấn vào để test
            // Sau này logic này sẽ nằm ở phía Parent
            await _dbService.updateMedicineStatus(med.id, !med.isConfirmed);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subText, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              // Status Icon
              Icon(
                med.isConfirmed ? Icons.check_circle : Icons.cancel,
                color: med.isConfirmed ? Colors.green : Colors.red,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reExaminationCard(CheckupModel checkup, VoidCallback onDelete) {
    final dateStr = DateFormat('dd/MM/yyyy - HH:mm').format(checkup.date);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(checkup.hospitalName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(dateStr, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
             IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkinCard(int percentage) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    valueColor:
                    const AlwaysStoppedAnimation(Color(0xFFFFA387)),
                  ),
                  Text(
                    "$percentage%",
                    style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tuân thủ tháng này",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CheckInHistoryPage()
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA387),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Xem chi tiết",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
