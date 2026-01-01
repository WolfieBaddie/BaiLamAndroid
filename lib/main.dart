import 'package:flutter/material.dart';
import 'package:hello_world/screens/welcome_screen.dart'; // Bắt đầu từ màn hình chào

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const surfaceLight = Color(0xFF1F2937);
    return MaterialApp(
      title: 'Tech-Events Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: surfaceLight, // Màu nền tối cho hợp với Header
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}