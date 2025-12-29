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

  // Sử dụng GlobalKey để quản lý Scaffold nếu cần
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Danh sách các màn hình
  // Lưu ý: Các trang này nên được thiết kế để hiển thị bên trong một Scaffold khác
  final List<Widget> _pages = [
    const ChildrenHomePage(), 
    const CheckInHistoryPage(),
    const AddImage(), 
    const GPSScreen(),
    const SettingPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
