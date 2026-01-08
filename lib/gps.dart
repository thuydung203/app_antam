import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GPSScreen extends StatefulWidget {
  final String? targetParentUid; 

  const GPSScreen({super.key, this.targetParentUid});

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

    String? parentIdToTrack = widget.targetParentUid;
    String errorMessage = "Không có thông tin người thân để theo dõi";
    
    if (user == null) {
      errorMessage = "Vui lòng đăng nhập để xem vị trí";
    } else if (user.role != 'child') {
      errorMessage = "Tài khoản của bạn không phải là 'Con', nên không thể theo dõi.";
    } else if (user.following == null || user.following!.isEmpty) {
      errorMessage = "Bạn chưa theo dõi người thân nào. Vui lòng thực hiện 'Kết nối' trước.";
    } else {
      // Lấy ID người đầu tiên trong danh sách following nếu không chỉ định mục tiêu cụ thể
      parentIdToTrack ??= user.following!.first['uid'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Theo dõi vị trí"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: parentIdToTrack == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: _locationService.getChildLocationStream(parentIdToTrack),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data == null) return const Center(child: Text("Không tìm thấy dữ liệu vị trí"));
                
                final double? lat = data['latitude']?.toDouble();
                final double? lng = data['longitude']?.toDouble();
                final String name = data['name'] ?? "Người thân";

                if (lat == null || lng == null) {
                  return const Center(child: Text("Người thân chưa bật chia sẻ vị trí hoặc chưa có dữ liệu"));
                }

                final LatLng parentPos = LatLng(lat, lng);
                final Set<Marker> markers = {
                  Marker(
                    markerId: const MarkerId('parent_location'),
                    position: parentPos,
                    infoWindow: InfoWindow(title: name, snippet: "Vị trí hiện tại"),
                  ),
                };

                _mapController?.animateCamera(CameraUpdate.newLatLng(parentPos));

                return Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: parentPos, zoom: 15),
                        onMapCreated: (controller) => _mapController = controller,
                        markers: markers,
                        myLocationEnabled: true,
                        zoomControlsEnabled: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Lat: $lat, Lng: $lng",
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ),
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
          radius: 25,
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
