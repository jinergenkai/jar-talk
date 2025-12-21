import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/slip_controller.dart';
import 'package:jar_talk/controllers/app_controller.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/models/comment_model.dart';
import 'package:jar_talk/models/reaction_model.dart';
import 'package:jar_talk/utils/app_theme.dart';

class SlipDetailScreen extends StatefulWidget {
  final Slip slip;

  const SlipDetailScreen({super.key, required this.slip});

  @override
  State<SlipDetailScreen> createState() => _SlipDetailScreenState();
}

class _SlipDetailScreenState extends State<SlipDetailScreen> {
  late SlipController controller;
  late TextEditingController commentController;
  bool showAllComments = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SlipController>(tag: 'jar_${widget.slip.containerId}');
    commentController = TextEditingController();

    // Load comments and reactions
    controller.fetchCommentsForSlip(widget.slip.id);
    controller.fetchReactionSummary(widget.slip.id);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  String formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String getReactionEmoji(String type) {
    switch (type) {
      case 'Heart':
        return '❤️';
      case 'Fire':
        return '🔥';
      case 'Resonate':
        return '✨';
      case 'Like':
        return '👍';
      default:
        return '👍';
    }
  }

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
                                          formatDate(widget.slip.createdAt),
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
                                if (widget.slip.media != null &&
                                    widget.slip.media!.isNotEmpty) ...[
                                  for (var media in widget.slip.media!)
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
                                  widget.slip.textContent,
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
                                            widget.slip.authorEmail != null
                                                ? 'https://ui-avatars.com/api/?name=${widget.slip.authorUsername}&background=random'
                                                : 'https://i.pravatar.cc/100?img=${(widget.slip.authorId % 70) + 1}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Written by ${widget.slip.authorUsername ?? "Unknown"}',
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
                          // Reactions Display
                          Obx(() {
                            if (controller.currentSlipReactions.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final totalReactions = controller.currentSlipReactions
                                .fold<int>(0, (sum, r) => sum + r.count);
                            final firstUsers = controller.currentSlipReactions
                                .expand((r) => r.users)
                                .take(2)
                                .toList();

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // User avatars
                                    Row(
                                      children: [
                                        if (firstUsers.isNotEmpty)
                                          for (var i = 0; i < firstUsers.length; i++)
                                            Container(
                                              width: 32,
                                              height: 32,
                                              transform: i > 0
                                                  ? Matrix4.translationValues(-8 * i.toDouble(), 0, 0)
                                                  : null,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                                border: Border.all(
                                                  color: theme.scaffoldBackgroundColor,
                                                  width: 2,
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: firstUsers[i].profilePicture != null
                                                    ? Image.network(
                                                        firstUsers[i].profilePicture!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Icon(
                                                          Icons.person,
                                                          size: 20,
                                                          color: Colors.grey,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size: 20,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            ),
                                        if (totalReactions > 2)
                                          Container(
                                            width: 32,
                                            height: 32,
                                            transform: Matrix4.translationValues(
                                              -8 * firstUsers.length.toDouble(),
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
                                                '+${totalReactions - 2}',
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
                                    // Reaction summary text
                                    Flexible(
                                      child: Text(
                                        firstUsers.isEmpty
                                            ? '$totalReactions ${totalReactions == 1 ? "reaction" : "reactions"}'
                                            : firstUsers.length == 1 && totalReactions == 1
                                                ? '${firstUsers[0].username} reacted'
                                                : firstUsers.length == 2 && totalReactions == 2
                                                    ? '${firstUsers[0].username} and ${firstUsers[1].username} reacted'
                                                    : '${firstUsers[0].username}, ${firstUsers.length > 1 ? firstUsers[1].username : ""} + ${totalReactions - 2} others reacted',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: appTheme.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }),

                          // Reaction Buttons
                          Row(
                            children: [
                              _buildReactionButton(theme, isDark, '❤️', 'Heart'),
                              const SizedBox(width: 8),
                              _buildReactionButton(theme, isDark, '🔥', 'Fire'),
                              const SizedBox(width: 8),
                              _buildReactionButton(theme, isDark, '✨', 'Resonate'),
                              const SizedBox(width: 8),
                              _buildReactionButton(theme, isDark, '👍', 'Like'),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Divider(color: appTheme.textSecondary.withOpacity(0.1)),
                          const SizedBox(height: 16),

                          // Comments Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Comments (${widget.slip.commentCount})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Comment Input Field
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
                                    controller: commentController,
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
                                        onPressed: () async {
                                          final text = commentController.text.trim();
                                          if (text.isNotEmpty) {
                                            final success = await controller.addComment(
                                              widget.slip.id,
                                              text,
                                            );
                                            if (success) {
                                              commentController.clear();
                                            }
                                          }
                                        },
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

                          const SizedBox(height: 16),

                          // Comments List
                          Obx(() {
                            if (controller.commentsLoading.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (controller.currentSlipComments.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    'No comments yet. Be the first!',
                                    style: TextStyle(
                                      color: appTheme.textSecondary.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final displayComments = showAllComments
                                ? controller.currentSlipComments
                                : controller.currentSlipComments.take(3).toList();

                            return Column(
                              children: [
                                ...displayComments.map((comment) {
                                  return _buildCommentItem(
                                    theme,
                                    appTheme,
                                    isDark,
                                    comment,
                                  );
                                }),
                                if (controller.currentSlipComments.length > 3)
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          showAllComments = !showAllComments;
                                        });
                                      },
                                      icon: Text(
                                        showAllComments
                                            ? 'Show less'
                                            : 'View all ${controller.currentSlipComments.length} comments',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: appTheme.textSecondary,
                                        ),
                                      ),
                                      label: Icon(
                                        showAllComments
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 16,
                                        color: appTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
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

  Widget _buildReactionButton(
    ThemeData theme,
    bool isDark,
    String emoji,
    String reactionType,
  ) {
    return InkWell(
      onTap: () {
        controller.toggleReaction(widget.slip.id, reactionType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildCommentItem(
    ThemeData theme,
    AppThemeExtension appTheme,
    bool isDark,
    Comment comment,
  ) {
    final currentUserId = Get.find<AppController>().userInfo['user_id'] as int?;
    final isAuthor = currentUserId == comment.authorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            child: ClipOval(
              child: comment.authorProfilePicture != null
                  ? Image.network(
                      comment.authorProfilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.grey,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorUsername ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: appTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCommentTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: appTheme.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.textContent,
                  style: TextStyle(
                    fontSize: 14,
                    color: appTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Delete button (only for comment author)
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red.shade300,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Comment'),
                    content: const Text(
                      'Are you sure you want to delete this comment?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await controller.deleteComment(
                    comment.commentId,
                    widget.slip.id,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
