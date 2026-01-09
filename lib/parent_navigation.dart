import 'package:antam_app/map_screen.dart';
import 'package:antam_app/parent_home.dart';
import 'package:antam_app/parent_pairing.dart';
import 'package:antam_app/services/reminder_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class ParentNavigation extends StatefulWidget {
  const ParentNavigation({super.key});

  @override
  State<ParentNavigation> createState() => _ParentNavigationState();
}

class _ParentNavigationState extends State<ParentNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi động đồng bộ nhắc nhở cho phụ huynh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).firebaseUser;
      if (user != null) {
        ReminderSyncService().startSync(user.uid);
      }
    });
  }

  @override
  void dispose() {
    ReminderSyncService().stopSync();
    super.dispose();
  }

  // Chỉ giữ lại 3 màn hình chính: Trang chủ, Kết nối, Định vị
  final List<Widget> _pages = [
    const ParentHomePage(),    // Index 0: Trang chủ
    const ParentPairingPage(), // Index 1: Kết nối
    const MapScreen(),         // Index 2: Định vị (MapScreen sẽ tự hiển thị Toggle cho cha mẹ)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 30),
            label: 'Kết nối',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined, size: 30),
            label: 'Định vị',
          ),
        ],
      ),
    );
  }
}
