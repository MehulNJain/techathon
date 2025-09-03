import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _PhotoWithTimestamp {
  final File file;
  final DateTime timestamp;
  _PhotoWithTimestamp({required this.file, required this.timestamp});
}

class WorkerReportIssuePage extends StatefulWidget {
  const WorkerReportIssuePage({super.key});

  @override
  State<WorkerReportIssuePage> createState() => _WorkerReportIssuePageState();
}

class _WorkerReportIssuePageState extends State<WorkerReportIssuePage> {
  List<_PhotoWithTimestamp> photos = [];
  String? gps;
  String? address;
  TextEditingController notesController = TextEditingController();

  // Audio
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _requestAndFetchLocation();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _recorder!.openRecorder();
    _player!.openPlayer();
  }

  @override
  void dispose() {
    notesController.dispose();
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  Future<void> _requestAndFetchLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) {
      setState(() {
        gps = "";
        address = "Location permission denied";
      });
      return;
    }
    if (!status.isGranted) {
      setState(() {
        gps = "";
        address = "Location permission denied";
      });
      return;
    }
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        gps = "${pos.latitude}, ${pos.longitude}";
      });
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          address = [
            if (p.name != null && p.name!.isNotEmpty) p.name,
            if (p.street != null && p.street!.isNotEmpty) p.street,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality,
            if (p.subAdministrativeArea != null &&
                p.subAdministrativeArea!.isNotEmpty)
              p.subAdministrativeArea,
            if (p.administrativeArea != null &&
                p.administrativeArea!.isNotEmpty)
              p.administrativeArea,
            if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
            if (p.country != null && p.country!.isNotEmpty) p.country,
          ].whereType<String>().join(', ');
        });
      } else {
        setState(() {
          address = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        gps = "";
        address = "Unable to fetch location";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (picked != null) {
      setState(() {
        if (photos.length < 3) {
          photos.add(
            _PhotoWithTimestamp(
              file: File(picked.path),
              timestamp: DateTime.now(),
            ),
          );
        }
      });
    }
  }

  void _showImagePreview(_PhotoWithTimestamp photo) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(photo.file),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(photo.timestamp),
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/worker_voice_note.aac';
    await _recorder!.startRecorder(toFile: path, codec: Codec.aacADTS);
    setState(() {
      _audioPath = path;
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    setState(() => _isPlaying = true);
    await _player!.startPlayer(
      fromURI: _audioPath,
      whenFinished: () => setState(() => _isPlaying = false),
    );
  }

  Future<void> _stopAudio() async {
    await _player!.stopPlayer();
    setState(() => _isPlaying = false);
  }

  void _deleteVoiceNote() {
    if (_audioPath != null) {
      File(_audioPath!).delete().catchError((_) {});
    }
    setState(() {
      _audioPath = null;
      _isPlaying = false;
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Report Issue",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14.r),
              ),
              margin: EdgeInsets.only(bottom: 18.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15.sp,
                        ),
                        children: [
                          const TextSpan(text: "Upload at least "),
                          TextSpan(
                            text: "1 photo",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: " (max 3) as proof of issue."),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'Capture Photos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 90.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, i) {
                  if (i < photos.length) {
                    final photo = photos[i];
                    return GestureDetector(
                      onTap: () => _showImagePreview(photo),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              photo.file,
                              width: 90.w,
                              height: 90.h,
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
                          Positioned(
                            top: 2.h,
                            right: 2.w,
                            child: GestureDetector(
                              onTap: () => setState(() => photos.removeAt(i)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 90.w,
                        height: 90.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.grey.shade100,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 32.sp,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'At least 1 photo required. Up to 3 photos allowed.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 20.h),

            // Location
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Auto-detected Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      address ?? "Fetching address...",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 6.w),
                      Text(
                        gps != null && gps!.isNotEmpty
                            ? "GPS coordinates: $gps"
                            : "Fetching GPS...",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: Icon(Icons.refresh, size: 16.sp),
                      label: Text("Refresh", style: TextStyle(fontSize: 14.sp)),
                      onPressed: _requestAndFetchLocation,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Additional Information
            Text(
              "Additional Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add notes/remarks (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
            SizedBox(height: 12.h),

            // Voice Note
            Row(
              children: [
                Icon(Icons.mic, color: Colors.grey, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: _isRecording
                      ? Row(
                          children: [
                            Text(
                              'Recording...',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 3.w,
                              ),
                            ),
                          ],
                        )
                      : _isPlaying
                      ? Row(
                          children: [
                            Text(
                              'Playing...',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 3.w,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _audioPath == null
                              ? 'Record voice note (optional)'
                              : 'Voice note recorded',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15.sp,
                          ),
                        ),
                ),
                if (!_isRecording && _audioPath == null)
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.blue, size: 28.sp),
                    onPressed: _startRecording,
                  ),
                if (_isRecording)
                  IconButton(
                    icon: Icon(Icons.stop, color: Colors.red, size: 28.sp),
                    onPressed: _stopRecording,
                  ),
                if (!_isRecording && _audioPath != null)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.blue,
                          size: 28.sp,
                        ),
                        onPressed: _isPlaying ? _stopAudio : _playAudio,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 28.sp,
                        ),
                        onPressed: _deleteVoiceNote,
                        tooltip: "Delete voice note",
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 28.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.report_problem,
                  color: Colors.white,
                  size: 24.sp,
                ),
                label: Text(
                  'Submit Issue',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                onPressed: photos.isNotEmpty
                    ? () {
                        // Submit logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Issue submitted!")),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
