import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../models/notification_item.dart';
import '../services/deep_link_service.dart';
import '../services/cactus_service.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Future<void> _openApp(String packageName) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: packageName,
      );
      await intent.launch();
    } catch (e) {
      debugPrint('Failed to open app: $e');
    }
  }

  Future<void> _clearAll() async {
    final box = Hive.box<NotificationItem>('notifications');
    await box.clear();
  }

  Future<String> _generateSummary(Box<NotificationItem> box) async {
    if (box.isEmpty) return '';

    final notifications = box.values
        .map((n) => '${n.title}: ${n.body}')
        .toList();

    return await CactusAIService.summarizeNotifications(notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All?'),
                  content: const Text(
                    'This will delete all captured notifications.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await _clearAll();
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<NotificationItem>(
          'notifications',
        ).listenable(),
        builder: (context, Box<NotificationItem> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications captured yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group notifications by package name
          final groupedNotifications = <String, List<NotificationItem>>{};
          for (var notification in box.values) {
            groupedNotifications
                .putIfAbsent(notification.packageName, () => [])
                .add(notification);
          }

          return Column(
            children: [
              // AI Summary Card
              if (box.isNotEmpty)
                Card(
                  margin: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Summary',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String>(
                          future: _generateSummary(box),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Generating summary...'),
                                ],
                              );
                            }
                            return Text(
                              snapshot.data ?? 'Unable to generate summary',
                              style: const TextStyle(height: 1.5),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: groupedNotifications.length,
                  itemBuilder: (context, index) {
                    final packageName = groupedNotifications.keys.elementAt(
                      index,
                    );
                    final notifications = groupedNotifications[packageName]!;

                    // Sort by timestamp (newest first)
                    notifications.sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.apps),
                        title: Text(packageName.split('.').last),
                        subtitle: Text(
                          '${notifications.length} notification(s)',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _openApp(packageName),
                        ),
                        children: notifications.map((notification) {
                          // Parse deep link actions
                          final actions = DeepLinkService.parseActions(
                            notification.title,
                            notification.body,
                          );

                          return ListTile(
                            title: Text(notification.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (notification.body.isNotEmpty)
                                  Text(
                                    notification.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(notification.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                // Deep link actions as text links
                                if (actions.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: actions.map((action) {
                                      return InkWell(
                                        onTap: () =>
                                            DeepLinkService.executeAction(
                                              action,
                                            ),
                                        child: Text(
                                          action.label,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                            isThreeLine:
                                notification.body.isNotEmpty ||
                                actions.isNotEmpty,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
