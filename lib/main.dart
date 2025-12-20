import 'package:antam_app/add_follower.dart';
import 'package:antam_app/add_images.dart';
import 'package:antam_app/create_medicine.dart';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'login.dart';
import 'signup.dart';
import 'roleselection.dart';
import 'following.dart';
import 'children_home.dart';
import 'check_in_history.dart';
import 'add_images.dart';
import 'setting.dart';
import 'setting_account_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AccountInfoPage(), // Khi chạy app → mở LoadingPage đầu tiên
    );
  }
}
