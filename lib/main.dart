import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_shell.dart';
import 'features/map/presentation/screens/map_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MeetApp()));
}

final _router = GoRouter(
  initialLocation: '/map',
  redirect: (context, state) {
    // If not logged in, always go to login
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn = state.uri.toString() == '/login';
    if (user == null && !loggingIn) return '/login';
    
    // If logged in and at login page, go to map
    if (user != null && loggingIn) return '/map';
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return ChatScreen(
          targetUserId: extras['userId'],
          targetName: extras['userName'],
          targetAvatar: extras['userAvatar'],
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return HomeShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class MeetApp extends StatelessWidget {
  const MeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Meet',
      theme: MeetAppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
