import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Một widget nút bấm có thể tái sử dụng cho máy tính.
///
/// Nhận vào [label] để hiển thị, [onTap] callback khi được nhấn,
/// và [backgroundColor] cho màu nền của nút.
class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }
}