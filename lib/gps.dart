import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GPSScreen extends StatefulWidget {
  final String? targetUid; 

  const GPSScreen({super.key, this.targetUid});

  @override
  State<GPSScreen> createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    // XÁC ĐỊNH NGƯỜI CẦN THEO DÕI
    String? uidToTrack = widget.targetUid;
    
    if (uidToTrack == null) {
      if (user.role == 'parent') {
        uidToTrack = user.uid;
      } else if (user.role == 'child' && user.following != null && user.following!.isNotEmpty) {
        uidToTrack = user.following!.first['uid'];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Định vị An Tâm"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: uidToTrack == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Bạn chưa có người thân để theo dõi vị trí.\nVui lòng thực hiện kết nối trước.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uidToTrack).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Không tìm thấy dữ liệu vị trí."));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data == null) return const Center(child: Text("Dữ liệu rỗng."));
                
                // ÉP KIỂU AN TOÀN TUYỆT ĐỐI (Sử dụng double literal 0.0)
                final double lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
                final double lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
                final String name = data['name'] ?? "Người dùng";

                // Kiểm tra nếu tọa độ chưa được cập nhật
                if (lat == 0.0 && lng == 0.0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 80.0, color: Colors.grey),
                        const SizedBox(height: 20.0),
                        Text("$name chưa bật chia sẻ vị trí.", style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }

                final LatLng currentPos = LatLng(lat, lng);
                final Set<Marker> markers = {
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: currentPos,
                    infoWindow: InfoWindow(title: name, snippet: "Vị trí hiện tại"),
                  ),
                };

                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: currentPos, zoom: 15.0),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: markers,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10.0),
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red),
                                SizedBox(width: 8.0),
                                Expanded(child: Text("Vị trí thời gian thực", style: TextStyle(color: Colors.black54))),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(Icons.history, "Lịch sử"),
                                _buildActionButton(Icons.directions, "Chỉ đường"),
                                _buildActionButton(Icons.notifications_active, "Vùng an toàn"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25.0,
          backgroundColor: const Color(0xFFFFA387).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFFFA387)),
        ),
        const SizedBox(height: 5.0),
        Text(label, style: const TextStyle(fontSize: 12.0)),
      ],
    );
  }
}
