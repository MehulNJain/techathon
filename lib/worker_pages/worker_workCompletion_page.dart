import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'worker_home_page.dart';
import 'worker_main_page.dart'; // Add this import
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class WorkerWorkCompletionSuccessPage extends StatelessWidget {
  final String complaintId;
  final String supervisorId;
  final String citizenId;

  const WorkerWorkCompletionSuccessPage({
    super.key,
    required this.complaintId,
    required this.supervisorId,
    required this.citizenId,
  });

  Future<void> _downloadReport(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }
        // For Android 11+ (API 30+), use manageExternalStorage
        if (await Permission.manageExternalStorage.isDenied) {
          var manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
            return;
          }
        }
        if (!await Permission.storage.isGranted &&
            !await Permission.manageExternalStorage.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Work Completion Report',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Complaint ID: $complaintId'),
              pw.Text('Supervisor ID: $supervisorId'),
              pw.Text('Citizen ID: $citizenId'),
              pw.Text('Status: Completed'),
              pw.Text('Date: ${DateTime.now()}'),
            ],
          ),
        ),
      );

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      if (downloadsDir == null) {
        throw Exception("Downloads directory not found");
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath =
          '${downloadsDir.path}/work_completion_report_${complaintId}_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Downloaded')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700, // Main orange
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null, // No title
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 24.h),
              Text(
                "Work Marked as Completed!",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                "Your completion proof has been sent to the complaint owner and supervisor.",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.share, color: Colors.white, size: 24.sp),
                  label: Text(
                    "Share Status",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Share status pressed")),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.download, color: Colors.white, size: 24.sp),
                  label: Text(
                    "Download Report",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () => _downloadReport(context),
                ),
              ),
              SizedBox(height: 32.h),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WorkerMainPage()),
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 15.sp, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
