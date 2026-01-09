import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class MapScreen extends StatefulWidget {
  // ID của người được theo dõi (Bố/Mẹ). Nếu null sẽ tự động lấy từ danh sách following
  final String? targetUid;

  const MapScreen({super.key, this.targetUid});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    // 1. Kiểm tra đăng nhập
    if (userModel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Đang tải dữ liệu...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // --- GIAO DIỆN CHO CHA MẸ (Bật/Tắt định vị) ---
    if (userModel.role == 'parent') {
       return Scaffold(
        appBar: AppBar(title: const Text("Chia sẻ vị trí")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Trạng thái chia sẻ vị trí",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Switch(
                value: true, // TODO: Cần binding với Database (field isSharing)
                onChanged: (value) {
                  // TODO: Cập nhật vào Firestore
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(value ? "Đã BẬT chia sẻ vị trí" : "Đã TẮT chia sẻ vị trí")),
                  );
                },
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Khi bật, con của bạn có thể xem được vị trí hiện tại của bạn trên bản đồ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- GIAO DIỆN CHO CON (Xem bản đồ) ---
    
    // 2. Xác định ID người cần theo dõi
    String? targetId = widget.targetUid;

    // Nếu không truyền vào targetId, lấy người đầu tiên trong danh sách following
    if (targetId == null && userModel.following != null && userModel.following!.isNotEmpty) {
      targetId = userModel.following!.first['uid'];
    }

    // Nếu vẫn không có ID nào (chưa kết nối với ai), dùng ID test (Demo Mode)
    if (targetId == null) {
       targetId = "B1e4LvWVyFR9rP1q1HEX4ys36W53"; // ID Demo
       WidgetsBinding.instance.addPostFrameCallback((_) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("Đang xem ở Chế độ Demo (vì chưa kết nối với Cha/Mẹ)"),
             duration: Duration(seconds: 3),
             backgroundColor: Colors.orange,
           ),
         );
       });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Xem vị trí của bố mẹ")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(targetId) 
            .snapshots(),
        builder: (context, snapshot) {
          // Xử lý lỗi Firestore
          if (snapshot.hasError) {
             return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy người dùng này!"));
          }

          var userDocument = snapshot.data!;
          Map<String, dynamic> data = userDocument.data() as Map<String, dynamic>;

          // Kiểm tra tọa độ
          if (!data.containsKey('latitude') || !data.containsKey('longitude')) {
            return const Center(child: Text("Bố/Mẹ chưa bật chia sẻ vị trí!"));
          }

          double lat = data['latitude'];
          double lng = data['longitude'];
          LatLng targetLocation = LatLng(lat, lng);
          String name = data['name'] ?? "Bố/Mẹ";

          try {
            _mapController.move(targetLocation, 15.0);
          } catch (e) {
            // Ignored
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: targetLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.antam_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: targetLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 40),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                            ]
                          ),
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
