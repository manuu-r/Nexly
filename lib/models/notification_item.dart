import 'package:hive/hive.dart';

part 'notification_item.g.dart';

@HiveType(typeId: 0)
class NotificationItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String packageName;

  @HiveField(2)
  String title;

  @HiveField(3)
  String body;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  bool isRead;

  NotificationItem({
    required this.id,
    required this.packageName,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'packageName': packageName,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        packageName: json['packageName'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}
