import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_marker_model.dart';
import '../../data/firebase_map_repository.dart';

final mapRepositoryProvider = Provider((ref) => FirebaseMapRepository());

final nearbyUsersProvider = StreamProvider<List<UserMarkerModel>>((ref) {
  final repo = ref.watch(mapRepositoryProvider);
  return repo.getNearbyUsers();
});
