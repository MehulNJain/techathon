import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I submit a complaint?",
      "answer":
          "Go to the home page and tap the '+' button or 'Report Issue' to submit a new complaint.",
    },
    {
      "question": "How can I track my complaint status?",
      "answer":
          "Open 'My Reports' to see the status and details of all your complaints.",
    },
    {
      "question": "How do I update my profile information?",
      "answer":
          "Tap the edit icon on your profile page to update your name or email.",
    },
    {
      "question": "What do the different complaint statuses mean?",
      "answer":
          "Pending: Waiting for review.\nAssigned: Assigned to a worker.\nIn Progress: Work has started.\nResolved: Issue has been fixed.",
    },
    {
      "question": "How do I raise a grievance if my complaint is not resolved?",
      "answer":
          "Open the complaint details and tap 'Raise Grievance' at the bottom.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1757C2),
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final faq = faqs[i];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            color: Colors.white,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                faq["question"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    faq["answer"] ?? "",
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
