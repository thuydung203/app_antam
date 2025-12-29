import 'package:antam_app/add_images.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/children_home.dart';
import 'package:antam_app/gps.dart';
import 'package:antam_app/setting.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  final List<Widget> _pages = [
    const ChildrenHomePage(), // Index 0
    const CheckInHistoryPage(),
    const AddImage(), // Index 2
    const GPSScreen(),
    const SettingPage(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giúp giữ trạng thái của các trang khi chuyển tab (không bị reload lại)
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
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), label: ''),
        ],
      ),
    );
  }
}
