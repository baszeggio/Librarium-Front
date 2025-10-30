import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/avatar_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/habits/habits_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/multiplayer/multiplayer_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/customization/customization_screen.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  runApp(LibrariumApp(initialToken: token));
}

class LibrariumApp extends StatelessWidget {
  final String? initialToken;
  
  const LibrariumApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Librarium',
            theme: AppTheme.darkTheme,
            routerConfig: _createRouter(authProvider.isAuthenticated),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(bool isAuthenticated) {
    return GoRouter(
      initialLocation: '/dashboard', // Sempre vai direto para o dashboard
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/habits',
          builder: (context, state) => const HabitsScreen(),
        ),
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: '/multiplayer',
          builder: (context, state) => const MultiplayerScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/customization',
          builder: (context, state) => const CustomizationScreen(),
        ),
      ],
    );
  }
}
