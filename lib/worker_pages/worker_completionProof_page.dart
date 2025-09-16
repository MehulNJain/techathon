import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'worker_workCompletion_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:CiTY/l10n/app_localizations.dart';

class _PhotoWithTimestamp {
  final File file;
  final DateTime timestamp;
  _PhotoWithTimestamp({required this.file, required this.timestamp});
}

class WorkerCompletionProofPage extends StatefulWidget {
  final String complaintId;

  const WorkerCompletionProofPage({super.key, required this.complaintId});

  @override
  State<WorkerCompletionProofPage> createState() =>
      _WorkerCompletionProofPageState();
}

class _WorkerCompletionProofPageState extends State<WorkerCompletionProofPage> {
  List<_PhotoWithTimestamp> photos = [];
  String? gps;
  String? address;
  TextEditingController notesController = TextEditingController();
  bool _isSubmitting = false; // Add this for loading state

  // Audio
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure context is ready for location fetching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndFetchLocation();
    });
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    Future.microtask(() async {
      await _recorder!.openRecorder();
      await _player!.openPlayer();
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    Future.microtask(() async {
      await _recorder?.closeRecorder();
      await _player?.closePlayer();
    });
    super.dispose();
  }

  Future<void> _requestAndFetchLocation() async {
    final loc = AppLocalizations.of(context)!;
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.permissionRequired),
          content: Text(loc.locationPermissionPermanentlyDenied),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(ctx).pop();
              },
              child: Text(loc.openSettings),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.cancel),
            ),
          ],
        ),
      );
      setState(() {
        address = loc.locationPermissionDenied;
        gps = "";
      });
      return;
    }
    if (!status.isGranted) {
      setState(() {
        gps = "";
        address = loc.locationPermissionDenied;
      });
      return;
    }
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final loc = AppLocalizations.of(context)!;
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
          address = loc.addressNotFound;
        });
      }
    } catch (e) {
      setState(() {
        gps = "";
        address = loc.unableToFetchLocation;
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
    final loc = AppLocalizations.of(context)!;
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
                loc.close,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
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

  bool get _isFormValid {
    final loc = AppLocalizations.of(context)!;
    final isLocationValid =
        address != null &&
        address!.isNotEmpty &&
        address != loc.addressNotFound &&
        address != loc.locationPermissionDenied &&
        address != loc.unableToFetchLocation;

    return photos.isNotEmpty && isLocationValid;
  }

  // --- NEW FIREBASE METHODS ---

  Future<List<String>> _uploadPhotosToStorage() async {
    final storageRef = FirebaseStorage.instance.ref();
    List<String> photoUrls = [];
    for (var i = 0; i < photos.length; i++) {
      final photo = photos[i];
      final timestampStr = photo.timestamp.toIso8601String().replaceAll(
        ':',
        '-',
      );
      final fileName = 'completion_photo_${i + 1}_$timestampStr.jpg';
      final ref = storageRef.child(
        'complaints/${widget.complaintId}/completion_proofs/$fileName',
      );
      final uploadTask = await ref.putFile(photo.file);
      final url = await uploadTask.ref.getDownloadURL();
      photoUrls.add(url);
    }
    return photoUrls;
  }

  Future<String?> _uploadAudioToStorage() async {
    if (_audioPath == null) return null;
    final storageRef = FirebaseStorage.instance.ref();
    final fileName =
        'completion_voice_note_${DateTime.now().toIso8601String().replaceAll(':', '-')}.aac';
    final ref = storageRef.child(
      'complaints/${widget.complaintId}/completion_proofs/$fileName',
    );
    final uploadTask = await ref.putFile(File(_audioPath!));
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submitCompletionProof() async {
    if (photos.isEmpty || _isSubmitting) return;
    final loc = AppLocalizations.of(context)!;

    setState(() => _isSubmitting = true);

    try {
      // 1. Upload files to Storage
      final List<String> photoUrls = await _uploadPhotosToStorage();
      final String? voiceNoteUrl = await _uploadAudioToStorage();

      // 2. Prepare data for Realtime Database
      final completionData = {
        'status': 'Resolved',
        'completionPhotos': photoUrls,
        'completionNotes': notesController.text.trim(),
        'completionTimestamp': DateTime.now().toIso8601String(),
        'completionGps': gps,
        'completionAddress': address,
        if (voiceNoteUrl != null) 'completionVoiceNote': voiceNoteUrl,
      };

      // 3. Update the complaint in Firebase
      final dbRef = FirebaseDatabase.instance
          .ref()
          .child('complaints')
          .child(widget.complaintId);
      await dbRef.update(completionData);

      if (!mounted) return;

      // 4. Navigate to success page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WorkerWorkCompletionSuccessPage(
            complaintId: widget.complaintId,
            // You might need to fetch these from the complaint data if required
            supervisorId: 'N/A',
            citizenId: 'N/A',
          ),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.failedToSubmitProof(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            Colors.orange.shade700, // Changed to match WorkerHomePage
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.completionProofTitle,
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
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
                    size: 22.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15.sp,
                        ),
                        children: [TextSpan(text: loc.completionProofInfo)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  loc.capturePhotos,
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
                              onTap: () => setState(() => photos.removeAt(i)),
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
              loc.photoRequirementNote,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 20.h),

            // Location
            Text(
              loc.location,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
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
                        loc.autoDetectedLocation,
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
                      address ?? loc.fetchingAddress,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Icon(
                          Icons.gps_fixed,
                          size: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          gps != null && gps!.isNotEmpty
                              ? loc.gpsCoordinates(gps!)
                              : loc.fetchingGps,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
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
                        loc.refresh,
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      onPressed: _requestAndFetchLocation,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Additional Information
            Text(
              loc.additionalDetails,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.addNotesHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),

            // Voice Note
            Row(
              children: [
                Icon(Icons.mic, color: Colors.grey, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: _isRecording
                      ? Row(
                          children: [
                            Text(
                              loc.recording,
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
                              loc.playing,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 3,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _audioPath == null
                              ? loc.recordVoiceNote
                              : loc.voiceNoteRecorded,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13.sp,
                          ),
                        ),
                ),
                if (!_isRecording && _audioPath == null)
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.blue, size: 22.sp),
                    onPressed: _startRecording,
                  ),
                if (_isRecording)
                  IconButton(
                    icon: Icon(Icons.stop, color: Colors.red, size: 22.sp),
                    onPressed: _stopRecording,
                  ),
                if (!_isRecording && _audioPath != null)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.blue,
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
                        tooltip: loc.deleteVoiceNote,
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
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                label: Text(
                  _isSubmitting ? loc.submitting : loc.submit,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? Colors.orange.shade700
                      : Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                onPressed: _isFormValid && !_isSubmitting
                    ? _submitCompletionProof
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
