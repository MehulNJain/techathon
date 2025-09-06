import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'report_model.g.dart'; // This file will be generated

@HiveType(typeId: 0)
class Report extends HiveObject {
  @HiveField(0)
  late String complaintId;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String date;

  @HiveField(3)
  late String status;

  @HiveField(4)
  late String image;

  @HiveField(5) // New field
  late String location;

  // Add this method to the Report class to get a properly formatted date

  DateTime? getDateTime() {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  String getFormattedDate() {
    final dateTime = getDateTime();
    if (dateTime != null) {
      return DateFormat.yMMMd().add_jm().format(dateTime);
    }
    return date;
  }
}
