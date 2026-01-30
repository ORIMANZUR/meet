import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
import '../../../map/presentation/providers/map_providers.dart';
import '../../../map/domain/models/user_marker_model.dart';
import '../../data/storage_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAvailable = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vibeController = TextEditingController();
  String _avatarUrl = 'https://i.pravatar.cc/150?u=me';
  String? _storyImageUrl;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if(mounted) {
      setState(() {
        _nameController.text = "Diagnostic User";
        _vibeController.text = "Just chilling \uD83C\uDF03";
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadStoryImage() async {
    // DIAGNOSTIC - MOCK PICKER
    // final picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    // if (image == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Picker Disabled")));
  }

  Future<void> _saveProfile() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Saved! (Mock)")));
    }
  }

  Future<void> _logout() async {
    if(mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // UI REMAINS SAME
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFCCFF00))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _storyImageUrl != null 
                    ? CachedNetworkImage(
                        imageUrl: _storyImageUrl!, 
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[900]),
                      )
                    : CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800&q=80',
                        fit: BoxFit.cover,
                      ),
                  Container(color: Colors.black.withOpacity(0.3)),
                  Center(
                    child: _isUploading 
                      ? const CircularProgressIndicator(color: Color(0xFFCCFF00))
                      : IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                          onPressed: _pickAndUploadStoryImage,
                          style: IconButton.styleFrom(backgroundColor: Colors.black26),
                        ),
                  ),
                ],
              ),
              title: const Text("My Profile"),
              centerTitle: true,
            ),
            actions: [
              IconButton(onPressed: _saveProfile, icon: const Icon(Icons.save, color: Color(0xFFCCFF00))),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.red)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Avatar & Status
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(_avatarUrl),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _isAvailable ? const Color(0xFFCCFF00) : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Editor
                   TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "Your Name",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.edit, color: Colors.white54, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Availability Toggle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141416),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isAvailable ? const Color(0xFFCCFF00).withOpacity(0.5) : Colors.white10,
                      ),
                      boxShadow: _isAvailable
                          ? [BoxShadow(color: const Color(0xFFCCFF00).withOpacity(0.2), blurRadius: 15)]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Be Visible",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                            Text(
                              "Show on map",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Switch(
                          value: _isAvailable,
                          activeColor: Colors.black,
                          activeTrackColor: const Color(0xFFCCFF00),
                          onChanged: (val) {
                             setState(() => _isAvailable = val);
                             _saveProfile();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vibe Editor
                  Text("Current Vibe", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _vibeController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF141416),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.bolt_rounded, color: Color(0xFF00E5FF)),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
