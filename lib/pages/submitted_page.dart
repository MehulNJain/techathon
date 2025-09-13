import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'report_details_page.dart';
import 'home_page.dart';
import 'report_issue_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart'; // Add this import

class SubmittedPage extends StatefulWidget {
  final String complaintId;
  const SubmittedPage({super.key, required this.complaintId});

  static const mainBlue = Color(0xFF1746D1);
  static const bgGrey = Color(0xFFF6F6F6); // Same as HomePage

  @override
  State<SubmittedPage> createState() => _SubmittedPageState();
}

class _SubmittedPageState extends State<SubmittedPage> {
  Map<String, dynamic>? complaintData;
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
        complaintData = data;
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
    // Get localizations
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        backgroundColor: SubmittedPage.bgGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (complaintData == null) {
      return Scaffold(
        backgroundColor: SubmittedPage.bgGrey,
        body: Center(child: Text(l10n.complaintNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: SubmittedPage.bgGrey,
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
        title: null, // Remove the title from the AppBar
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),
              // Add "Complaint Submitted" back here
              Text(
                l10n.submitted, // "Complaint Submitted" -> localized
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
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
                  size: 46.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                l10n.success, // "Success!" -> localized
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.reportSubmittedByCitizen, // "Your complaint has been submitted successfully!" -> localized
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),
              // Keep Complaint Summary box intact
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
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
                      "Complaint Summary", // Keeping this as is per requirement
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _summaryRow("Category", complaintData!['category'] ?? ''),
                    _summaryRow(
                      "Issue Type",
                      complaintData!['subcategory'] ?? '',
                    ),
                    _summaryRow(
                      "Date Submitted",
                      "$formattedDate, $formattedTime",
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Status",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.sp,
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
                              fontSize: 12.sp,
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
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        Text(
                          "#${complaintData!['complaintId'] ?? ''}",
                          style: TextStyle(
                            color: SubmittedPage.mainBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
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
                    l10n.viewDetails, // "Track Complaint" -> localized
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
                        builder: (_) => ReportDetailsPage(
                          complaintId: complaintData!['complaintId'],
                        ),
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
                    l10n.reportIssuee, // "Report Another Issue" -> localized
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
                        l10n.assignedToMunicipalworker, // Info text -> localized
                        style: TextStyle(
                          color: SubmittedPage.mainBlue,
                          fontSize: 12.sp,
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
              style: TextStyle(color: Colors.black54, fontSize: 13.sp),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
