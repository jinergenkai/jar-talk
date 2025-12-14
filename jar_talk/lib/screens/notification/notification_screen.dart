import 'package:flutter/material.dart';
import 'package:jar_talk/utils/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'unread'; // 'all', 'unread', 'invites'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final appTheme = theme.extension<AppThemeExtension>()!; // Unused in build method directly if children don't use it, but they do. Wait, line 17 is declaration.
    // Actually, checking usage: appTheme is used in _buildInviteCard, etc. but strictly in build() it might not be used.
    // Let's check if it is used in the main build method.
    // It is NOT used in the main build method, only in helper methods.
    // However, the helpers obtain it themselves via context again.
    // So the one in build() is redundancy. I will remove it from build().
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Activity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement Mark all read
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
            ),

            // Segmented Control
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A2D20) // Dark mode bg matching design
                      : const Color(0xFFE5E7EB), // Light mode bg (gray-200)
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildSegment('all', 'All Activity'),
                    _buildSegment('unread', 'Unread'),
                    _buildSegment('invites', 'Invites'),
                  ],
                ),
              ),
            ),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader('TODAY'),
                  const SizedBox(height: 12),
                  _buildInviteCard(
                    context,
                    name: 'Group Admin',
                    action: 'invited you to the',
                    target: 'Phan Thiết Jar',
                    targetIcon: Icons.eco,
                    time: '2m ago',
                    description:
                        '"Hey! I created a new jar for our upcoming trip. Join us to collect memories!"',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAOZx-QIWmb-QrENqbb7fBNOnYxMYQke8w-pOp3nhWLvdck2Pu2Hdnl1SWY7B8WKBgwAi5MldRGnkHrBuIY3bG3IWZyPsVmPb5mh6KICIXCce2Ws-f8huwNj2EjgxtlxejWFwrQsU1GSTJhjoUfeafVVq3fjVizN1NtEd1UGWGsdunWH2qias0zGt48glZkOB9KZJAJhsoAXZnnLvZ9UjAubhrk_MOOHKAfbit5jW5RczzGepHAEvPYsPAj-hPsHHozr8wctBb4wcyf',
                    isUnread: true,
                  ),
                  const SizedBox(height: 12),
                  _buildReactionCard(
                    context,
                    name: 'Nam',
                    action: 'reacted with ❤️ to your Slip',
                    time: '15m ago',
                    target: 'Family Jar',
                    targetIcon: Icons.history_edu,
                    previewText: '"The best coffee in..."',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuD-2mwC-nkBaKo0fPFCocGu-mox8dHsxxQ-r-LAf8X5Su_yjmeXPs4GYdooQOd9mwCo4n0Tp0sLLxbBZcMYs6SvfQHMpinti9SABijlFCtvZpuahZL2tCAoeIIdSjvExe2OHRUQviItGRQ9PqLVfONhyx_SU_1L5vOg1muWNvjjYIs5b_zjUvTmP3xTIsQrv0CTEFn9x4bircuzuYwM2gj7PuUPnL0O0Jw_a9eNMK3r6i6YvD0zWzhHRT1zlVlozDetMKlQ7m5CwXgK',
                    reactionIcon: Icons.favorite,
                    reactionColor: Colors.red,
                    isUnread: true,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('YESTERDAY'),
                  const SizedBox(height: 12),
                  _buildCommentCard(
                    context,
                    name: 'Ngọc',
                    action: 'commented on your Slip',
                    time: '1d ago',
                    target: "Beach Trip '23",
                    targetIcon: Icons.beach_access,
                    comment:
                        '"This reminds me of when we went to the beach last summer!"',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBu9xVi01Ho2_VQU3TeD0zmp2sIZbFo1qUh1dWBZBmxsOQA0CCvCqgLyO4p6e7dhI0frHdzq_SJc-AeXX3B6E22DdPo9MEHhPNUmX2pLGlw9MAQZKDU5cwFvpsSHf63RE9FGCBK4cV_RORCh2M33HIwqxKUtEtC2rI4ajD7gwTd7G3SerjvKe7tOWMoolbIchtGIkkv87QaS0STICq8qAs452_2O6Iz7lNzTiqJeVxBOZSj6qbTYpu4Y-h7-U7rQpdhDCZwv8HXaxLX',
                    thumbnailUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBeKEX5S-No4enoa6KJM4bUfTWugLQoCzrvHCi_yVfellZak2TIbP5v-QE3wP3ZiIQbMA8CLrIk3hoaQlK8Ua5Lher7OHvpGcmBpnivLFgy-oHSR9A9nnn_ZXoMPNE4w7lrjM57pOjwPFckJ9PG6Tuv83P7K2_SxdQ7ZeHRG6-RaY7-R2V_Xba3iDcjIfZ4FURuCy8uqkHuUO_pBTWUItFZF9J-bpR1yNoLfd_Ob8bDv9tLJH3vCFecsB4WQv7oFGU_Xf_SaQ03bgM0',
                    isUnread: false,
                  ),
                  const SizedBox(height: 12),
                  _buildStackedReactionCard(
                    context,
                    name: 'Mike and 3 others',
                    action: 'liked your Slip',
                    time: '1d ago',
                    target: 'Coffee Lovers',
                    targetIcon: Icons.local_cafe,
                    previewText: '"Morning brew ritual..."',
                    isUnread: false,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "You're all caught up!",
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String value, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? theme.colorScheme.primary : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? const Color(0xFFC9AD92) : Colors.grey[500]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFC9AD92) : Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInviteCard(
    BuildContext context, {
    required String name,
    required String action,
    required String target,
    required IconData targetIcon,
    required String time,
    required String description,
    required String imageUrl,
    bool isUnread = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border(
                left: BorderSide(color: theme.colorScheme.primary, width: 4),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 20,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? appTheme.surface : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.mail,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[100]
                                    : Colors.blueGrey[900],
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(
                                  text: name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: ' $action '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? theme.colorScheme.primary
                                                .withOpacity(0.2)
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          targetIcon,
                                          size: 12,
                                          color: isDark
                                              ? Colors.orange[200]
                                              : Colors.orange[800],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          target,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.orange[200]
                                                : Colors.orange[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? theme
                                  .extension<AppThemeExtension>()!
                                  .textSecondary
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Actions
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionCard(
    BuildContext context, {
    required String name,
    required String action,
    required String time,
    required String target,
    required IconData targetIcon,
    required String previewText,
    required String imageUrl,
    required IconData reactionIcon,
    required Color reactionColor,
    bool isUnread = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border(
                left: BorderSide(color: theme.colorScheme.primary, width: 4),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 20),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: reactionColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? appTheme.surface : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(reactionIcon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[100]
                                : Colors.blueGrey[900],
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' $action'),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            targetIcon,
                            size: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            target,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(
    BuildContext context, {
    required String name,
    required String action,
    required String time,
    required String target,
    required IconData targetIcon,
    required String comment,
    required String imageUrl,
    required String thumbnailUrl,
    bool isUnread = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isUnread ? 1.0 : 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.grey[300], // Fallback
                radius: 20,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? appTheme.surface : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.blueGrey[700],
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.blueGrey[900],
                              ),
                            ),
                            TextSpan(text: ' $action'),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          comment,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[100]
                                : Colors.blueGrey[900],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        targetIcon,
                        size: 12,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        target,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
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
    );
  }

  Widget _buildStackedReactionCard(
    BuildContext context, {
    required String name,
    required String action,
    required String time,
    required String target,
    required IconData targetIcon,
    required String previewText,
    bool isUnread = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(isUnread ? 1.0 : 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stacked Avatars
          SizedBox(
            width: 50, // Slightly wider to accommodate stack
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 14,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfi2MnCEdYBz4LDboshrUrDRZrjOAznGuhyxCQmtGtaL9hUcBYqFdp-QuRyDq8RSHUb-8jxAJYbrjNfMXqB0pHgc6kHsIbwfi-4ZdptHUBynoEV5QlDrfrMuPYqAcedhMzo4URyntc6xTEg8MZCUP4PMcnnSy7tFVK6j0qpyWHSk4_qOKOXPzvsBwWWOY2YX1OBMJ8mannc7h0uP32c8raovEAXTL0iSqIWN8moTa54up026zOBo8oFpxheflsUIfZqYetY_H1zt5B',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: isDark ? appTheme.surface : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCAfAFmGWLEA0G9fFH3y6QXJgujjjQkEURUyZ5Xe1vfPfBTMNsPMYBfQ5JbBoPwbf8l5iKQpZnL7Bb_JqlCYjr3BLFoW-1JRR100bwqrcZ2EWR2HZfOH-dR7FvWvg6hJ985wVFdWWjW32iAq1e1AxqnNk-xQXum6JQVd8D-yyjSxhssrA7Ag28v5vdrIySXLiVSvh_5NUMl3FPNqkg7111HpOnMhlLjFOdY6yRBRUEhBdPuOrM0O-5DSPXtqFX0pmiEaQEV2_9FXVdJ',
                      ),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: isDark ? appTheme.surface : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? appTheme.surface : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.thumb_up,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.blueGrey[700],
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.blueGrey[900],
                              ),
                            ),
                            TextSpan(text: ' $action'),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            targetIcon,
                            size: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            target,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
