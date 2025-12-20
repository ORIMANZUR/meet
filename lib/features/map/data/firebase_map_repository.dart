import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/user_marker_model.dart';

class FirebaseMapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserMarkerModel>> getNearbyUsers() {
    // simple query for now, can be improved with GeoFlutterFire later
    return _firestore.collection('users').where('isOnline', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserMarkerModel.fromFirestore(doc)).toList();
    });
  }

  Future<UserMarkerModel?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserMarkerModel.fromFirestore(doc);
  }

  Future<void> updateUserStatus(UserMarkerModel userModel) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // Ensure we are writing to the current user's document
    await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore(), SetOptions(merge: true));
  }
}
