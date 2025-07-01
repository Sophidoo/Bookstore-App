import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String email;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.email,
    required this.role,
    required this.createdAt,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String?;
    final lastName = json['lastName'] as String?;
    final phoneNumber = json['phoneNumber'] as String?;
    final email = json['email'] as String;
    final role = json['role'] as String;

    return UserModel(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
