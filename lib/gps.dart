import 'package:flutter/material.dart';

void main() {
  // Chạy ứng dụng với widget chính là MyApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPS Screen Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[50], 
        primarySwatch: Colors.blue,
      ),
      home: const GPSScreen(), 
    );
  }
}

class GPSScreen extends StatelessWidget {
  const GPSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 2. Body
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenWidth * 1.2, 
                    width: screenWidth,
                    // Container giả lập khu vực bản đồ
                    child: Center(
                        child: Container(
                            color: Colors.grey[400], 
                            // Bạn có thể thêm Text hoặc Image.asset tại đây
                        ),
                    ),
                  ),
                  
                  // 2.2. Phần Thông Tin Địa Điểm
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Địa chỉ
                        const Text(
                          '175 Tây Sơn, P. Đống Đa, Hà Nội',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        // "Trực tiếp"
                        const Text(
                          'Trực tiếp',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),


                        // Các nút hành động (Truy cập & Chỉ đường)
                        Row(
                          children: <Widget>[
                            // Nút 1: Truy cập (Khối màu xám trống)
                            Expanded(
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Nút 2: Chỉ đường
                            Expanded(
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], 
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.directions, color: Colors.blue[600], size: 28),
                                    Text(
                                      'Chỉ đường',
                                      style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      '41 km',
                                      style: TextStyle(color: Colors.black54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Phần Thông báo
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.notifications, color: Colors.red, size: 30),
                              SizedBox(width: 12),
                              Text(
                                'Thông báo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
