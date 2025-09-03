import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/report_data.dart';
import 'home_page.dart';
import 'reports_page.dart';
import 'user_profile_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Icon selection based on complaint category
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Garbage':
      return Icons.delete;
    case 'Street Light':
      return Icons.lightbulb_outline;
    case 'Road Damage':
      return Icons.construction;
    case 'Water':
      return Icons.water_drop;
    case 'Drainage & Sewerage':
      return Icons.water_damage_outlined;
    default:
      return Icons.report_problem;
  }
}

// Voice note player widget
class VoiceNotePlayer extends StatefulWidget {
  final String path;
  const VoiceNotePlayer({super.key, required this.path});

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.path));
      setState(() => _isPlaying = true);
      _player.onPlayerComplete.listen((_) {
        setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.blue,
        size: 22.sp,
      ),
      label: Text(
        _isPlaying ? "Pause Voice Note" : "Play Voice Note",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.08),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onPressed: _togglePlay,
    );
  }
}

class ReportDetailsPage extends StatelessWidget {
  final ReportData report;
  const ReportDetailsPage({super.key, required this.report});

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MyReportsPage()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Report Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Card
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: mainBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.all(8.w),
                              child: Icon(
                                getCategoryIcon(report.category),
                                color: mainBlue,
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${report.category} - ${report.subcategory}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    report.dateTime,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: mainBlue,
                              size: 18.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                report.location,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.tag, color: Colors.grey, size: 18.sp),
                            SizedBox(width: 4.w),
                            Text(
                              "REF: ${report.complaintId}",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13.sp,
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(
                                "Pending Review",
                                style: TextStyle(
                                  color: Color(0xFFB26A00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              backgroundColor: Color(0xFFFFF6E0),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 0.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Photos Submitted
                  if (report.photos.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Photos Submitted",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 90.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: report.photos.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 10.w),
                              itemBuilder: (context, i) {
                                final photo = report.photos[i];
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.black,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.file(File(photo.path)),
                                            Padding(
                                              padding: EdgeInsets.all(8.w),
                                              child: Text(
                                                DateFormat(
                                                  'dd MMM yyyy, hh:mm a',
                                                ).format(photo.timestamp),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                "Close",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        child: Image.file(
                                          File(photo.path),
                                          width: 70.w,
                                          height: 70.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 2.h,
                                        left: 2.w,
                                        child: Container(
                                          color: Colors.black54,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                            vertical: 2.h,
                                          ),
                                          child: Text(
                                            DateFormat(
                                              'dd MMM, hh:mm a',
                                            ).format(photo.timestamp),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Issue Description & Voice Note
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Issue Description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          report.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                        if (report.voiceNotePath != null) ...[
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              VoiceNotePlayer(path: report.voiceNotePath!),
                              SizedBox(width: 10.w),
                              Text(
                                "Voice Note",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Timeline (dummy, you can add real status if you want)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status Timeline",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _timelineTile(
                          icon: Icons.radio_button_unchecked,
                          color: Colors.grey,
                          title: "Submitted",
                          date: report.dateTime,
                          desc: "Report submitted by citizen",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar (same as before)
          Container(
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
              currentIndex: 2,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: mainBlue,
              unselectedItemColor: Colors.grey,
              iconSize: width * 0.065.w,
              selectedFontSize: width * 0.03.sp,
              unselectedFontSize: width * 0.028.sp,
              elevation: 0,
              showUnselectedLabels: true,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomePage(fullName: ""),
                    ),
                    (route) => false,
                  );
                } else if (index == 1) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomePage(fullName: "")),
                    (route) => false,
                  );
                } else if (index == 2) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => MyReportsPage()),
                    (route) => false,
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => UserProfilePage()),
                    (route) => false,
                  );
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 0 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.home, color: Colors.grey, size: 24.sp),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 1 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
                  ),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: mainBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.list_alt, color: mainBlue, size: 24.sp),
                  ),
                  label: "Complaints",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: 2 == 3 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.person, color: Colors.grey, size: 24.sp),
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineTile({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required String desc,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 22.sp),
              Container(width: 2.w, height: 32.h, color: Colors.grey.shade200),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.black54, fontSize: 13.sp),
                ),
                Text(
                  desc,
                  style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
