import 'package:hive/hive.dart';

part 'user_profile_model.g.dart'; // This file will be generated

@HiveType(typeId: 1) // Use a new, unique typeId
class UserProfile extends HiveObject {
  @HiveField(0)
  late String fullName;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String phoneNumber;

  @HiveField(3)
  late String badge;

  @HiveField(4)
  late int points;
}
