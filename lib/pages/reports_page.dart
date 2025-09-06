import 'package:CiTY/models/report_model.dart';
import 'package:CiTY/pages/report_details_page.dart';
import 'package:CiTY/pages/submitted_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'home_page.dart';
import 'report_issue_page.dart';
import 'user_profile_page.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late Box<Report> _reportsBox;
  bool _isLoading = true;
  String selectedTab = "All";

  @override
  void initState() {
    super.initState();
    _reportsBox = Hive.box<Report>('reportsBox');
    _loadReports();
  }

  Future<void> _loadReports() async {
    // Show cached data immediately, if available
    if (_reportsBox.isNotEmpty) {
      if (mounted) setState(() => _isLoading = false);
    }
    // Fetch fresh data from network
    await _fetchUserReportsFromFirebase();
  }

  Future<void> _fetchUserReportsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.phoneNumber == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref(
      'users/${user.phoneNumber}/complaints',
    );

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<String, Report> fetchedReportsMap = {};
        final data = snapshot.value as Map;

        data.forEach((key, value) {
          final reportData = Map<String, dynamic>.from(value);
          String effectiveStatus;
          if (reportData['assignedTo'] != null) {
            effectiveStatus = "Assigned";
          } else {
            effectiveStatus = reportData['status'] ?? 'Pending';
          }

          final report = Report()
            ..complaintId = key
            ..title =
                "${reportData['category'] ?? 'N/A'} - ${reportData['subcategory'] ?? 'N/A'}"
            ..date = reportData['dateTime'] != null
                ? DateFormat(
                    'MMM dd, h:mm a',
                  ).format(DateTime.parse(reportData['dateTime']))
                : 'Unknown Date'
            ..status = effectiveStatus
            ..image = (reportData['photos'] as List?)?.isNotEmpty ?? false
                ? reportData['photos'][0]
                : 'https://img.icons8.com/fluency/96/image--v1.png'
            ..location =
                reportData['location'] ?? 'Unknown Location'; // Add this line
          fetchedReportsMap[key] = report;
        });

        // Update local cache and UI
        await _reportsBox.clear();
        await _reportsBox.putAll(fetchedReportsMap);
      } else {
        // If no reports on Firebase, clear local cache
        await _reportsBox.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to refresh reports: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Assigned":
        return Colors.purple;
      case "In Progress":
        return Colors.blue;
      case "Resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
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

  // Add this method to get the icon based on category
  IconData getCategoryIcon(String category) {
    // Extract the main category from the title (e.g. "Garbage - Overflow" -> "Garbage")
    final mainCategory = category.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return Icons.delete;
      case "Street Light":
        return Icons.lightbulb_outline;
      case "Road Damage":
        return Icons.traffic;
      case "Water":
        return Icons.water_drop;
      default:
        return Icons.report_problem;
    }
  }

  // Add this method to get the background color for the category icon
  Color getCategoryBgColor(String category) {
    final mainCategory = category.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return const Color(0xFFEAF8ED); // Light green
      case "Street Light":
        return const Color(0xFFFFF9E5); // Light yellow
      case "Road Damage":
        return const Color(0xFFFFEAEA); // Light red
      case "Water":
        return const Color(0xFFEAF4FF); // Light blue
      default:
        return Colors.grey.shade100;
    }
  }

  // Add this method to get the icon color for the category
  Color getCategoryIconColor(String category) {
    final mainCategory = category.split(' - ').first;

    switch (mainCategory) {
      case "Garbage":
        return Colors.green;
      case "Street Light":
        return Colors.orange;
      case "Road Damage":
        return Colors.red;
      case "Water":
        return const Color(0xFF1746D1); // Main blue
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.myReports,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: SubmittedPage.mainBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: ValueListenableBuilder<Box<Report>>(
        valueListenable: _reportsBox.listenable(),
        builder: (context, box, _) {
          var reports = box.values.toList().cast<Report>();

          // Sort reports by date descending
          reports.sort((a, b) {
            DateTime dateA = DateFormat('MMM dd, h:mm a').parse(a.date);
            DateTime dateB = DateFormat('MMM dd, h:mm a').parse(b.date);
            return dateB.compareTo(dateA);
          });

          final filteredReports = selectedTab == "All"
              ? reports
              : reports.where((r) => r.status == selectedTab).toList();

          final totalCount = reports.length;
          final pendingCount = reports
              .where((r) => r.status == 'Pending')
              .length;
          final inProgressCount = reports
              .where((r) => r.status == 'In Progress')
              .length;
          final resolvedCount = reports
              .where((r) => r.status == 'Resolved')
              .length;
          final assignedCount = reports
              .where((r) => r.status == 'Assigned')
              .length;

          return SafeArea(
            child: Column(
              children: [
                // COMBINED CARD: Total, Pending, In Progress, Resolved
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SummaryItem(
                            title: loc.total,
                            value: totalCount.toString(),
                            color: Colors.black,
                          ),
                          _SummaryItem(
                            title: loc.pending,
                            value: pendingCount.toString(),
                            color: Colors.orange,
                          ),
                          _SummaryItem(
                            title: loc.inProgress,
                            value: inProgressCount.toString(),
                            color: Colors.blue,
                          ),
                          _SummaryItem(
                            title: loc.resolved,
                            value: resolvedCount.toString(),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // FILTER TABS - Keep as is with Assigned included
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var tab in [
                          "All",
                          "Pending",
                          "Assigned",
                          "In Progress",
                          "Resolved",
                        ])
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTab = tab),
                              child: _TabButton(
                                label: tab == "All"
                                    ? loc.all
                                    : _getStatusLabel(tab, loc),
                                selected: (tab == selectedTab),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading && reports.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredReports.isEmpty
                      ? Center(
                          child: Text(
                            selectedTab == "All"
                                ? "You have not submitted any reports."
                                : "No reports found in this category.",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchUserReportsFromFirebase,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];

                              // Category icon instead of image
                              final categoryIcon = Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: getCategoryBgColor(report.title),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: Icon(
                                    getCategoryIcon(report.title),
                                    size: 26.sp,
                                    color: getCategoryIconColor(report.title),
                                  ),
                                ),
                              );

                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ListTile(
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
                                  leading: categoryIcon, // Use category icon
                                  title: Text(
                                    report.title,
                                    style: TextStyle(fontSize: 15.sp),
                                  ),
                                  subtitle: Text(
                                    report.date,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        report.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      _getStatusLabel(report.status, loc),
                                      style: TextStyle(
                                        color: _getStatusColor(report.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFF0F4FF),
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssuePage(),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1746D1),
          unselectedItemColor: Colors.grey,
          iconSize: 24.sp,
          selectedFontSize: 14.sp,
          unselectedFontSize: 13.sp,
          elevation: 0,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: 2 == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1746D1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.home,
                        color: const Color(0xFF1746D1),
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.home, size: 24.sp),
              label: loc.home,
            ),
            BottomNavigationBarItem(
              icon: 2 == 1
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1746D1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: const Color(0xFF1746D1),
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.add_circle_outline, size: 24.sp),
              label: loc.report,
            ),
            BottomNavigationBarItem(
              icon: 2 == 2
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1746D1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.list_alt,
                        color: const Color(0xFF1746D1),
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.list_alt, size: 24.sp),
              label: loc.complaints,
            ),
            BottomNavigationBarItem(
              icon: 2 == 3
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1746D1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF1746D1),
                        size: 24.sp,
                      ),
                    )
                  : Icon(Icons.person, size: 24.sp),
              label: loc.profile,
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Box
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}

// Tab Button
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabButton({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected ? SubmittedPage.mainBlue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
