import '../domain/models/user_marker_model.dart';

class FirebaseMapRepository {
  // FINAL DIAGNOSTIC: DISABLING FIRESTORE
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserMarkerModel>> getNearbyUsers() {
    return Stream.value([]);
  }

  Future<UserMarkerModel?> getUserProfile() async {
    return null;
  }

  Future<void> updateUserStatus(UserMarkerModel userModel) async {
    return;
  }
}
