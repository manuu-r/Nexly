import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/notification_item.dart';
import 'screens/dashboard_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';
import 'services/cactus_service.dart';
import 'services/notification_scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NotificationItemAdapter());
  await Hive.openBox<NotificationItem>('notifications');

  // Initialize AI service (may fail silently)
  await CactusAIService.initialize();

  // Initialize notification scheduler
  await NotificationScheduler.initialize();

  runApp(const NexlyApp());
}

class NexlyApp extends StatelessWidget {
  const NexlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// Router configuration
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
