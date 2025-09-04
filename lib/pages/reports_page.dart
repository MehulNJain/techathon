import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final List<Map<String, dynamic>> reports = [
    {
      "title": "Garbage - Overflowing Dustbin",
      "location": "MG Road, Sector 14",
      "date": "Aug 31, 2:45 PM",
      "status": "Pending",
      "image": "https://img.icons8.com/fluency/96/trash.png",
    },
    {
      "title": "Street Light - Not Working",
      "location": "Park Street, Block A",
      "date": "Aug 30, 11:20 AM",
      "status": "In Progress",
      "image": "assets/images/streetlight.png",
    },
    {
      "title": "Road Damage - Pothole",
      "location": "Main Road, Near Mall",
      "date": "Aug 29, 4:15 PM",
      "status": "Resolved",
      "image": "https://img.icons8.com/fluency/96/road-worker.png",
    },
    {
      "title": "Water Supply - Pipe Leakage",
      "location": "Residential Area, B-12",
      "date": "Aug 28, 9:30 AM",
      "status": "In Progress",
      "image": "https://img.icons8.com/fluency/96/water.png",
    },
    {
      "title": "Garbage - Illegal Dumping",
      "location": "Market Road, Near Bus Stand",
      "date": "Aug 27, 6:45 PM",
      "status": "Resolved",
      "image": "https://img.icons8.com/fluency/96/trash.png",
    },
  ];

  String selectedTab = "All";

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final filteredReports = selectedTab == "All"
        ? reports
        : reports.where((r) => r["status"] == selectedTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myReports, style: TextStyle(fontSize: 18.sp)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Row
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    title: loc.total,
                    value: "12",
                    color: Colors.black,
                  ),
                  _SummaryItem(
                    title: loc.pending,
                    value: "3",
                    color: Colors.orange,
                  ),
                  _SummaryItem(
                    title: loc.inProgress,
                    value: "4",
                    color: Colors.blue,
                  ),
                  _SummaryItem(
                    title: loc.resolved,
                    value: "5",
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var tab in ["All", "Pending", "In Progress", "Resolved"])
                    GestureDetector(
                      onTap: () => setState(() => selectedTab = tab),
                      child: _TabButton(
                        label: tab == "All"
                            ? loc.all
                            : tab == "Pending"
                            ? loc.pending
                            : tab == "In Progress"
                            ? loc.inProgress
                            : loc.resolved,
                        selected: (tab == selectedTab),
                      ),
                    ),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 16.h),
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  final imageWidget =
                      report["image"].toString().startsWith("http")
                      ? Image.network(
                          report["image"],
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 40.sp,
                            color: Colors.grey,
                          ),
                        )
                      : Image.asset(
                          report["image"],
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                        );

                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: imageWidget,
                      ),
                      title: Text(
                        report["title"],
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report["location"],
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          Text(
                            report["date"],
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            report["status"],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          report["status"] == "Pending"
                              ? loc.pending
                              : report["status"] == "In Progress"
                              ? loc.inProgress
                              : loc.resolved,
                          style: TextStyle(
                            color: _getStatusColor(report["status"]),
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

            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                loc.footerNote,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
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
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 14.sp)),
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
        color: selected ? Colors.blue : Colors.grey[200],
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
