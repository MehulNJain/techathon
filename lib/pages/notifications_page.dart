import 'package:CiTY/pages/submitted_page.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Complaint Resolved",
      "body": "Your complaint CR-2024-08-001234 has been resolved.",
      "time": "2 hours ago",
    },
    {
      "title": "Complaint Assigned",
      "body": "A municipal worker has been assigned to your complaint.",
      "time": "Yesterday",
    },
    {
      "title": "New Update",
      "body": "Your complaint status has been updated.",
      "time": "3 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // Same as other pages
      appBar: AppBar(
        backgroundColor: SubmittedPage.mainBlue, // Main blue
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : ListView.separated(
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
                    leading: Icon(
                      Icons.notifications,
                      color: Color(0xFF1757C2),
                    ),
                    title: Text(
                      notif["title"] ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif["body"] ?? "",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          notif["time"] ?? "",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
