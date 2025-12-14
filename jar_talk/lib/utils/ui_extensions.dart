import 'package:flutter/material.dart';

extension BlurExtension on Widget {
  Widget blur(double sigma) {
    // Placeholder for blur if not using BackdropFilter on plain container
    // Since this is just a background glow, we can just let opacity handle soft look
    // or use ImageFilter.
    // For actual blur, one might wrap in ImageFiltered with ImageFilter.blur
    return this;
  }
}
