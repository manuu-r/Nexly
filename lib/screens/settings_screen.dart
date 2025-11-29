import 'package:flutter/material.dart';
import 'package:nexly/services/notification_scheduler.dart';

/// Settings screen for configuring Nexly
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _summaryTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await NotificationScheduler.getSummaryTime();
    setState(() {
      _summaryTime = TimeOfDay(hour: time.hour, minute: time.minute);
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _summaryTime,
    );

    if (picked != null && picked != _summaryTime) {
      setState(() {
        _summaryTime = picked;
      });

      // Update the scheduled time
      await NotificationScheduler.updateSummaryTime(picked.hour, picked.minute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily summary time updated to ${picked.format(context)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    await NotificationScheduler.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Daily Summary Section
                const ListTile(
                  title: Text(
                    'Daily Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Summary Time'),
                  subtitle: Text(
                    'Get your daily summary at ${_summaryTime.format(context)}',
                  ),
                  trailing: TextButton(
                    onPressed: _selectTime,
                    child: const Text('Change'),
                  ),
                  onTap: _selectTime,
                ),

                const Divider(),

                // Notifications Section
                const ListTile(
                  title: Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notification_add),
                  title: const Text('Test Notification'),
                  subtitle: const Text(
                    'Send a test notification to verify it works',
                  ),
                  trailing: TextButton(
                    onPressed: _testNotification,
                    child: const Text('Send'),
                  ),
                  onTap: _testNotification,
                ),

                const Divider(),

                // About Section
                const ListTile(
                  title: Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.description),
                  title: Text('About Nexly'),
                  subtitle: Text(
                    'Your personal notification secretary that batches notifications into daily summaries',
                  ),
                ),
              ],
            ),
    );
  }
}
