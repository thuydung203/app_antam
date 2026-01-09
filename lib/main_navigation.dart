import 'package:antam_app/add_images.dart';
import 'package:antam_app/children_home.dart';
import 'package:antam_app/map_screen.dart';
import 'package:antam_app/paring.dart';
import 'package:antam_app/setting.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic>? selectedPerson; // Nhận thông tin người được chọn

  const MainNavigation({super.key, this.selectedPerson});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình, truyền selectedPerson vào ChildrenHomePage
    final List<Widget> _pages = [
      ChildrenHomePage(selectedPerson: widget.selectedPerson),
      const AddImage(), 
      const MapScreen(),
      const PairingExpiredPage(),
      const SettingPage(),
    ];

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
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_outlined, size: 30), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), label: ''),
        ],
      ),
    );
  }
}
