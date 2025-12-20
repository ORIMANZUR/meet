import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_providers.dart';
import '../../domain/models/user_marker_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../profile/data/storage_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'package:meet/core/utils/marker_generator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  String? _darkMapStyle;
  Set<Marker> _markers = {};
  bool _isUploading = false;
  bool _hasPermission = false;
  // Cache for generated marker icons to verify performance
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermission();
    });
  }

  Future<void> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.always || requested == LocationPermission.whileInUse) {
        if (mounted) setState(() => _hasPermission = true);
      }
    } else {
      if (mounted) setState(() => _hasPermission = true);
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      _darkMapStyle = await rootBundle.loadString('assets/map_style.json');
      if (_controller != null) {
        _controller!.setMapStyle(_darkMapStyle);
      }
    } catch (e) {
      debugPrint("Error loading map style: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (_darkMapStyle != null) {
      _controller!.setMapStyle(_darkMapStyle);
    }
  }

  void _showUserSheet(UserMarkerModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailSheet(user: user),
    );
  }

  Future<void> _pickAndUploadStory() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return;

    setState(() => _isUploading = true);

    final storageRepo = ref.read(storageRepositoryProvider);
    final downloadUrl = await storageRepo.uploadStoryImage(File(image.path));

    if (downloadUrl != null) {
      final mapRepo = ref.read(mapRepositoryProvider);
      final user = await mapRepo.getUserProfile();
      
      if (user != null) {
        final updatedUser = user.copyWith(storyImageUrl: downloadUrl);
        await mapRepo.updateUserStatus(updatedUser);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Vibe posted! ✨"),
            backgroundColor: Color(0xFFCCFF00),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload Failed")));
    }
    
    if(mounted) setState(() => _isUploading = false);
  }

  void _showStoryViewer(UserMarkerModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Full Screen Image
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: user.storyImageUrl ?? "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&q=80",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Info Overlay
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.avatarUrl)),
                      const SizedBox(width: 10),
                      Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                   ),
                   const SizedBox(height: 10),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     decoration: BoxDecoration(
                       color: Colors.black54,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Text(user.vibe, style: const TextStyle(color: Colors.white, fontSize: 16)),
                   ),
                   const SizedBox(height: 20),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/chat', extra: {
                            'userId': user.id,
                            'userName': user.name,
                            'userAvatar': user.avatarUrl,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCCFF00),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Say Hi 👋"),
                     ),
                   )
                ],
              ),
            ),
            // Close Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMarkers(List<UserMarkerModel> users) async {
    final myId = FirebaseAuth.instance.currentUser?.uid;
    final Set<Marker> newMarkers = {};

    for (final user in users) {
      // Check cache first
      BitmapDescriptor icon = _markerIconCache[user.id] ?? BitmapDescriptor.defaultMarker;
      
      // If not in cache or if it's the default marker (meaning we haven't generated custom yet)
      if (!_markerIconCache.containsKey(user.id)) {
        final isMe = user.id == myId;
        final borderColor = isMe ? const Color(0xFFCCFF00) : const Color(0xFF00E5FF);
        
        try {
          icon = await MarkerGenerator.createCustomMarkerBitmap(
            user.avatarUrl, 
            borderColor: borderColor,
            size: 150
          );
          _markerIconCache[user.id] = icon;
        } catch (e) {
          debugPrint("Failed to generate marker for ${user.name}: $e");
        }
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(user.id),
          position: LatLng(user.latitude, user.longitude),
          icon: icon,
          onTap: () => _showUserSheet(user),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(nearbyUsersProvider);

    ref.listen(nearbyUsersProvider, (previous, next) {
      next.whenData((users) {
        _updateMarkers(users);
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          if (_hasPermission)
            GoogleMap(
              initialCameraPosition: _kInitialPosition,
              onMapCreated: _onMapCreated,
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              style: _darkMapStyle, 
            )
          else
            Container(
              color: const Color(0xFF141416),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
              ),
            ),
          
          // ... Rest of the UI
          
          // Top Stories Rail Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // Gradient removed for cleaner look
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Local Vibe",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Colors.white))
                        ],
                      ),
                    ),
                    
                    // Stories List
                    SizedBox(
                      height: 110,
                      child: usersAsync.when(
                        data: (users) {
                           // Authenticated user story logic
                           final myId = FirebaseAuth.instance.currentUser?.uid;
                           final me = users.firstWhere((u) => u.id == myId, orElse: () => UserMarkerModel(id: 'temp', name: 'Me', latitude: 0, longitude: 0, vibe: '', isOnline: true, avatarUrl: FirebaseAuth.instance.currentUser?.photoURL ?? 'https://i.pravatar.cc/150?u=me'));
                           
                           final storyUsers = users.where((u) => u.id != myId && u.vibe.isNotEmpty).toList();

                           return ListView.separated(
                             scrollDirection: Axis.horizontal,
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             itemCount: 1 + storyUsers.length,
                             separatorBuilder: (_, __) => const SizedBox(width: 15),
                             itemBuilder: (context, index) {
                               if (index == 0) {
                                  // Me Bubble
                                  return GestureDetector(
                                    onTap: _pickAndUploadStory,
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(colors: [Color(0xFFCCFF00), Colors.cyanAccent]),
                                                border: Border.all(color: Colors.transparent, width: 2),
                                              ),
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.grey[900],
                                                backgroundImage: CachedNetworkImageProvider(me.avatarUrl), 
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: _isUploading 
                                               ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                               : const Icon(Icons.add, color: Color(0xFFCCFF00), size: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Text("Your Vibe", style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ],
                                    ),
                                  );
                               }
                               
                               final user = storyUsers[index - 1];
                               return GestureDetector(
                                 onTap: () => _showStoryViewer(user),
                                 child: Column(
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.all(2),
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                                       ),
                                       child: CircleAvatar(
                                         radius: 28,
                                         backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                                       ),
                                     ),
                                     const SizedBox(height: 5),
                                     SizedBox(
                                       width: 60,
                                       child: Text(
                                         user.name, 
                                         style: const TextStyle(color: Colors.white, fontSize: 12),
                                         overflow: TextOverflow.ellipsis,
                                         textAlign: TextAlign.center,
                                       ),
                                     ),
                                   ],
                                 ),
                               );
                             },
                           );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
                        error: (_,__) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailSheet extends StatelessWidget {
    final UserMarkerModel user;
  const _UserDetailSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(user.avatarUrl), // Updated to cached
                backgroundColor: Colors.grey[800],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCFF00), // Neon Lime
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Online Now",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFCCFF00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.vibe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                 if (context.mounted) {
                    context.push('/chat', extra: {
                      'userId': user.id,
                      'userName': user.name,
                      'userAvatar': user.avatarUrl,
                    });
                  }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Send Meet Request",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
