import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/upload/screens/upload_screen.dart';
import '../features/profile_detail/screens/profile_detail_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
    GoRoute(
      path: '/profile/:id',
      builder: (_, state) => ProfileDetailScreen(profileId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
  ],
);
