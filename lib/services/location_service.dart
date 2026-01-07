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
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      await _db.collection('users').doc(uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdateTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error silently or use a logger
    }
  }

  /// Get a stream of the child's location updates
  Stream<DocumentSnapshot> getChildLocationStream(String childUid) {
    return _db.collection('users').doc(childUid).snapshots();
  }
}
