import 'package:flutter/material.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/utils/app_theme.dart';

class SlipDetailScreen extends StatelessWidget {
  final Slip slip;

  const SlipDetailScreen({super.key, required this.slip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    // Helper for formatting date
    String formatDate(DateTime date) {
      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      final month = months[date.month - 1];
      return '$month ${date.day}, ${date.year}';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Text(
                    'View Slip',
                    style: TextStyle(
                      fontFamily: 'Noto Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, // TODO: More options
                    icon: const Icon(Icons.more_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  children: [
                    // Slip Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2c241b) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.4 : 0.08,
                            ),
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Decorative Top Border
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Slip Header Info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatDate(slip.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: appTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(isDark ? 0.2 : 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lock_open,
                                            size: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Shared with Jar',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Media (Image)
                                if (slip.media != null &&
                                    slip.media!.isNotEmpty) ...[
                                  for (var media in slip.media!)
                                    if (media.mediaType == 'image')
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            media.downloadUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                ),
                                          ),
                                        ),
                                      ),
                                ],

                                // Content Body
                                Text(
                                  slip.textContent,
                                  style: TextStyle(
                                    fontFamily: 'Noto Serif',
                                    fontSize: 18,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFFe8e6e3)
                                        : const Color(0xFF1b140d),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Author / Signature
                                Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[200],
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            slip.authorEmail != null
                                                ? 'https://ui-avatars.com/api/?name=${slip.authorUsername}&background=random'
                                                : 'https://i.pravatar.cc/100?img=${(slip.authorId % 70) + 1}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Written by ${slip.authorUsername ?? "Unknown"}',
                                        style: TextStyle(
                                          fontFamily: 'Noto Sans',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: appTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Interaction Section (Reactions & Comments)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Placeholder for Reactions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildReactionAvatar(isDark),
                                  _buildReactionAvatar(isDark, offset: true),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    transform: Matrix4.translationValues(
                                      -16,
                                      0,
                                      0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withOpacity(isDark ? 0.3 : 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+24',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Jane, Mike + 24 others reacted',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: appTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Input Field
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2c241b)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Write a supportive note...',
                                      hintStyle: TextStyle(
                                        color: appTheme.textSecondary
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.edit_note,
                                        color: appTheme.textSecondary
                                            .withOpacity(0.5),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.send,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: Text(
                                'View all 12 comments',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appTheme.textSecondary,
                                ),
                              ),
                              label: Icon(
                                Icons.expand_more,
                                size: 16,
                                color: appTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionAvatar(bool isDark, {bool offset = false}) {
    return Container(
      width: 32,
      height: 32,
      transform: offset ? Matrix4.translationValues(-8, 0, 0) : null,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        border: Border.all(
          color: isDark
              ? const Color(0xFF221910)
              : const Color(0xFFf8f7f6), // Match scaffold bg
          width: 2,
        ),
      ),
      child: const Icon(Icons.person, size: 20, color: Colors.grey),
    );
  }
}
