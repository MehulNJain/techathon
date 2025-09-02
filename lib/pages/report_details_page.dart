import 'package:flutter/material.dart';
import 'home_page.dart';
import 'reports_page.dart';
import 'user_profile_page.dart';

class ReportDetailsPage extends StatelessWidget {
  const ReportDetailsPage({Key? key}) : super(key: key);

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Dummy images for demo
    final List<String> photoUrls = [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    ];

    final List<String> beforeAfterUrls = [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    ];

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
                                children: const [
                                  Text(
                                    "Road Damage - Pothole",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Aug 29, 2024 at 4:15 PM",
                                    style: TextStyle(
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
                          children: const [
                            Icon(Icons.location_on, color: mainBlue, size: 18),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Main Road, Near City Mall, Sector 18",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.tag, color: Colors.grey, size: 18),
                            SizedBox(width: 4),
                            Text(
                              "REF: CR-2024-08-001234",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            Spacer(),
                            Chip(
                              label: Text(
                                "Resolved",
                                style: TextStyle(
                                  color: Color(0xFF12B76A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              backgroundColor: Color(0xFFD1FADF),
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
                            itemCount: photoUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photoUrls[i],
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
                        const Text(
                          "Large pothole on main road causing traffic issues and vehicle damage. Water accumulates during rain making it dangerous for two-wheelers. Immediate repair needed.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
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
                                // TODO: Play voice note
                              },
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "0:45 duration",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Timeline
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
                          icon: Icons.check_circle,
                          color: const Color(0xFF12B76A),
                          title: "Resolved",
                          date: "Aug 31, 2024 at 3:30 PM",
                          desc: "Issue fixed by Municipal Corporation team",
                        ),
                        _timelineTile(
                          icon: Icons.cancel,
                          color: mainBlue,
                          title: "In Progress",
                          date: "Aug 30, 2024 at 10:15 AM",
                          desc: "Assigned to repair team",
                        ),
                        _timelineTile(
                          icon: Icons.radio_button_unchecked,
                          color: Colors.grey,
                          title: "Submitted",
                          date: "Aug 29, 2024 at 4:15 PM",
                          desc: "Report submitted by citizen",
                        ),
                      ],
                    ),
                  ),

                  // Resolution Details
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
                          "Resolution Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Pothole has been filled with hot mix asphalt and road surface has been leveled. Traffic flow restored to normal.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Before & After Photos",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: beforeAfterUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                beforeAfterUrls[i],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Resolved by: Municipal Corporation Team - Sector 18",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.report_gmailerrorred,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Raise Grievance",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Raise grievance
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "Back to My Reports",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => MyReportsPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar
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
                  // Go to report issue
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => HomePage(fullName: ""),
                    ), // or ReportIssuePage()
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
