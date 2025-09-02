import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_data.dart';
import 'home_page.dart';
import 'reports_page.dart';
import 'user_profile_page.dart';

class ReportDetailsPage extends StatelessWidget {
  final ReportData report;
  const ReportDetailsPage({Key? key, required this.report}) : super(key: key);

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Report Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: mainBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.directions_car,
                                color: mainBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${report.category} - ${report.subcategory}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    report.dateTime,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: mainBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.location,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.tag, color: Colors.grey, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "REF: ${report.complaintId}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            const Chip(
                              label: Text(
                                "Pending Review",
                                style: TextStyle(
                                  color: Color(0xFFB26A00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              backgroundColor: Color(0xFFFFF6E0),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Photos Submitted
                  if (report.photoPaths.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Photos Submitted",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 70,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: report.photoPaths.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(report.photoPaths[i]),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Issue Description & Voice Note
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Issue Description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (report.voiceNotePath != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: mainBlue,
                                ),
                                label: const Text(
                                  "Play Voice Note",
                                  style: TextStyle(
                                    color: mainBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainBlue.withOpacity(0.08),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Play voice note using report.voiceNotePath
                                },
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Voice Note",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Timeline (dummy, you can add real status if you want)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Status Timeline",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _timelineTile(
                          icon: Icons.radio_button_unchecked,
                          color: Colors.grey,
                          title: "Submitted",
                          date: report.dateTime,
                          desc: "Report submitted by citizen",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar (same as before)
          Container(
            decoration: BoxDecoration(
              color: navBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: navBg,
              currentIndex: 2,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: mainBlue,
              unselectedItemColor: Colors.grey,
              iconSize: width * 0.065,
              selectedFontSize: width * 0.03,
              unselectedFontSize: width * 0.028,
              elevation: 0,
              showUnselectedLabels: true,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomePage(fullName: ""),
                    ),
                    (route) => false,
                  );
                } else if (index == 1) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomePage(fullName: "")),
                    (route) => false,
                  );
                } else if (index == 2) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => MyReportsPage()),
                    (route) => false,
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => UserProfilePage()),
                    (route) => false,
                  );
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 0 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.home, color: Colors.grey),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 1 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_circle_outline, color: Colors.grey),
                  ),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mainBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.list_alt, color: mainBlue),
                  ),
                  label: "Complaints",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 3 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineTile({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 22),
              Container(width: 2, height: 32, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
