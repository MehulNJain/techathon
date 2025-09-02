class ReportData {
  final String category;
  final String subcategory;
  final String description;
  final List<String> photoPaths; // Local file paths
  final String? voiceNotePath;
  final String location;
  final String dateTime;
  final String complaintId;

  ReportData({
    required this.category,
    required this.subcategory,
    required this.description,
    required this.photoPaths,
    required this.location,
    required this.dateTime,
    required this.complaintId,
    this.voiceNotePath,
  });
}
