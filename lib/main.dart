import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const MyApp());
}

// Định nghĩa các hằng số màu sắc để dễ quản lý và tái sử dụng
const Color primaryColor = Color(0xFF2D3142);
const Color secondaryColor = Color(0xFF4F5D75);
const Color accentColor = Color(0xFFEF8354);
const Color whiteColor = Colors.white;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        scaffoldBackgroundColor: primaryColor,
        // Sử dụng google_fonts để áp dụng font Roboto cho toàn bộ ứng dụng
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: whiteColor, displayColor: whiteColor),
      ),
      home: const CalculatorScreen(),
    );
  }
}
