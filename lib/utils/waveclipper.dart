import 'dart:ui';
import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Log the size to debug
    print("WaveClipper Size: $size");

    // Starting at the left, going down by 30px
    path.lineTo(0, size.height - 30);

    // First curve (control point adjusted)
    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second curve (control point adjusted)
    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // End the path by going to the top-right corner
    path.lineTo(size.width, 0);
    path.close();

    // Log the points for debugging
    print("First Control Point: $firstControlPoint");
    print("First End Point: $firstEndPoint");
    print("Second Control Point: $secondControlPoint");
    print("Second End Point: $secondEndPoint");

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => false;
}
