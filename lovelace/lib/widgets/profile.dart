import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.name,
    required this.description,
    required this.displayPic,
  });

  final String name;
  final String description;
  final ImageProvider displayPic;

  @override
  String toString() {
    return 'Profile{name: $name, description: $description, displayPic: $displayPic}';
  }
}
