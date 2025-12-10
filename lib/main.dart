import 'package:flutter/material.dart';
import 'loading.dart';
import 'login.dart';
import 'signup.dart';
import 'roleselection.dart';
import 'following.dart';
import 'children_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChildrenHomePage(), // Khi chạy app → mở LoadingPage đầu tiên
    );
  }
}
