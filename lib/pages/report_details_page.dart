import 'package:CiTY/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_page.dart';
import 'reports_page.dart';
import 'user_profile_page.dart';
import 'report_issue_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';

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
  final String url; // Changed from path to url
  const VoiceNotePlayer({super.key, required this.url});

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen((_) => setState(() => _isPlaying = false));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      // ✅ Use UrlSource for Firebase URLs
      await _player.play(UrlSource(widget.url));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;
    final bool isNonLatinScript =
        (currentLocale == 'sat' || currentLocale == 'hi');

    return ElevatedButton.icon(
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.blue,
        size: 20.sp, // Slightly smaller icon
      ),
      label: Text(
        _isPlaying ? loc.pauseVoiceNote : loc.playVoiceNote,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: isNonLatinScript
              ? 12.sp
              : 14.sp, // Smaller font for Hindi/Santali
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.08),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 8.h,
        ), // Reduced horizontal padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onPressed: _togglePlay,
    );
  }
}

class ReportDetailsPage extends StatefulWidget {
  final String complaintId;
  const ReportDetailsPage({super.key, required this.complaintId});

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  Map<String, dynamic>? complaintData;
  bool _loading = true;
  String formattedDate = '';
  String formattedTime = '';
  String effectiveStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  Future<void> _loadComplaint() async {
    // First, try to load from Hive cache for instant display
    final box = Hive.box<Report>('reportsBox');
    final cachedReport = box.get(widget.complaintId);
    if (cachedReport != null) {
      // Use cached data to build a temporary map for display
      setState(() {
        complaintData = {
          'complaintId': cachedReport.complaintId,
          'category': cachedReport.title.split(' - ')[0],
          'subcategory': cachedReport.title.split(' - ')[1],
          'status': cachedReport.status,
          // We need to fetch the rest from Firebase
        };
        effectiveStatus = cachedReport.status;
        _loading = false; // Stop loading, show cached data
      });
    }
    // Always fetch from Firebase for the latest details
    await _fetchComplaintFromFirebase();
  }

