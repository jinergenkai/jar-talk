import 'dart:convert';
import 'package:flutter/material.dart';

class JarStyle {
  final String shape;
  final int colorIndex;
  final String theme;

  JarStyle({
    required this.shape,
    required this.colorIndex,
    required this.theme,
  });

  factory JarStyle.fromJson(String json) {
    try {
      final map = jsonDecode(json);
      return JarStyle(
        shape: map['shape'] ?? 'Mason',
        colorIndex: map['colorIndex'] ?? 0,
        theme: map['theme'] ?? 'default',
      );
    } catch (e) {
      return JarStyle.defaultStyle();
    }
  }

  String toJson() {
    return jsonEncode({
      'shape': shape,
      'colorIndex': colorIndex,
      'theme': theme,
    });
  }

  static JarStyle defaultStyle() {
    return JarStyle(shape: 'Mason', colorIndex: 0, theme: 'default');
  }

  static const List<int> defaultColors = [
    0xFFD47311, // Primary Orange
    0xFF5D4037, // Brown
    0xFF388E3C, // Green
    0xFF1976D2, // Blue
    0xFF7B1FA2, // Purple
  ];

  static Color getColor(int index) {
    if (index < 0 || index >= defaultColors.length)
      return Color(defaultColors[0]);
    return Color(defaultColors[index]);
  }
}
