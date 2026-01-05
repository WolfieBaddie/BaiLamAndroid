import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Thêm import này
import 'package:hello_world/screens/welcome_screen.dart';

void main() async { // 2. Thêm async
  // 3. Khởi tạo dữ liệu format cho tiếng Việt (hoặc tất cả locale)
  await initializeDateFormatting('vi_VN', null);

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
        scaffoldBackgroundColor: surfaceLight,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}