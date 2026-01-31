import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/main_shell.dart';

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Welcome/Onboarding
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Mood Tracker (placeholder)
          GoRoute(
            path: '/mood',
            name: 'mood',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Mood Tracker')),
            ),
          ),
          
          // Journal (placeholder)
          GoRoute(
            path: '/journal',
            name: 'journal',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Journal')),
            ),
          ),
          
          // Chat (placeholder)
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('AI Chat')),
            ),
          ),
          
          // Profile (placeholder)
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Profile')),
            ),
          ),
        ],
      ),
      
      // Search (standalone)
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Search')),
        ),
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
