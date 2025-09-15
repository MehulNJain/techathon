import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ADD THIS LINE
import 'package:hive/hive.dart';

part 'notification_service.g.dart'; // Add this line

@HiveType(typeId: 2) // Use a unique typeId (e.g., 2 if others are used)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final DateTime receivedAt;

  @HiveField(3)
  final Map<String, dynamic> data;

  NotificationModel({
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.data,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late Box<NotificationModel> _notificationBox;

  Future<void> init() async {
    _notificationBox = await Hive.openBox<NotificationModel>('notifications');
  }

  // Use a ValueListenable from the Hive box directly
  ValueListenable<Box<NotificationModel>> get listenable =>
      _notificationBox.listenable();

  Future<void> addNotification(NotificationModel notification) async {
    // Add new notifications to the box. Hive handles the rest.
    await _notificationBox.add(notification);
  }
}
