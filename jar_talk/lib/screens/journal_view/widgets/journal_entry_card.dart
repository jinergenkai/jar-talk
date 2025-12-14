import 'package:flutter/material.dart';

import 'dart:math' as math;

class JournalEntryCard extends StatelessWidget {
  final Widget child;
  final String date;
  final double rotation;
  final bool showPin;

  const JournalEntryCard({
    super.key,
    required this.child,
    required this.date,
    this.rotation = 0,
    this.showPin = true,
  });

  @override
  Widget build(BuildContext context) {
    // Hardcoded paper color to match HTML design "paper-light"
    // Ideally this would be in AppTheme if used frequently
    const paperColor = Color(0xFFF0ECE6);
    const paperTextColor = Color(0xFF2C221A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            date, // e.g. "OCT 24 • 10:30 AM"
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: const Color(
                0xFFC9AD92,
              ), // "paper-text" secondary from HTML
            ),
          ),
        ),
        // The Paper Slip
        Transform.rotate(
          angle: rotation * (math.pi / 180),
          child: Container(
            decoration: BoxDecoration(
              color: paperColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Pin Visual
                if (showPin)
                  Positioned(
                    top: -12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Transform.rotate(
                        angle: 45 * (math.pi / 180),
                        child: Icon(
                          Icons.push_pin,
                          color: math.Random().nextBool()
                              ? Colors.red
                              : Colors.orange,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                // Content
                DefaultTextStyle(
                  style: TextStyle(
                    color: paperTextColor,
                    fontFamily: 'Noto Sans',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