  Future<void> _fetchComplaintFromFirebase() async {
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

      if (data['assignedTo'] != null) {
        effectiveStatus = "Assigned";
      } else {
        effectiveStatus = data['status'] ?? 'Pending';
      }

      if (mounted) {
        setState(() {
          complaintData = data;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ✅ Helper to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xFFB26A00); // Dark Orange
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

  // ✅ Helper to get status background color
  Color _getStatusBgColor(String status) {
    switch (status) {
      case "Pending":
        return const Color(0xFFFFF6E0); // Light Orange
      case "Assigned":
        return Colors.purple.withOpacity(0.1);
      case "In Progress":
        return Colors.blue.withOpacity(0.1);
      case "Resolved":
        return Colors.green.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (complaintData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text(loc.complaintNotFound)),
      );
    }

    final photos = (complaintData!['photos'] as List<dynamic>? ?? []);
    final voiceNoteUrl = complaintData!['voiceNote'];

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
          loc.reportDetails,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
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
                          color: ReportDetailsPage.mainBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          getCategoryIcon(complaintData!['category'] ?? ''),
                          color: ReportDetailsPage.mainBlue,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${complaintData!['category'] ?? ''} - ${complaintData!['subcategory'] ?? ''}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "$formattedDate, $formattedTime",
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
                        color: ReportDetailsPage.mainBlue,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          complaintData!['location'] ?? '',
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
                      Expanded(
                        // Add this to allow text to wrap if needed
                        child: Text(
                          loc.refId("", complaintData!['complaintId'] ?? ''),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13.sp,
                          ),
                          maxLines: 2, // Allow two lines
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w), // Add space before the chip
                      // ✅ DYNAMIC STATUS CHIP
                      Chip(
                        label: Text(
                          effectiveStatus,
                          style: TextStyle(
                            color: _getStatusColor(effectiveStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        backgroundColor: _getStatusBgColor(effectiveStatus),
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
            if (photos.isNotEmpty)
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
                      loc.photosSubmitted,
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
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, i) {
                          final photoUrl = photos[i];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.black,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.network(photoUrl),
                                      Padding(
                                        padding: EdgeInsets.all(8.w),
                                        child: Text(
                                          "$formattedDate, $formattedTime",
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
                                          loc.close,
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
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    photoUrl,
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
                                      "$formattedDate, $formattedTime",
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
                    loc.issueDescription,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    complaintData!['description'] ?? '',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  if (voiceNoteUrl != null && voiceNoteUrl != "") ...[
                    SizedBox(height: 12.h),
                    // ✅ Pass URL to the player
                    VoiceNotePlayer(url: voiceNoteUrl),
                  ],
                ],
              ),
            ),

            // ✅ UPDATED STATUS TIMELINE
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
                    loc.statusTimeline,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildStatusTimeline(),
                ],
              ),
            ),

            SizedBox(height: 20.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // ✅ Updated method to build the timeline with all status steps
  Widget _buildStatusTimeline() {
    final loc = AppLocalizations.of(context)!;

    // Determine the current status stage (0=Submitted, 1=Pending, 2=Assigned, 3=In Progress, 4=Resolved)
    int currentStage = 0;

    if (complaintData!['status'] == 'Resolved') {
      currentStage = 4;
    } else if (complaintData!['status'] == 'In Progress') {
      currentStage = 3;
    } else if (complaintData!['assignedTo'] != null) {
      currentStage = 2;
    } else {
      currentStage = 1; // Pending by default after submission
    }

    return Column(
      children: [
        // 1. Submitted (Always completed)
        _timelineTile(
          icon: Icons.check_circle,
          color: Colors.green,
          title: loc.submitted,
          date: "$formattedDate, $formattedTime",
          desc: loc.reportSubmittedByCitizen,
          isLast: false,
          isActive: true,
        ),

        // 2. Pending Review
        _timelineTile(
          icon: Icons.hourglass_empty,
          color: currentStage >= 1 ? const Color(0xFFB26A00) : Colors.grey,
          title: loc.pendingReview,
          date: currentStage > 1 ? loc.completed : loc.currentStage,
          desc: loc.waitingForAssignment,
          isLast: false,
          isActive: currentStage >= 1,
        ),

        // 3. Assigned
        _timelineTile(
          icon: Icons.person_search,
          color: currentStage >= 2 ? Colors.purple : Colors.grey,
          title: loc.assigned,
          date: currentStage > 2
              ? (complaintData!['assignedTimestamp'] != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(
                        DateTime.parse(complaintData!['assignedTimestamp']),
                      )
                    : loc.timestampNotAvailable)
              : (currentStage == 2 ? loc.currentStage : loc.notYet),
          desc: loc.assignedToMunicipalWorker,
          isLast: false,
          isActive: currentStage >= 2,
        ),

        // 4. In Progress
        _timelineTile(
          icon: Icons.construction,
          color: currentStage >= 3 ? Colors.blue : Colors.grey,
          title: loc.inProgress,
          date: currentStage > 3
              ? loc.completed
              : (currentStage == 3 ? loc.currentStage : loc.notYet),
          desc: loc.workHasStarted,
          isLast: false,
          isActive: currentStage >= 3,
        ),

        // 5. Resolved
        _timelineTile(
          icon: Icons.verified,
          color: currentStage >= 4 ? Colors.green : Colors.grey,
          title: loc.resolved,
          date: currentStage == 4 ? loc.currentStage : loc.notYet,
          desc: loc.issueResolved,
          isLast: true,
          isActive: currentStage >= 4,
        ),
      ],
    );
  }

  Widget _timelineTile({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required String desc,
    bool isLast = false,
    bool isActive = true,
  }) {
    // Get current locale
    final currentLocale = Localizations.localeOf(context).languageCode;
    final bool isNonLatinScript =
        (currentLocale == 'sat' || currentLocale == 'hi');

    // Adjust font sizes for non-Latin scripts
    final double titleFontSize = isNonLatinScript ? 13.sp : 15.sp;
    final double dateFontSize = isNonLatinScript ? 12.sp : 13.sp;
    final double descFontSize = isNonLatinScript ? 12.sp : 13.sp;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? color.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  border: Border.all(
                    color: isActive ? color : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isActive ? color : Colors.grey.shade400,
                  size: 18.sp,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 40.h,
                  color: isActive
                      ? color.withOpacity(0.5)
                      : Colors.grey.shade300,
                ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            // Make sure this is expandable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? color : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize, // Adjusted size
                  ),
                  maxLines: 2, // Allow wrapping
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: dateFontSize, // Adjusted size
                    fontWeight: date == "Current Stage"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 2.h), // Reduced spacing
                Text(
                  desc,
                  style: TextStyle(
                    color: isActive ? Colors.black87 : Colors.grey.shade500,
                    fontSize: descFontSize, // Adjusted size
                  ),
                  maxLines: 3, // Allow wrapping
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
