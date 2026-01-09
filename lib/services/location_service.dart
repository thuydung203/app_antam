import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if location services are enabled and permissions are granted
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Update the user's current location in Firestore
  Future<void> updateUserLocation(String uid) async {
    try {
      // --- PHẦN ĐÃ SỬA ---
      // Dùng desiredAccuracy thay cho locationSettings để tương thích
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // -------------------

      await _db.collection('users').doc(uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdateTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi lấy vị trí: $e"); // Nên in lỗi ra để dễ debug
    }
  }

  /// Get a stream of the child's location updates
  Stream<DocumentSnapshot> getChildLocationStream(String childUid) {
    return _db.collection('users').doc(childUid).snapshots();
  }
}
