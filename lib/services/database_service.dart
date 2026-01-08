import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/checkup_model.dart';
import '../models/location_model.dart';
import '../models/checkin_model.dart';


class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersCollection => _db.collection('users');
  CollectionReference get _medicinesCollection => _db.collection('medicines');
  CollectionReference get _checkupsCollection => _db.collection('checkups');
  CollectionReference get _locationsCollection => _db.collection('locations');
  CollectionReference get _checkinsCollection => _db.collection('checkins');


  // --- User Operations ---

  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
    return null;
  }

  // Cập nhật thông tin người dùng linh hoạt
  Future<void> updateUserInfo(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  Future<void> updateUserName(String uid, String newName) async {
    await _usersCollection.doc(uid).update({'name': newName});
  }

  // --- Medicine Operations ---

  Future<void> addMedicine(MedicineModel medicine) async {
    DocumentReference docRef = _medicinesCollection.doc();
    await docRef.set(medicine.toMap());
  }
  
  Stream<List<MedicineModel>> getMedicines(String userId) {
    return _medicinesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MedicineModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateMedicineStatus(String id, bool isConfirmed) async {
    await _medicinesCollection.doc(id).update({'isConfirmed': isConfirmed});
  }

  Future<void> deleteMedicine(String id) async {
    await _medicinesCollection.doc(id).delete();
  }

  // --- Checkup Operations ---

  Future<void> addCheckup(CheckupModel checkup) async {
    await _checkupsCollection.add(checkup.toMap());
  }

  Future<void> deleteCheckup(String id) async {
    await _checkupsCollection.doc(id).delete();
  }

  Stream<List<CheckupModel>> getCheckups(String userId) {
    return _checkupsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CheckupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- Location Operations ---

  Future<void> updateLocation(LocationModel location) async {
    await _locationsCollection.add(location.toMap());
  }

  Stream<LocationModel?> getLastLocation(String userId) {
    return _locationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return LocationModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // --- Check-in Operations ---

  Future<void> addCheckIn(CheckInModel checkin) async {
    // Use date (YYYY-MM-DD) as document ID to ensure only one check-in per day
    String dateId = "${checkin.date.year}-${checkin.date.month}-${checkin.date.day}";
    String docId = "${checkin.userId}_$dateId";
    await _checkinsCollection.doc(docId).set(checkin.toMap());
  }

  Stream<List<CheckInModel>> getCheckIns(String userId, DateTime month) {
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _checkinsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CheckInModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<bool> hasCheckedInToday(String userId) async {
    DateTime now = DateTime.now();
    String dateId = "${now.year}-${now.month}-${now.day}";
    String docId = "${userId}_$dateId";
    DocumentSnapshot doc = await _checkinsCollection.doc(docId).get();
    return doc.exists;
  }
}
