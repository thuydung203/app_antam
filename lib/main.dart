import 'package:flutter/material.dart';
import 'loading.dart';
import 'login.dart';
import 'signup.dart';
import 'roleselection.dart';
import 'following.dart';
import 'children_home.dart';
import 'confirmation.dart';
import 'alarm_clock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlarmClockPage(), // Màn hình hiển thị đầu tiên
    );
  }
}
