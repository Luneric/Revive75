import 'package:flutter/material.dart';

// Import feature pages here as you create them
import 'profile_page.dart';
import 'meal_page.dart';
import 'workout_page.dart';

class AppRoutes {
  // Core routes
  static const String profile = '/profile';
  static const String meal = '/meal';
  static const String workout = '/workout';
  // You can add more routes like:
  // static const String settings = '/settings';
  // static const String chat = '/chat';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case AppRoutes.meal:
        return MaterialPageRoute(
          builder: (_) => const MealPage(),
          settings: settings,
        );

      case AppRoutes.workout:
        return MaterialPageRoute(
          builder: (_) => const WorkoutPage(),
          settings: settings,
      );
      // Add new routes here as your app grows
      // Example:
      // case AppRoutes.settings:
      //   return MaterialPageRoute(
      //     builder: (_) => const SettingsPage(),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }
}

/// Fallback page for undefined routes
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Text('Page not found'),
      ),
    );
  }
}