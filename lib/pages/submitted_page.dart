import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/report_data.dart';
import 'report_details_page.dart';
import 'home_page.dart';
import 'report_issue_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SubmittedPage extends StatefulWidget {
  final String complaintId;
  const SubmittedPage({super.key, required this.complaintId});

  static const mainBlue = Color(0xFF1746D1);

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  ReportData? report;
  bool _loading = true;
  String formattedDate = '';
  String formattedTime = '';

  @override
  void initState() {
    super.initState();
    _fetchComplaint();
  }

  Future<void> _fetchComplaint() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef
        .child('complaints')
        .child(widget.complaintId)
        .get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      DateTime? dt = DateTime.tryParse(data['dateTime'] ?? '');
      if (dt != null) {
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
        formattedTime = DateFormat('hh:mm a').format(dt);
      }
      setState(() {
        report = ReportData(
          category: data['category'] ?? '',
          subcategory: data['subcategory'] ?? '',
          description: data['description'] ?? '',
          photos: (data['photos'] as List<dynamic>? ?? [])
              .map(
                (url) =>
                    ReportPhoto(path: url, timestamp: dt ?? DateTime.now()),
              )
              .toList(),
          location: data['location'] ?? '',
          dateTime: data['dateTime'] ?? '',
          complaintId: data['complaintId'] ?? '',
          voiceNotePath: data['voiceNote'],
        );
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (report == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Complaint not found.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: SubmittedPage.mainBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),
              Text(
                "Complaint Submitted",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD1FADF),
                ),
                padding: EdgeInsets.all(24.w),
                child: Icon(
                  Icons.check,
                  color: const Color(0xFF12B76A),
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                "Success!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Your complaint has been submitted\nsuccessfully!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 15.sp),
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(14.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.04),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Complaint Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _summaryRow("Category", report!.category),
                    _summaryRow("Issue Type", report!.subcategory),
                    _summaryRow("Date Submitted", formattedDate),
                    _summaryRow("Time Submitted", formattedTime),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Status",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E0),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "Pending Review",
                            style: TextStyle(
                              color: const Color(0xFFB26A00),
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Complaint ID",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        Text(
                          "#${report!.complaintId}",
                          style: TextStyle(
                            color: SubmittedPage.mainBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.search, color: Colors.white, size: 20.sp),
                  label: Text(
                    "Track Complaint",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SubmittedPage.mainBlue,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsPage(report: report!),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: SubmittedPage.mainBlue,
                    size: 20.sp,
                  ),
                  label: Text(
                    "Report Another Issue",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: SubmittedPage.mainBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: SubmittedPage.mainBlue,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => ReportIssuePage()),
                      (route) => false,
                    );
                  },
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: SubmittedPage.mainBlue,
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "Your complaint will be reviewed by our team within 24 hours and assigned to the relevant department for resolution.",
                        style: TextStyle(
                          color: SubmittedPage.mainBlue,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black54, fontSize: 15.sp),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
