import 'package:antam_app/add_follower.dart';
import 'package:antam_app/add_images.dart';
import 'package:antam_app/alarm_clock.dart';
import 'package:antam_app/check_in_history.dart';
import 'package:antam_app/confirmation.dart';
import 'package:antam_app/create_medicine.dart';
import 'package:antam_app/forgot_password.dart';
import 'package:antam_app/location_status.dart';
import 'package:antam_app/setting_language_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'login.dart';
import 'signup.dart';
import 'roleselection.dart';
import 'following.dart';
import 'children_home.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // File do flutterfire sinh ra


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:ForgotPasswordPage(), // Khi chạy app → mở LoadingPage đầu tiên
    );
  }
}
