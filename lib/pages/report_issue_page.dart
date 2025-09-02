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

class _PhotoWithTimestamp {
  final File file;
  final DateTime timestamp;
  _PhotoWithTimestamp({required this.file, required this.timestamp});
}

class ReportIssuePage extends StatefulWidget {
  final String? prefilledCategory;

  const ReportIssuePage({Key? key, this.prefilledCategory}) : super(key: key);

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
      'Broken Manhole / Drain Cover',
      'Cracks in Road Surface',
      'Damaged Speed Breaker / Missing Markings',
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
    _recorder!.openRecorder();
    _player!.openPlayer();
  }

  @override
  void dispose() {
    detailsController.dispose();
    customSubcategoryController.dispose();
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(photo.timestamp),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
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
      photos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    List<String> subcategories = selectedCategory != null
        ? [...categoryMap[selectedCategory!]!, 'Other']
        : [];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Make blue go to top
      appBar: AppBar(
        backgroundColor: mainBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Report an Issue',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  const Text(
                    'Select Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: const Text("Select category"),
                    items: categoryMap.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      filled: widget.prefilledCategory != null,
                      fillColor: widget.prefilledCategory != null
                          ? Colors.grey.shade100
                          : null,
                    ),
                    disabledHint: widget.prefilledCategory != null
                        ? Text(widget.prefilledCategory!)
                        : null,
                    isExpanded: true,
                  ),
                  if (_isCategoryRequired && selectedCategory == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "Please select a category",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Subcategory
                  const Text(
                    'Subcategory',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedSubcategory,
                    hint: const Text('Select specific issue'),
                    items: subcategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSubcategory = v;
                        if (v != 'Other') customSubcategoryController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                  if (selectedSubcategory == null ||
                      selectedSubcategory!.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "Subcategory is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (_isOtherSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextField(
                        controller: customSubcategoryController,
                        decoration: const InputDecoration(
                          labelText: "Please specify",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  if (_isOtherSelected &&
                      customSubcategoryController.text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        "Please specify the issue",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Photos
                  Row(
                    children: [
                      const Text(
                        'Capture Photos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        if (i < photos.length) {
                          final photo = photos[i];
                          return GestureDetector(
                            onTap: () => _showImagePreview(photo),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    photo.file,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  left: 2,
                                  child: Container(
                                    color: Colors.black54,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'dd MMM, hh:mm a',
                                      ).format(photo.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => photos.removeAt(i)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
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
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'At least 1 photo required. Up to 3 photos allowed.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Auto-detected Location',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            address ??
                                ((location == null ||
                                        location!.contains("Lat:"))
                                    ? "Fetching address..."
                                    : location!),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              gps != null && gps!.isNotEmpty
                                  ? "GPS coordinates: $gps"
                                  : "Fetching GPS...",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text("Refresh"),
                            onPressed: _requestAndFetchLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Additional Details
                  const Text(
                    'Additional Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter details...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Voice Note
                  Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isRecording
                            ? Row(
                                children: [
                                  const Text(
                                    'Recording...',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 18,
                                    height: 18,
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
                                  const Text(
                                    'Playing...',
                                    style: TextStyle(
                                      color: mainBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 18,
                                    height: 18,
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
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                      ),
                      if (!_isRecording && _audioPath == null)
                        IconButton(
                          icon: const Icon(Icons.mic, color: mainBlue),
                          onPressed: _startRecording,
                        ),
                      if (_isRecording)
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.red),
                          onPressed: _stopRecording,
                        ),
                      if (!_isRecording && _audioPath != null)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: mainBlue,
                              ),
                              onPressed: _isPlaying ? _stopAudio : _playAudio,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _deleteVoiceNote,
                              tooltip: "Delete voice note",
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? mainBlue
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      onPressed: _isFormValid
                          ? () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => SubmittedPage(
                                    category: selectedCategory ?? "",
                                    issueType: selectedSubcategory ?? "",
                                    dateTime: DateFormat(
                                      'dd MMM, hh:mm a',
                                    ).format(DateTime.now()),
                                    complaintId:
                                        "CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12)}",
                                  ),
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
          // Bottom Navigation Bar (exactly as in home page)
          Container(
            decoration: BoxDecoration(
              color: navBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: navBg,
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: mainBlue,
              unselectedItemColor: Colors.grey,
              iconSize: width * 0.065,
              selectedFontSize: width * 0.03,
              unselectedFontSize: width * 0.028,
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
                // index == 1 is current page, do nothing
              },
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 1 == 0 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.home, color: Colors.grey),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mainBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_circle_outline, color: mainBlue),
                  ),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 1 == 2 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.list_alt, color: Colors.grey),
                  ),
                  label: "Complaints",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: 1 == 3 ? mainBlue.withOpacity(0.12) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person, color: Colors.grey),
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
