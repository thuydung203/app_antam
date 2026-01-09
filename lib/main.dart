import 'package:antam_app/services/notification_service.dart';
import 'package:antam_app/services/reminder_sync_service.dart';
import 'package:antam_app/setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'loading.dart';
import 'setting_account_info_page.dart';
import 'package:antam_app/map_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Khởi tạo dịch vụ thông báo
  await NotificationService().init();
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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(),
    );
  }
}
