import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_page.dart';
import 'reports_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF1746D1);
    const navBg = Color(0xFFF0F4FF);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text("My Profile", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/women/44.jpg",
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Priya Sharma",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.edit, color: mainBlue, size: 18.sp),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16.sp, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              "+91 98765 43210",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 16.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(Icons.email, size: 16.sp, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              "priya.sharma@email.com",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Badge Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
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
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Civic Hero",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "12",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                          Text(
                            "Reports",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Current Badge",
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        "Progress to Neighborhood Guardian 🦸‍♂️",
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                      const Spacer(),
                      Text(
                        "12/15",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  LinearProgressIndicator(
                    value: 12 / 15,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 7.h,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "2 more reports to reach next level!",
                    style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Reports Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reports Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _summaryIconBox(
                        Icons.assignment,
                        "12",
                        "Total",
                        Colors.blue.shade100,
                        mainBlue,
                      ),
                      _summaryIconBox(
                        Icons.check_circle,
                        "8",
                        "Resolved",
                        Colors.green.shade100,
                        Colors.green,
                      ),
                      _summaryIconBox(
                        Icons.access_time,
                        "4",
                        "Pending",
                        Colors.yellow.shade100,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Settings
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications, size: 22.sp),
                    title: Text(
                      "Notifications",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeColor: mainBlue,
                      onChanged: (val) {
                        setState(() => notificationsEnabled = val);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.language, size: 22.sp),
                    title: Text("Language", style: TextStyle(fontSize: 15.sp)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "English",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18.sp),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, size: 22.sp),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    trailing: Icon(Icons.chevron_right, size: 18.sp),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.description_outlined, size: 22.sp),
                    title: Text(
                      "Terms of Use",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    trailing: Icon(Icons.chevron_right, size: 18.sp),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Support
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Support",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, size: 22.sp),
                    title: Text("FAQ", style: TextStyle(fontSize: 15.sp)),
                    trailing: Icon(Icons.chevron_right, size: 18.sp),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.headset_mic_outlined, size: 22.sp),
                    title: Text(
                      "Contact Support",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    trailing: Icon(Icons.chevron_right, size: 18.sp),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: Colors.white, size: 20.sp),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: Implement logout logic
                },
              ),
            ),
            SizedBox(height: 10.h),

            // Footer
            Center(
              child: Text(
                "Government of India Initiative – Secure & Verified",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _summaryIconBox(
    IconData icon,
    String value,
    String label,
    Color bg,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 26.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: iconColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 13.sp)),
      ],
    );
  }
}
