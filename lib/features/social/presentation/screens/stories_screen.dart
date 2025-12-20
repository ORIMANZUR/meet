import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../map/presentation/providers/map_providers.dart';
import '../../../map/domain/models/user_marker_model.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
// Let's use the storage repo directly here.
import '../../../profile/data/storage_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  final PageController _pageController = PageController();
  bool _isUploading = false;

  Future<void> _pickAndUploadStory() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return;

    setState(() => _isUploading = true);

    // Read storage repo
    final storageRepo = ref.read(storageRepositoryProvider);
    final downloadUrl = await storageRepo.uploadStoryImage(File(image.path));

    if (downloadUrl != null) {
      // Update user profile in Firestore directly
      final mapRepo = ref.read(mapRepositoryProvider);
      final user = await mapRepo.getUserProfile();
      
      if (user != null) {
        // Create updated user model with new story image
        final updatedUser = user.copyWith(storyImageUrl: downloadUrl);
        await mapRepo.updateUserStatus(updatedUser);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Vibe posted! \u2728"),
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

  @override
  Widget build(BuildContext context) {
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);
    // ... (rest of build)
    
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadStory,
        backgroundColor: const Color(0xFFCCFF00),
        foregroundColor: Colors.black,
        child: _isUploading 
          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.black))
          : const Icon(Icons.add_a_photo_rounded),
      ),
      body: Stack(
        children: [
          nearbyUsersAsync.when(
            data: (users) {
              final storyUsers = users.where((u) => u.vibe.isNotEmpty).toList();

              if (storyUsers.isEmpty) {
                return _buildEmptyState();
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: storyUsers.length,
                itemBuilder: (context, index) {
                  return _StoryCard(user: storyUsers[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
            error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.white))),
          ),
          
          // Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Text(
                "Local Vibe",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
   // ... existing empty state
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.nights_stay_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text("No vibes nearby yet.", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickAndUploadStory, // Now triggers upload
            child: const Text("Be the first!", style: TextStyle(color: Color(0xFFCCFF00))),
          )
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
    // ... existing story card
  final UserMarkerModel user;

  const _StoryCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        CachedNetworkImage(
          imageUrl: user.storyImageUrl ?? "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&q=80",
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
          errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
        ),
        // Overlay Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: 100, // Above navbar
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.avatarUrl), // Updated to use cached
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      Text(
                        "Nearby • Just now", 
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.vibe,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.push('/chat', extra: {
                        'userId': user.id,
                        'userName': user.name,
                        'userAvatar': user.avatarUrl,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Say Hi 👋"),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
