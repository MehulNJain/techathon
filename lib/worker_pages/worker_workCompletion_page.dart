import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'worker_home_page.dart';
import 'package:permission_handler/permission_handler.dart';

class WorkerWorkCompletionSuccessPage extends StatelessWidget {
  final String complaintId;
  final String supervisorId;
  final String citizenId;

  const WorkerWorkCompletionSuccessPage({
    Key? key,
    required this.complaintId,
    required this.supervisorId,
    required this.citizenId,
  }) : super(key: key);

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
      if (downloadsDir == null)
        throw Exception("Downloads directory not found");

      final filePath =
          '${downloadsDir.path}/work_completion_report_${complaintId}.pdf';
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
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Work Completion",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text(
                "Work Marked as Completed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your completion proof has been sent to the complaint owner and supervisor.",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    "Share Status",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Share status pressed")),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    "Download Report",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _downloadReport(context),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => WorkerHomePage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
