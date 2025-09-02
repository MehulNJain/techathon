import 'package:flutter/material.dart';
import 'reports_page.dart';
import 'report_issue_page.dart';
import 'user_profile_page.dart';

class HomePage extends StatefulWidget {
  final String fullName;

  const HomePage({super.key, required this.fullName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Go to ReportIssuePage and reset to Home on return
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportIssuePage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyReportsPage()),
      );
      setState(() {
        _selectedIndex = 2;
      });
    } else if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
      setState(() {
        _selectedIndex = 3;
      });
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  void _openReportIssueWithCategory(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIssuePage(prefilledCategory: category),
      ),
    );
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    const mainBlue = Color(0xFF1746D1);
    const navBg = Color(0xFFF0F4FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with floating button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: mainBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      width * 0.04,
                      width * 0.05,
                      width * 0.04,
                      height * 0.04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.account_balance,
                                    color: mainBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Smart Civic Portal",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.012),
                        Text(
                          "Good morning,",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: width * 0.032,
                          ),
                        ),
                        Text(
                          widget.fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                      ],
                    ),
                  ),
                  // Floating "Report an Issue" button (white with border, slightly smaller)
                  Positioned(
                    left: width * 0.12,
                    right: width * 0.12,
                    bottom: -height * 0.035,
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: mainBlue,
                            side: BorderSide(color: mainBlue, width: 1.5),
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.014,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportIssuePage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add, size: width * 0.052),
                          label: Text(
                            "Report an Issue",
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.bold,
                              color: mainBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.065),

              // Quick Report (card size same, icons/images bigger)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Report",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: height * 0.012,
                      crossAxisSpacing: width * 0.04,
                      childAspectRatio: 1.35,
                      children: [
                        GestureDetector(
                          onTap: () => _openReportIssueWithCategory("Garbage"),
                          child: _quickReportCard(
                            Icons.delete,
                            "Garbage",
                            const Color(0xFFEAF8ED),
                            Colors.green,
                            width,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openReportIssueWithCategory("Street Light"),
                          child: _quickReportCard(
                            Icons.lightbulb_outline,
                            "Street Light",
                            const Color(0xFFFFF9E5),
                            Colors.orange,
                            width,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openReportIssueWithCategory("Road Damage"),
                          child: _quickReportCard(
                            Icons.traffic,
                            "Road Damage",
                            const Color(0xFFFFEAEA),
                            Colors.red,
                            width,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openReportIssueWithCategory("Water"),
                          child: _quickReportCard(
                            Icons.water_drop,
                            "Water",
                            const Color(0xFFEAF4FF),
                            mainBlue,
                            width,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.018),

              // Badge Card (smaller)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: width * 0.045,
                    horizontal: width * 0.04,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB16CEA), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Badge",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: width * 0.028,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Civic Hero 🧑‍🤝‍🧑",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: height * 0.01,
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        "2 more reports to reach Neighborhood Guardian 🦸‍♂️",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.018),

              // Report Summary
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reports Summary",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyReportsPage(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.07),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _summaryBox("12", "Total", mainBlue, width),
                            _summaryBox("3", "Pending", Colors.orange, width),
                            _summaryBox("9", "Resolved", Colors.green, width),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.018),

              // Recent Reports
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Reports",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    _reportItem(
                      "Broken Street Light",
                      "MG Road, Sector 14 • 2 days ago",
                      "Pending",
                      Colors.orange.shade700,
                      Colors.yellow.shade50,
                      width,
                    ),
                    _reportItem(
                      "Garbage Collection",
                      "Park Avenue, Block A • 5 days ago",
                      "Resolved",
                      Colors.green.shade700,
                      Colors.green.shade50,
                      width,
                    ),
                    _reportItem(
                      "Pothole Repair",
                      "Main Street, Near Mall • 1 week ago",
                      "Resolved",
                      Colors.green.shade700,
                      Colors.green.shade50,
                      width,
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: mainBlue,
          unselectedItemColor: Colors.grey,
          iconSize: width * 0.065,
          selectedFontSize: width * 0.03,
          unselectedFontSize: width * 0.028,
          elevation: 0,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.home, color: mainBlue),
                    )
                  : const Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_circle_outline, color: mainBlue),
                    )
                  : const Icon(Icons.add_circle_outline),
              label: "Report",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.list_alt, color: mainBlue),
                    )
                  : const Icon(Icons.list_alt),
              label: "Complaints",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: mainBlue),
                    )
                  : const Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  // Quick Report Card (card size same, icons/images bigger, with border)
  Widget _quickReportCard(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor,
    double width,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: width * 0.085,
              child: Icon(icon, color: iconColor, size: width * 0.085),
            ),
            SizedBox(height: width * 0.018),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: width * 0.032,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Report Summary Box (bigger, colored numbers)
  Widget _summaryBox(String value, String label, Color color, double width) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: width * 0.008),
        Text(label, style: TextStyle(fontSize: width * 0.028)),
      ],
    );
  }

  // Recent Report Item
  Widget _reportItem(
    String title,
    String subtitle,
    String status,
    Color statusColor,
    Color chipBg,
    double width,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: width * 0.008),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.032,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: width * 0.026)),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.025,
            vertical: width * 0.008,
          ),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: width * 0.026,
            ),
          ),
        ),
      ),
    );
  }
}
