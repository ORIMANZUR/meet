import 'package:cloud_firestore/cloud_firestore.dart';

class UserMarkerModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String vibe;
  final bool isOnline;
  final String avatarUrl;
  final String? storyImageUrl;
  final DateTime? lastActive;

  const UserMarkerModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.vibe,
    required this.isOnline,
    required this.avatarUrl,
    this.storyImageUrl,
    this.lastActive,
  });

  factory UserMarkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final geo = data['location'] as GeoPoint? ?? const GeoPoint(0, 0);
    return UserMarkerModel(
      id: doc.id,
      name: data['name'] ?? 'Anonymous',
      latitude: geo.latitude,
      longitude: geo.longitude,
      vibe: data['vibe'] ?? '',
      isOnline: data['isOnline'] ?? false,
      avatarUrl: data['avatarUrl'] ?? 'https://i.pravatar.cc/150?u=anon',
      storyImageUrl: data['storyImageUrl'],
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': GeoPoint(latitude, longitude),
      'vibe': vibe,
      'isOnline': isOnline,
      'avatarUrl': avatarUrl,
      'storyImageUrl': storyImageUrl,
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  UserMarkerModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? vibe,
    bool? isOnline,
    String? avatarUrl,
    String? storyImageUrl,
  }) {
    return UserMarkerModel(
      id: id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      vibe: vibe ?? this.vibe,
      isOnline: isOnline ?? this.isOnline,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storyImageUrl: storyImageUrl ?? this.storyImageUrl,
      lastActive: lastActive,
    );
  }
}
