import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:CiTY/services/notification_service.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // This method now only initializes listeners and permissions.
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification when app is opened from a terminated state
    _firebaseMessaging.getInitialMessage().then(_handleMessage);

    // Handle notification when app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle notification when app is opened from the background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Listen for token refresh and save it if the user is logged in
    _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null || message.notification == null) return;

    debugPrint('Message handled: ${message.notification?.title}');

    final notification = NotificationModel(
      title: message.notification!.title ?? 'No Title',
      body: message.notification!.body ?? 'No Body',
      receivedAt: DateTime.now(),
      data: message.data,
    );

    // Add the notification to our service
    NotificationService().addNotification(notification);
  }

  // New public method to save the token. Call this after login.
  Future<void> saveTokenToDatabase([String? token]) async {
    final user = FirebaseAuth.instance.currentUser;
    // Exit if user is not logged in
    if (user == null || user.phoneNumber == null) {
      return;
    }

    // Get the current token if not provided
    token ??= await _firebaseMessaging.getToken();

    debugPrint("Saving FCM Token for user ${user.phoneNumber}: $token");
    try {
      final userRef = FirebaseDatabase.instance.ref(
        'users/${user.phoneNumber}',
      );
      await userRef.update({'fcmToken': token});
    } catch (e) {
      debugPrint("Error saving FCM token: $e");
    }
  }

  // --- ADD THIS NEW METHOD FOR WORKERS ---
  Future<void> saveWorkerTokenToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final workerId = prefs.getString('workerId');

    // Exit if worker is not logged in
    if (workerId == null) {
      debugPrint("Worker not logged in, cannot save token.");
      return;
    }

    final token = await _firebaseMessaging.getToken();
    if (token == null) {
      debugPrint("Failed to get FCM token for worker.");
      return;
    }

    debugPrint("Saving FCM Token for worker $workerId: $token");
    try {
      final workerRef = FirebaseDatabase.instance.ref('workers/$workerId');
      await workerRef.update({'fcmToken': token});
    } catch (e) {
      debugPrint("Error saving worker FCM token: $e");
    }
  }
}
