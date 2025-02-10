import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0056D2); // Blue
  static const Color secondary = Color(0xFFFA7268); // Peach/Accent

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light gray background
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // White card background

  // Text Colors
  static const Color textPrimary = Color(
    0xFF333333,
  ); // Dark gray/black for primary text
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Gray for secondary text
  static const Color textHint = Color(
    0xFFBDBDBD,
  ); // Hint/placeholder text color

  // Accent Colors
  static const Color accent = Color(0xFF00C897); // Green accent
  static const Color divider = Color(0xFFE0E0E0); // Divider gray

  // Icon Colors
  static const Color iconPrimary = Color(0xFF666666); // Icon default gray
  static const Color iconAccent = Color(0xFFFA7268); // Accent for active icons

  // Button Colors
  static const Color buttonBackground = Color(
    0xFF0056D2,
  ); // Blue button background
  static const Color buttonText = Color(0xFFFFFFFF); // White button text

  // Chip/Tag Colors
  static const Color chipBackground = Color(
    0xFFF5F5F5,
  ); // Light gray chip background
  static const Color chipSelected = Color(
    0xFF0056D2,
  ); // Blue selected chip background

  // Gradient Colors
  static const List<Color> gradient = [
    Color(0xFF0056D2),
    Color(0xFF00C897),
  ]; // Gradient for cards/banners

  // Shadow Colors
  static const Color shadow = Color(0x33000000); // Slight black shadow
}
