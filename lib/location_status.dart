import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antam_app/providers/auth_provider.dart';
import 'package:antam_app/services/location_service.dart';
import 'dart:async';

class LocationStatusPage extends StatefulWidget {
  const LocationStatusPage({super.key});

  @override
  State<LocationStatusPage> createState() => _LocationStatusPageState();
}

class _LocationStatusPageState extends State<LocationStatusPage> {
  bool _isSharing = false;
  Timer? _timer;
  final LocationService _locationService = LocationService();

  void _toggleSharing(String uid) async {
    if (_isSharing) {
      _timer?.cancel();
      setState(() => _isSharing = false);
    } else {
      bool hasPermission = await _locationService.checkPermission();
      if (hasPermission) {
        setState(() => _isSharing = true);
        // Update immediately
        _locationService.updateUserLocation(uid);
        // Then update every 30 seconds
        _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
          _locationService.updateUserLocation(uid);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng cấp quyền truy cập vị trí")),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;
    final isParent = user?.role == 'parent';

    return Scaffold(
      appBar: AppBar(
        title: Text(isParent ? "Chia sẻ vị trí (Cha mẹ)" : "Trạng thái theo dõi"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Icon định vị
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (isParent && _isSharing) || (!isParent) ? const Color(0xFF2EC8B8) : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              isParent 
                ? (_isSharing ? "Đang chia sẻ vị trí với con" : "Đang tắt chia sẻ")
                : "Đang theo dõi vị trí của cha mẹ",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),

            // Nút Tắt/Bật (Chỉ hiện cho Cha mẹ)
            if (isParent)
              ElevatedButton(
                onPressed: user == null ? null : () => _toggleSharing(user.uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSharing ? Colors.red.shade400 : Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSharing ? "Dừng chia sẻ" : "Bắt đầu chia sẻ",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            
            if (!isParent)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Bạn sẽ nhận được thông báo nếu vị trí của cha mẹ có dấu hiệu bất thường.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

