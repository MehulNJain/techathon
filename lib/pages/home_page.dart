import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportIssuePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyReportsPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    }
  }

  void _openReportIssueWithCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIssuePage(prefilledCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF1746D1);
    const navBg = Color(0xFFF0F4FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      extendBodyBehindAppBar:
          true, // Allow content to extend behind the status bar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with floating button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    MediaQuery.of(context).padding.top +
                        20.h, // Add top padding to clear status bar
                    16.w,
                    32.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18.r,
                                child: Icon(
                                  Icons.account_balance,
                                  color: mainBlue,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Smart Civic Portal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                              Positioned(
                                right: 0,
                                top: 2.h,
                                child: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Good morning,",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        widget.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                // Floating "Report an Issue" button
                Positioned(
                  left: 48.w,
                  right: 48.w,
                  bottom: -28.h,
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: mainBlue,
                          side: BorderSide(color: mainBlue, width: 1.5.w),
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
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
                        icon: Icon(Icons.add, size: 22.sp),
                        label: Text(
                          "Report an Issue",
                          style: TextStyle(
                            fontSize: 15.sp,
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
            SizedBox(height: 40.h),

            // Quick Report
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Report",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 1.35,
                    children: [
                      GestureDetector(
                        onTap: () => _openReportIssueWithCategory("Garbage"),
                        child: _quickReportCard(
                          Icons.delete,
                          "Garbage",
                          const Color(0xFFEAF8ED),
                          Colors.green,
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
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openReportIssueWithCategory("Water"),
                        child: _quickReportCard(
                          Icons.water_drop,
                          "Water",
                          const Color(0xFFEAF4FF),
                          mainBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Badge Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB16CEA), Color(0xFF4A90E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Badge",
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Civic Hero 🧑‍🤝‍🧑",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 7.h,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "2 more reports to reach Neighborhood Guardian 🦸‍♂️",
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Report Summary
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reports Summary",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
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
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.07),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _summaryBox("12", "Total", mainBlue),
                          _summaryBox("3", "Pending", Colors.orange),
                          _summaryBox("9", "Resolved", Colors.green),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Recent Reports
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Reports",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _reportItem(
                    "Broken Street Light",
                    "MG Road, Sector 14 • 2 days ago",
                    "Pending",
                    Colors.orange.shade700,
                    Colors.yellow.shade50,
                  ),
                  _reportItem(
                    "Garbage Collection",
                    "Park Avenue, Block A • 5 days ago",
                    "Resolved",
                    Colors.green.shade700,
                    Colors.green.shade50,
                  ),
                  _reportItem(
                    "Pothole Repair",
                    "Main Street, Near Mall • 1 week ago",
                    "Resolved",
                    Colors.green.shade700,
                    Colors.green.shade50,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: Offset(0, -2.h),
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
          iconSize: 24.sp,
          selectedFontSize: 14.sp,
          unselectedFontSize: 13.sp,
          elevation: 0,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.home, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.home, size: 24.sp),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: mainBlue,
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.add_circle_outline, size: 24.sp),
              label: "Report",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.list_alt, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.list_alt, size: 24.sp),
              label: "Complaints",
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: mainBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.person, color: mainBlue, size: 24.sp),
                    )
                  : Icon(Icons.person, size: 24.sp),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  // Quick Report Card
  Widget _quickReportCard(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.2.w),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 32.r,
              child: Icon(icon, color: iconColor, size: 32.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  // Report Summary Box
  Widget _summaryBox(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 13.sp)),
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
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}
