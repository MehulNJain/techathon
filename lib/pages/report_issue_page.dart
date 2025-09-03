import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'home_page.dart';
import 'reports_page.dart';
import 'user_profile_page.dart';
import 'submitted_page.dart';
import '../models/report_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _PhotoWithTimestamp {
  final File file;
  final DateTime timestamp;
  _PhotoWithTimestamp({required this.file, required this.timestamp});
}

class ReportIssuePage extends StatefulWidget {
  final String? prefilledCategory;

  const ReportIssuePage({super.key, this.prefilledCategory});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  String? selectedCategory;
  String? selectedSubcategory;
  String? customSubcategory;
  List<_PhotoWithTimestamp> photos = [];
  String? location;
  String? gps;
  String? address;
  TextEditingController detailsController = TextEditingController();
  TextEditingController customSubcategoryController = TextEditingController();

  static const mainBlue = Color(0xFF1746D1);
  static const navBg = Color(0xFFF0F4FF);

  // Audio
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  final Map<String, List<String>> categoryMap = {
    'Garbage': [
      'Uncollected / Overflowing Garbage Bin',
      'Garbage Dumping in Open Area',
      'Damaged / Missing Garbage Bin',
      'Dead Animal Disposal',
    ],
    'Street Light': [
      'Light not working at night',
      'Light flickering',
      'Light glowing in daytime',
      'Pole damaged / wire issue',
    ],
    'Road Damage': [
      'Pothole',
      'Broken Manhole / Drain',
      'Cracks in Road Surface',
      'Damaged Speed Breaker',
    ],
    'Water': ['Water Leakage', 'Water Contamination / Dirty Water'],
    'Drainage & Sewerage': [
      'Blocked Drain',
      'Flooding / Waterlogging',
      'Open Sewer / Foul Smell',
      'Broken Drain Cover',
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.prefilledCategory != null &&
        categoryMap.keys.contains(widget.prefilledCategory)) {
      selectedCategory = widget.prefilledCategory;
    }
    _requestAndFetchLocation();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    Future.microtask(() async {
      await _recorder!.openRecorder();
      await _player!.openPlayer();
    });
  }

  @override
  void dispose() {
    detailsController.dispose();
    customSubcategoryController.dispose();
    Future.microtask(() async {
      await _recorder?.closeRecorder();
      await _player?.closePlayer();
    });
    super.dispose();
  }

