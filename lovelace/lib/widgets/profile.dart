import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.email,
    required this.name,
    required this.description,
    required this.displayPic,
  });

  final String email;
  final String name;
  final String description;
  final ImageProvider displayPic;

  @override
  String toString() {
    return 'Profile{email: $email, name: $name, description: $description, displayPic: $displayPic}';
  }
}
