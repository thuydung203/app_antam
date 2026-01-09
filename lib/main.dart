import 'package:antam_app/add_images.dart';
import 'package:antam_app/children_home.dart';
import 'package:antam_app/following.dart';
import 'package:antam_app/login.dart';
import 'package:antam_app/parent_home.dart';
import 'package:antam_app/paring.dart';
import 'package:antam_app/setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'loading.dart';
import 'setting_account_info_page.dart';

// THÊM DÒNG NÀY
import 'package:antam_app/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // SỬA DÒNG NÀY ĐỂ TEST BẢN ĐỒ
      home: const LoadingPage(),
      // Khi nào test xong thì sửa lại thành: const LoadingPage()
    );
  }
}
