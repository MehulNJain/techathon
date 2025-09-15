import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/notification_service.dart';
import 'worker_complaint_page.dart';

class WorkerNotificationsPage extends StatelessWidget {
  const WorkerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<Box<NotificationModel>>(
        valueListenable: notificationService.listenable,
        builder: (context, box, _) {
          final notifications = box.values.toList().cast<NotificationModel>();
          notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet.",
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
                    if (notif.data['complaintId'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerComplaintPage(
                            complaintId: notif.data['complaintId'],
                          ),
                        ),
                      );
                    }
                  },
                  leading: const Icon(
                    Icons.assignment_ind,
                    color: Colors.orange,
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
                        timeago.format(notif.receivedAt),
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
