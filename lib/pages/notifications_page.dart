import 'package:CiTY/pages/report_details_page.dart';
import 'package:CiTY/pages/submitted_page.dart';
import 'package:flutter/material.dart';
import 'package:CiTY/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:CiTY/l10n/app_localizations.dart'; // Add this import

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Get localizations
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: SubmittedPage.mainBlue,
        title: Text(
          loc.notifications, // Use translated title
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<Box<NotificationModel>>(
        valueListenable: _notificationService.listenable,
        builder: (context, box, _) {
          final notifications = box.values.toList().cast<NotificationModel>();
          notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                loc.noNotificationsYet, // Use translated text
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final notif = notifications[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                color: Colors.white,
                child: ListTile(
                  onTap: () {
                    // Navigate to details page if complaintId exists
                    if (notif.data['complaintId'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailsPage(
                            complaintId: notif.data['complaintId'],
                          ),
                        ),
                      );
                    }
                  },
                  leading: const Icon(
                    Icons.notifications,
                    color: Color(0xFF1757C2),
                  ),
                  title: Text(
                    notif.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.body,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notif.receivedAt), // Show relative time
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
