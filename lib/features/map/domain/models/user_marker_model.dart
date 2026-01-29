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

  // REMOVED FOR DIAGNOSTICS
  // factory UserMarkerModel.fromFirestore(DocumentSnapshot doc) { ... }
  // Map<String, dynamic> toFirestore() { ... }

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
