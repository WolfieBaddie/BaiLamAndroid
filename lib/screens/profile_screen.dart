import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  String fullName = "";
  String studentId = "";
  String email = "";

  ProfileScreen({required this.fullName, required this.studentId, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')), // <head>
      body: Padding( // <body>
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Full Name: $fullName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Student ID: $studentId', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            // Thêm thông tin profile khác nếu cần
          ],
        ),
      ),
    );
  }
}