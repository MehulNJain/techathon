import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../locale_provider.dart';
import '../main.dart';
import '../login_page.dart';

// ---------------- UserProfilePage ----------------
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    const mainBlue = Color(0xFF1746D1);

    // Access the LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(loc.profile, style: TextStyle(fontSize: 18.sp)),
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
            _profileCard(mainBlue),
            SizedBox(height: 18.h),
            _badgeCard(loc),
            SizedBox(height: 18.h),
            _reportsSummary(loc, mainBlue),
            SizedBox(height: 18.h),
            _settingsCard(loc, mainBlue, localeProvider),
            SizedBox(height: 18.h),
            _supportCard(loc),
            SizedBox(height: 18.h),
            _logoutButton(loc),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                loc.footerNote,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _profileCard(Color mainBlue) {
    return Container(
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
            backgroundImage: const NetworkImage(
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
                    Text("+91 98765 43210", style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Icon(Icons.verified, color: Colors.green, size: 16.sp),
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
    );
  }

  Widget _badgeCard(AppLocalizations loc) {
    return Container(
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
              Icon(Icons.emoji_events, color: Colors.white, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                loc.civicHero,
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
                    loc.report,
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            loc.currentBadge,
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
    );
  }

  Widget _reportsSummary(AppLocalizations loc, Color mainBlue) {
    return Container(
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
            loc.reportsSummary,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryIconBox(
                Icons.assignment,
                "12",
                loc.total,
                Colors.blue.shade100,
                mainBlue,
              ),
              _summaryIconBox(
                Icons.check_circle,
                "8",
                loc.resolved,
                Colors.green.shade100,
                Colors.green,
              ),
              _summaryIconBox(
                Icons.access_time,
                "4",
                loc.pending,
                Colors.yellow.shade100,
                Colors.orange,
              ),
            ],
          ),
        ],
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

  Widget _settingsCard(
    AppLocalizations loc,
    Color mainBlue,
    dynamic localeProvider,
  ) {
    return Container(
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
            loc.settings,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          ListTile(
            leading: Icon(Icons.notifications, size: 22.sp),
            title: Text(loc.notifications, style: TextStyle(fontSize: 15.sp)),
            trailing: Switch(
              value: notificationsEnabled,
              activeThumbColor: mainBlue,
              onChanged: (val) => setState(() => notificationsEnabled = val),
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, size: 22.sp),
            title: Text(loc.select_language, style: TextStyle(fontSize: 15.sp)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localeProvider.locale.languageCode == 'en'
                      ? loc.english
                      : loc.hindi,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18.sp),
              ],
            ),
            onTap: () => _showLanguageDialog(localeProvider),
          ),
        ],
      ),
    );
  }

  Widget _supportCard(AppLocalizations loc) {
    return Container(
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
            loc.support,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, size: 22.sp),
            title: Text(loc.faq, style: TextStyle(fontSize: 15.sp)),
            trailing: Icon(Icons.chevron_right, size: 18.sp),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.headset_mic_outlined, size: 22.sp),
            title: Text(loc.contactSupport, style: TextStyle(fontSize: 15.sp)),
            trailing: Icon(Icons.chevron_right, size: 18.sp),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.logout, color: Colors.white, size: 20.sp),
        label: Text(
          loc.logout,
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
      ),
    );
  }

  void _showLanguageDialog(dynamic localeProvider) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.select_language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.english),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(loc.hindi),
              onTap: () {
                localeProvider.setLocale(const Locale('hi'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
