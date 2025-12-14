import 'package:flutter/material.dart';

class TimelineEntry extends StatelessWidget {
  final Widget child;
  final bool isLast;

  const TimelineEntry({super.key, required this.child, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Spine Column
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Vertical Line
                if (!isLast)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 19,
                    child: Container(
                      width: 2,
                      color: const Color(0xFF674D32).withOpacity(0.3),
                    ),
                  ),
                // Dot
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF221910), // Dark background outline
                      width:
                          2, // slightly thinner than HTML outline-4 for mobile scale
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Scroll
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
