import 'package:CiTY/models/report_model.dart';
import 'package:CiTY/models/user_profile_model.dart';
import 'package:CiTY/pages/report_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';

import 'reports_page.dart';
import 'report_issue_page.dart';
import 'user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;
  bool _isLoading = true;

  // State variables
  int _totalReports = 0;
  int _pendingReports = 0;
  int _resolvedReports = 0;
  List<Report> _recentReports = [];
  String _badgeName = 'Civic Newcomer';
  int _badgePoints = 0;

  // Hive Boxes
  late Box<UserProfile> _userProfileBox;
  late Box<Report> _reportsBox;

  @override
  void initState() {
    super.initState();
    _userProfileBox = Hive.box<UserProfile>('userProfileBox');
    _reportsBox = Hive.box<Report>('reportsBox');
    _migrateReportDatesToISO().then((_) {
      _loadDataFromCache();
      _fetchHomePageData();
    });
  }

  void _loadDataFromCache() {
    // Load user profile from cache
    final userProfile = _userProfileBox.get('currentUser');
    // Load reports from cache
    final reports = _reportsBox.values.toList();

    if (userProfile != null) {
      _badgeName = userProfile.badge;

      _badgePoints = reports.where((r) => r.status == 'Resolved').length;
    }

    if (reports.isNotEmpty) {
      _totalReports = reports.length;
      _resolvedReports = reports.where((r) => r.status == 'Resolved').length;
      _pendingReports = _totalReports - _resolvedReports;

      reports.sort((a, b) {
        DateTime dateA = DateTime.parse(a.date);
        DateTime dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA);
      });
      _recentReports = reports.take(4).toList();
    }

    if (userProfile != null || reports.isNotEmpty) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHomePageData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.phoneNumber == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final userRef = FirebaseDatabase.instance.ref('users/${user.phoneNumber}');
    final complaintsRef = userRef.child('complaints');

    try {
      final List<DataSnapshot> snapshots = await Future.wait([
        userRef.get(),
        complaintsRef.get(),
      ]);

      final userSnapshot = snapshots[0];
      final complaintsSnapshot = snapshots[1];

      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        final civicData = userData['civicProfile'] != null
            ? Map<String, dynamic>.from(userData['civicProfile'])
            : {'badge': 'Civic Newcomer', 'points': 0};

        final userProfile = UserProfile()
          ..fullName = userData['fullName'] ?? 'No Name'
          ..email = userData['email'] ?? 'No Email'
          ..phoneNumber = userData['phoneNumber'] ?? user.phoneNumber!
          ..badge = civicData['badge'] ?? 'Civic Newcomer'
          ..points = civicData['points'] ?? 0;
        await _userProfileBox.put('currentUser', userProfile);
      }

      if (complaintsSnapshot.exists && complaintsSnapshot.value != null) {
        final Map<String, Report> fetchedReportsMap = {};
        final data = complaintsSnapshot.value as Map;

        final globalComplaintsRef = FirebaseDatabase.instance.ref('complaints');

        for (final complaintId in data.keys) {
          final globalSnapshot = await globalComplaintsRef
              .child(complaintId)
              .get();
          if (globalSnapshot.exists && globalSnapshot.value != null) {
            final reportData = Map<String, dynamic>.from(
              globalSnapshot.value as Map,
            );

            final report = Report()
              ..complaintId = complaintId
              ..title =
                  "${reportData['category'] ?? 'N/A'} - ${reportData['subcategory'] ?? 'N/A'}"
              ..date = reportData['dateTime'] != null
                  ? DateTime.parse(reportData['dateTime']).toIso8601String()
                  : 'Unknown Date'
              ..status = reportData['status'] ?? 'Pending'
              ..image = (reportData['photos'] as List?)?.isNotEmpty ?? false
                  ? reportData['photos'][0]
                  : 'https://img.icons8.com/fluency/96/image--v1.png'
              ..location = reportData['location'] ?? 'Unknown Location';
            fetchedReportsMap[complaintId] = report;
          }
        }
        await _reportsBox.clear();
        await _reportsBox.putAll(fetchedReportsMap);
      }

      if (mounted) {
        setState(() {
          _loadDataFromCache();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to refresh data: $e")));
      }
    }
  }

  Future<void> _migrateReportDatesToISO() async {
    final reports = _reportsBox.values.toList();
    bool updated = false;
    for (final report in reports) {
      try {
        DateTime.parse(report.date);
      } catch (_) {
        try {
          final parsed = DateFormat('MMM dd, h:mm a').parse(report.date);
          report.date = parsed.toIso8601String();
          updated = true;
        } catch (_) {}
      }
    }
    if (updated) {
      await _reportsBox.clear();
      for (final report in reports) {
        await _reportsBox.put(report.complaintId, report);
      }
    }
  }

  Map<String, dynamic> _getBadgeProgressDetails() {
    int points = _badgePoints;
    String nextBadgeName;
    int pointsForNextLevel;
    double progress;

    if (points < 5) {
      pointsForNextLevel = 5;
      nextBadgeName = "Civic Supporter";
      progress = points / pointsForNextLevel;
    } else if (points < 15) {
      pointsForNextLevel = 15;
      nextBadgeName = "Civic Hero";
      progress = (points - 5) / (15 - 5);
    } else if (points < 30) {
      pointsForNextLevel = 30;
      nextBadgeName = "Neighborhood Guardian";
      progress = (points - 15) / (30 - 15);
    } else {
      pointsForNextLevel = points;
      nextBadgeName = "Max Level";
      progress = 1.0;
    }

    return {
      "progress": progress.clamp(0.0, 1.0),
      "reportsToNextLevel": (pointsForNextLevel - points).clamp(0, 100),
      "nextBadgeName": nextBadgeName,
    };
  }

  String _getGreeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return loc.good_morning;
    } else if (hour < 17) {
      return loc.good_afternoon;
    } else {
      return loc.good_evening;
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
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

  void _openReportIssueWithCategory(String localizedCategory) {
    final loc = AppLocalizations.of(context)!;
    String englishCategory;

    if (localizedCategory == loc.garbage) {
      englishCategory = 'Garbage';
    } else if (localizedCategory == loc.streetLight) {
      englishCategory = 'Street Light';
    } else if (localizedCategory == loc.roadDamage) {
      englishCategory = 'Road Damage';
    } else if (localizedCategory == loc.water) {
      englishCategory = 'Water';
    } else {
      englishCategory = localizedCategory;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReportIssuePage(prefilledCategory: englishCategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final fullName = Provider.of<UserProvider>(context).fullName;

    const mainBlue = Color(0xFF1746D1);
    const navBg = Color(0xFFF0F4FF);

    final badgeDetails = _getBadgeProgressDetails();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHomePageData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            MediaQuery.of(context).padding.top + 20.h,
                            16.w,
                            32.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        loc.app_title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(24.r),
                                    onTap: () {},
                                    child: Stack(
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
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                _getGreeting(loc),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                fullName,
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
                                  side: BorderSide(
                                    color: mainBlue,
                                    width: 1.5.w,
                                  ),
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
                                      builder: (context) =>
                                          const ReportIssuePage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add, size: 22.sp),
                                label: Text(
                                  loc.reportIssue,
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

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.quickReport,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GridView.count(
                            padding: EdgeInsets.only(top: 12.h),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12.h,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: 1.35,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _openReportIssueWithCategory(loc.garbage),
                                child: _quickReportCard(
                                  Icons.delete,
                                  loc.garbage,
                                  const Color(0xFFEAF8ED),
                                  Colors.green,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openReportIssueWithCategory(
                                  loc.streetLight,
                                ),
                                child: _quickReportCard(
                                  Icons.lightbulb_outline,
                                  loc.streetLight,
                                  const Color(0xFFFFF9E5),
                                  Colors.orange,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openReportIssueWithCategory(
                                  loc.roadDamage,
                                ),
                                child: _quickReportCard(
                                  Icons.traffic,
                                  loc.roadDamage,
                                  const Color(0xFFFFEAEA),
                                  Colors.red,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _openReportIssueWithCategory(loc.water),
                                child: _quickReportCard(
                                  Icons.water_drop,
                                  loc.water,
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
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 16.w,
                        ),
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
                              loc.currentBadge,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _badgeName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            LinearProgressIndicator(
                              value: badgeDetails["progress"],
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                              minHeight: 7.h,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              badgeDetails["reportsToNextLevel"] == 0
                                  ? "You've reached the top level!"
                                  : "${badgeDetails["reportsToNextLevel"]} more reports to become a ${badgeDetails["nextBadgeName"]}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.reportsSummary,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _summaryBox(
                                    _totalReports.toString(),
                                    loc.total,
                                    mainBlue,
                                  ),
                                  _summaryBox(
                                    _pendingReports.toString(),
                                    loc.pending,
                                    Colors.orange,
                                  ),
                                  _summaryBox(
                                    _resolvedReports.toString(),
                                    loc.resolved,
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.recentReports,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          if (_recentReports.isEmpty)
                            Center(child: Text("No recent reports found."))
                          else
                            ..._recentReports.map((report) {
                              final status = report.status;
                              Color statusColor;
                              Color chipBg;

                              switch (status) {
                                case 'Resolved':
                                  statusColor = Colors.green.shade700;
                                  chipBg = Colors.green.shade50;
                                  break;
                                case 'In Progress':
                                  statusColor = Colors.blue.shade700;
                                  chipBg = Colors.blue.shade50;
                                  break;
                                case 'Assigned':
                                  statusColor = Colors.purple.shade700;
                                  chipBg = Colors.purple.shade50;
                                  break;
                                case 'Pending':
                                default:
                                  statusColor = Colors.orange.shade700;
                                  chipBg = Colors.yellow.shade50;
                              }

                              DateTime date;
                              String subtitle;
                              try {
                                date = DateTime.parse(report.date);
                                subtitle = DateFormat.yMMMd().add_jm().format(
                                  date,
                                );
                              } catch (e) {
                                subtitle = report.date;
                              }

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportDetailsPage(
                                        complaintId: report.complaintId,
                                      ),
                                    ),
                                  );
                                },
                                child: _reportItem(
                                  report.title,
                                  subtitle,
                                  status,
                                  statusColor,
                                  chipBg,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
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
              label: loc.home,
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
              label: loc.report,
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
              label: loc.complaints,
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
              label: loc.profile,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _reportItem(
    String title,
    String subtitle,
    String status,
    Color statusColor,
    Color chipBg,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),

        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: _getCategoryBgColor(title),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(title),
              size: 26.sp,
              color: _getCategoryIconColor(title),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _getStatusLabel(status, loc),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status, AppLocalizations loc) {
    switch (status) {
      case "Pending":
        return loc.pending;
      case "Assigned":
        return loc.assigned;
      case "In Progress":
        return loc.inProgress;
      case "Resolved":
        return loc.resolved;
      default:
        return status;
    }
  }

  IconData _getCategoryIcon(String title) {
    final mainCategory = title.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return Icons.delete;
      case "Street Light":
        return Icons.lightbulb_outline;
      case "Road Damage":
        return Icons.traffic;
      case "Water":
        return Icons.water_drop;
      case "Drainage & Sewerage":
        return Icons
            .water_damage_outlined; // Use the same icon as report_details_page.dart
      default:
        return Icons.report_problem;
    }
  }

  Color _getCategoryBgColor(String title) {
    final mainCategory = title.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return const Color(0xFFEAF8ED); // Light green
      case "Street Light":
        return const Color(0xFFFFF9E5); // Light yellow
      case "Road Damage":
        return const Color(0xFFFFEAEA); // Light red
      case "Water":
        return const Color(0xFFEAF4FF); // Light blue
      case "Drainage & Sewerage":
        return const Color(0xFFEAF4FF); // Same as Water (light blue)
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryIconColor(String title) {
    final mainCategory = title.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return Colors.green;
      case "Street Light":
        return Colors.orange;
      case "Road Damage":
        return Colors.red;
      case "Water":
        return const Color(0xFF1746D1); // Main blue
      case "Drainage & Sewerage":
        return const Color(
          0xFF1746D1,
        ); // Main blue, same as Report Details Page
      default:
        return Colors.grey;
    }
  }
}