  Future<void> _requestAndFetchLocation() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
            "Location permission is permanently denied. Please enable it from app settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(ctx).pop();
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
      setState(() {
        location = "Location permission denied";
        gps = "";
        address = null;
      });
      return;
    }
    if (!status.isGranted) {
      setState(() {
        location = "Location permission denied";
        gps = "";
        address = null;
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
        location = "Lat: ${pos.latitude}, Lng: ${pos.longitude}";
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
        location = "Unable to fetch location";
        gps = "";
        address = null;
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
      File? compressed = await _compressImage(File(picked.path));
      setState(() {
        if (photos.length < 3 && compressed != null) {
          photos.add(
            _PhotoWithTimestamp(file: compressed, timestamp: DateTime.now()),
          );
        }
      });
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return file;
      if (image.width > 1024) {
        image = img.copyResize(image, width: 1024);
      }
      final compressedBytes = img.encodeJpg(image, quality: 60);
      final dir = await getTemporaryDirectory();
      final target = File(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );
      await target.writeAsBytes(compressedBytes);
      return target;
    } catch (e) {
      return file;
    }
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) return;
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/voice_note.aac';
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
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isCategoryRequired => widget.prefilledCategory == null;
  bool get _isOtherSelected => selectedSubcategory == 'Other';
  bool get _isFormValid =>
      (selectedCategory != null || !_isCategoryRequired) &&
      selectedSubcategory != null &&
      selectedSubcategory!.isNotEmpty &&
      (!_isOtherSelected ||
          (customSubcategoryController.text.trim().isNotEmpty)) &&
      photos.isNotEmpty &&
      address != null &&
      address!.isNotEmpty &&
      address != "Address not found";

  @override
  Widget build(BuildContext context) {
    List<String> subcategories = selectedCategory != null
        ? [...categoryMap[selectedCategory!]!, 'Other']
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: mainBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Report an Issue',
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    // FIX: Enforce fixed height to prevent vertical jumping
                    height: 55.h,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      hint: Text(
                        "Select category",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      items: categoryMap.keys
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: TextStyle(fontSize: 14.sp)),
                            ),
                          )
                          .toList(),
                      onChanged: widget.prefilledCategory != null
                          ? null
                          : (v) {
                              setState(() {
                                selectedCategory = v;
                                selectedSubcategory = null;
                              });
                            },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        filled: widget.prefilledCategory != null,
                        fillColor: widget.prefilledCategory != null
                            ? Colors.grey.shade100
                            : null,
                      ),
                      disabledHint: widget.prefilledCategory != null
                          ? Text(
                              widget.prefilledCategory!,
                              style: TextStyle(fontSize: 14.sp),
                            )
                          : null,
                      isExpanded: true,
                    ),
                  ),
                  if (_isCategoryRequired && selectedCategory == null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        "Please select a category",
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ),
                  SizedBox(height: 20.h),

                  Text(
                    'Subcategory',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    // FIX: Enforce fixed height to prevent vertical jumping
                    height: 55.h,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedSubcategory,
                      hint: Text(
                        'Select specific issue',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      items: subcategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: TextStyle(fontSize: 14.sp)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedSubcategory = v;
                          if (v != 'Other') customSubcategoryController.clear();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                  if (selectedSubcategory == null ||
                      selectedSubcategory!.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        "Subcategory is required",
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ),
                  if (_isOtherSelected)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: TextField(
                        controller: customSubcategoryController,
                        decoration: InputDecoration(
                          labelText: "Please specify",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        style: TextStyle(fontSize: 14.sp),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  if (_isOtherSelected &&
                      customSubcategoryController.text.trim().isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        "Please specify the issue",
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ),
                  SizedBox(height: 20.h),

                  Row(
                    children: [
                      Text(
                        'Capture Photos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 15.sp),
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
                                    height: 90.w,
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
                                    onTap: () =>
                                        setState(() => photos.removeAt(i)),
                                    child: Container(
                                      decoration: BoxDecoration(
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
                              height: 90.w,
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

                  Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
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
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 20.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Auto-detected Location',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
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
                            address ??
                                ((location == null ||
                                        location!.contains("Lat:"))
                                    ? "Fetching address..."
                                    : location!),
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.gps_fixed,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
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
                            label: Text(
                              "Refresh",
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            onPressed: _requestAndFetchLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    'Additional Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter details...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Icon(Icons.mic, color: Colors.grey, size: 20.sp),
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
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                      strokeWidth: 3,
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
                                      color: mainBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: CircularProgressIndicator(
                                      color: mainBlue,
                                      strokeWidth: 3,
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
                                  fontSize: 13.sp,
                                ),
                              ),
                      ),
                      if (!_isRecording && _audioPath == null)
                        IconButton(
                          icon: Icon(Icons.mic, color: mainBlue, size: 22.sp),
                          onPressed: _startRecording,
                        ),
                      if (_isRecording)
                        IconButton(
                          icon: Icon(
                            Icons.stop,
                            color: Colors.red,
                            size: 22.sp,
                          ),
                          onPressed: _stopRecording,
                        ),
                      if (!_isRecording && _audioPath != null)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: mainBlue,
                                size: 22.sp,
                              ),
                              onPressed: _isPlaying ? _stopAudio : _playAudio,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 22.sp,
                              ),
                              onPressed: _deleteVoiceNote,
                              tooltip: "Delete voice note",
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                      label: Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? mainBlue
                            : Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                      onPressed: _isFormValid
                          ? () {
                              final report = ReportData(
                                category: selectedCategory ?? "",
                                subcategory: selectedSubcategory ?? "",
                                description: detailsController.text,
                                photos: photos
                                    .map(
                                      (p) => ReportPhoto(
                                        path: p.file.path,
                                        timestamp: p.timestamp,
                                      ),
                                    )
                                    .toList(),
                                location: address ?? "",
                                dateTime: DateFormat(
                                  'dd MMM, hh:mm a',
                                ).format(DateTime.now()),
                                complaintId:
                                    "CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12)}",
                                voiceNotePath: _audioPath,
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => SubmittedPage(report: report),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: mainBlue,
              unselectedItemColor: Colors.grey,
              iconSize: 24.sp,
              selectedFontSize: 14.sp,
              unselectedFontSize: 13.sp,
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
                } else if (index == 2) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyReportsPage()),
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => UserProfilePage()),
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
                      color: 1 == 0 ? mainBlue.withOpacity(0.12) : null,
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
                      color: mainBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: mainBlue,
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
                      color: 1 == 2 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.list_alt,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
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
                      color: 1 == 3 ? mainBlue.withOpacity(0.12) : null,
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
}
