import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../login_page.dart';
import '../l10n/app_localizations.dart';
import '../locale_provider.dart';

class WorkerProfilePage extends StatelessWidget {
  const WorkerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.orange.shade700,
                          child: Icon(
                            Icons.person,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Rajesh Kumar", // Dummy Data
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${l10n.workerId}: MW-2024-0156", // Dummy Data
                      style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    _infoTile(
                      Icons.phone,
                      l10n.phoneNumber,
                      "+91 98765 43210", // Dummy Data
                    ),
                    SizedBox(height: 10.h),
                    _infoTile(
                      Icons.engineering,
                      l10n.department,
                      "Road Maintenance", // Dummy Data
                    ),
                    SizedBox(height: 10.h),
                    _infoTile(
                      Icons.location_on,
                      l10n.assignedArea,
                      "Zone 3 - Central District", // Dummy Data
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Recognition & Progress
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.orange.shade700,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.recognitionProgress,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.tasksCompleted,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "15", // Dummy Data
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.list_alt,
                            color: Colors.green,
                            size: 32.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.earnedBadges,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _badge(
                          icon: Icons.star,
                          color: Colors.orange.shade700,
                          text: l10n.quickResponse,
                        ),
                        _badge(
                          icon: Icons.verified,
                          color: Colors.green,
                          text: l10n.qualityWork,
                        ),
                        _badge(
                          icon: Icons.access_time,
                          color: Colors.blue,
                          text: l10n.onTime,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Action Tiles
            _actionTile(Icons.lock, l10n.changePassword, Colors.blue, () {}),
            SizedBox(height: 12.h),
            _actionTile(Icons.language, l10n.changeLanguage, Colors.teal, () {
              _showLanguageDialog(context);
            }),
            SizedBox(height: 12.h),
            _actionTile(Icons.logout, l10n.logout, Colors.red, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Helper function for the language change dialog
void _showLanguageDialog(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('हिन्दी'),
              onTap: () {
                localeProvider.setLocale(const Locale('hi'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('ᱥᱟᱱᱛᱟᱲᱤ'),
              onTap: () {
                localeProvider.setLocale(const Locale('sat'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

// Helper widget for info tiles
Widget _infoTile(IconData icon, String title, String subtitle) {
  return Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 24.sp),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    ),
  );
}

// Helper widget for badges
Widget _badge({
  required IconData icon,
  required Color color,
  required String text,
}) {
  return Column(
    children: [
      CircleAvatar(
        radius: 20.r,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      SizedBox(height: 6.h),
      Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// Helper widget for action tiles
Widget _actionTile(
  IconData icon,
  String text,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.black45),
        ],
      ),
    ),
  );
}
