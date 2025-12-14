import 'package:flutter/material.dart';

class JournalHeader extends StatelessWidget {
  const JournalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // HTML uses hardcoded #221910/95. We use app theme background.
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor.withOpacity(0.95),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nav Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFFC9AD92),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: const Color(0xFFC9AD92),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Title & Avatars
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip to Japan 2023',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28, // HTML text-3xl ~= 30px
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF0ECE6), // "paper-light" for title text
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Avatar Row
                  Row(
                    children: [
                      _buildAvatarStack(),
                      const SizedBox(width: 12),
                      const Text(
                        'Shared with 5 friends',
                        style: TextStyle(
                          color: Color(0xFFC9AD92),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      height: 40,
      width: 40 + (24.0 * 3), // Base + overlap offset
      child: Stack(
        children: [
          _buildAvatar(0, 'https://i.pravatar.cc/100?img=1'),
          _buildAvatar(1, 'https://i.pravatar.cc/100?img=2'),
          _buildAvatar(2, 'https://i.pravatar.cc/100?img=3'),
          Positioned(
            left: 24.0 * 3,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF483623),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF221910), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+2',
                style: TextStyle(
                  color: Color(0xFFC9AD92),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(int index, String url) {
    return Positioned(
      left: 24.0 * index,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF221910), width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
