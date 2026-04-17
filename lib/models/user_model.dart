import '../enums/gender.dart';

class UserModel {
  final String fullName;
  final String email;
  final String password;
  final Gender gender;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.gender,
  });
}
