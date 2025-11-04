import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/avatar_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'providers/messages_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/habits/habits_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/multiplayer/multiplayer_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/customization/customization_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const LibrariumApp());
}

class LibrariumApp extends StatelessWidget {
  const LibrariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Librarium',
            theme: AppTheme.darkTheme,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/login' || 
                               state.matchedLocation == '/register';
        
        // Se não está autenticado e não está indo para tela de auth, redireciona para login
        if (!isAuthenticated && !isGoingToAuth) {
          return '/login';
        }
        
        // Se está autenticado e está indo para tela de auth, redireciona para dashboard
        if (isAuthenticated && isGoingToAuth) {
          return '/dashboard';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
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
      refreshListenable: authProvider,
    );
  }
}
