import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/notification_item.dart';
import 'screens/dashboard_screen.dart';
import 'screens/summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NotificationItemAdapter());
  await Hive.openBox<NotificationItem>('notifications');

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
  ],
);
