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

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MaterialApp(
//     home: Scaffold(
//       backgroundColor: Colors.blue,
//       body: Center(
//         child: Text(
//           'SAFE MODE - DIAGNOSTIC BUILD',
//           style: TextStyle(color: Colors.white, fontSize: 24),
//         ),
//       ),
//     ),
//   ));
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final router = createRouter();
    runApp(ProviderScope(child: MeetApp(router: router)));
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Text(
                'STARTUP ERROR:\n$e',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

GoRouter createRouter() {
  return GoRouter(
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
          final extras = (state.extra as Map?)?.cast<String, dynamic>();
          if (extras == null) return const MapScreen(); // Safety fallback
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
}

class MeetApp extends StatelessWidget {
  final GoRouter router;
  const MeetApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Meet',
      theme: MeetAppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
