import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isServiceRunning = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await NotificationsListener.hasPermission ?? false;
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermission() async {
    await NotificationsListener.openPermissionSettings();
    // Wait a bit and check again
    await Future.delayed(const Duration(seconds: 1));
    _checkPermission();
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      final stopped = await NotificationsListener.stopService() ?? false;
      setState(() {
        _isServiceRunning = !stopped;
      });
    } else {
      final started = await NotificationsListener.startService() ?? false;
      setState(() {
        _isServiceRunning = started;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexly Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isServiceRunning ? Icons.check_circle : Icons.error,
                          color: _isServiceRunning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isServiceRunning ? 'Running' : 'Stopped',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_hasPermission)
              ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.settings),
                label: const Text('Grant Notification Access'),
              )
            else
              ElevatedButton.icon(
                onPressed: _toggleService,
                icon: Icon(_isServiceRunning ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isServiceRunning ? 'Stop Service' : 'Start Service',
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/summary'),
              icon: const Icon(Icons.list),
              label: const Text('View Summary'),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Nexly Works',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Grant notification access permission\n'
                        '2. Start the service to begin capturing notifications\n'
                        '3. Notifications are stored silently throughout the day\n'
                        '4. View your daily summary at your convenience',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
