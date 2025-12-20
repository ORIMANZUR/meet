import '../domain/models/user_marker_model.dart';

class MockMapRepository {
  Future<List<UserMarkerModel>> getNearbyUsers() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return [
      const UserMarkerModel(
        id: '1',
        name: 'Alex',
        latitude: 37.7749,
        longitude: -122.4194,
        vibe: 'Grab a coffee? ☕',
        isOnline: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=1',
      ),
      const UserMarkerModel(
        id: '2',
        name: 'Sarah',
        latitude: 37.7760,
        longitude: -122.4210,
        vibe: 'Walking the dog 🐕',
        isOnline: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=2',
      ),
       const UserMarkerModel(
        id: '3',
        name: 'Mike',
        latitude: 37.7720,
        longitude: -122.4150,
        vibe: 'Anyone for tennis? 🎾',
        isOnline: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=3',
      ),
    ];
  }
}
