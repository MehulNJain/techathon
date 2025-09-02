class ReportPhoto {
  final String path;
  final DateTime timestamp;
  ReportPhoto({required this.path, required this.timestamp});
}

class ReportData {
  final String category;
  final String subcategory;
  final String description;
  final List<ReportPhoto> photos;
  final String? voiceNotePath;
  final String location;
  final String dateTime;
  final String complaintId;

  ReportData({
    required this.category,
    required this.subcategory,
    required this.description,
    required this.photos,
    required this.location,
    required this.dateTime,
    required this.complaintId,
    this.voiceNotePath,
  });
}
