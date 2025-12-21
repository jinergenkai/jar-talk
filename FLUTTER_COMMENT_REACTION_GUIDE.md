# Flutter Comment & Reaction Implementation Guide

## ✅ Files Created

```
lib/
├── models/
│   ├── comment_model.dart      ✅ Created (Comment, CommentPreview)
│   ├── reaction_model.dart     ✅ Created (Reaction, ReactionPreview, ReactionSummary)
│   └── slip_model.dart         ✅ Updated (added comments, reactions fields)
└── services/
    └── comment_reaction_service.dart  ✅ Created
```

## 📋 Next Steps: Update SlipController

Update `lib/controllers/slip_controller.dart`:

```dart
import '../services/comment_reaction_service.dart';
import '../models/comment_model.dart';
import '../models/reaction_model.dart';

class SlipController extends GetxController {
  final SlipService _slipService = SlipService();
  final JarService _jarService = JarService();
  final MediaService _mediaService = MediaService();
  final CommentReactionService _commentReactionService = CommentReactionService(); // ADD THIS

  // Existing observables...
  final RxList<Slip> slips = <Slip>[].obs;

  // ADD THESE NEW OBSERVABLES
  final RxList<Comment> currentSlipComments = <Comment>[].obs;
  final RxList<ReactionSummary> currentSlipReactions = <ReactionSummary>[].obs;
  final RxBool commentsLoading = false.obs;
  final RxBool reactionsLoading = false.obs;
  final RxString commentError = ''.obs;

  // ADD THIS METHOD - Fetch comments for a slip
  Future<void> fetchCommentsForSlip(int slipId) async {
    try {
      commentsLoading.value = true;
      commentError.value = '';

      final comments = await _commentReactionService.getCommentsForSlip(slipId);
      currentSlipComments.assignAll(comments);
    } catch (e) {
      commentError.value = 'Failed to load comments: $e';
      Get.snackbar('Error', 'Could not load comments');
    } finally {
      commentsLoading.value = false;
    }
  }

  // ADD THIS METHOD - Create a comment
  Future<bool> addComment(int slipId, String textContent) async {
    if (textContent.trim().isEmpty) {
      Get.snackbar('Error', 'Comment cannot be empty');
      return false;
    }

    try {
      final newComment = await _commentReactionService.createComment(slipId, textContent);

      // Add to list
      currentSlipComments.insert(0, newComment);

      // Update slip's comment count in the slips list
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        final updatedSlip = Slip(
          id: slips[slipIndex].id,
          containerId: slips[slipIndex].containerId,
          authorId: slips[slipIndex].authorId,
          title: slips[slipIndex].title,
          emotion: slips[slipIndex].emotion,
          textContent: slips[slipIndex].textContent,
          createdAt: slips[slipIndex].createdAt,
          locationData: slips[slipIndex].locationData,
          authorUsername: slips[slipIndex].authorUsername,
          authorEmail: slips[slipIndex].authorEmail,
          authorProfilePicture: slips[slipIndex].authorProfilePicture,
          media: slips[slipIndex].media,
          comments: slips[slipIndex].comments,
          commentCount: slips[slipIndex].commentCount + 1,
          reactions: slips[slipIndex].reactions,
          reactionCount: slips[slipIndex].reactionCount,
        );
        slips[slipIndex] = updatedSlip;
      }

      Get.snackbar('Success', 'Comment added');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e');
      return false;
    }
  }

  // ADD THIS METHOD - Delete a comment
  Future<bool> deleteComment(int commentId, int slipId) async {
    try {
      await _commentReactionService.deleteComment(commentId);

      // Remove from list
      currentSlipComments.removeWhere((c) => c.commentId == commentId);

      // Update slip's comment count
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        final updatedSlip = Slip(
          id: slips[slipIndex].id,
          containerId: slips[slipIndex].containerId,
          authorId: slips[slipIndex].authorId,
          title: slips[slipIndex].title,
          emotion: slips[slipIndex].emotion,
          textContent: slips[slipIndex].textContent,
          createdAt: slips[slipIndex].createdAt,
          locationData: slips[slipIndex].locationData,
          authorUsername: slips[slipIndex].authorUsername,
          authorEmail: slips[slipIndex].authorEmail,
          authorProfilePicture: slips[slipIndex].authorProfilePicture,
          media: slips[slipIndex].media,
          comments: slips[slipIndex].comments,
          commentCount: slips[slipIndex].commentCount - 1,
          reactions: slips[slipIndex].reactions,
          reactionCount: slips[slipIndex].reactionCount,
        );
        slips[slipIndex] = updatedSlip;
      }

      Get.snackbar('Success', 'Comment deleted');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment: $e');
      return false;
    }
  }

  // ADD THIS METHOD - Fetch reaction summary
  Future<void> fetchReactionSummary(int slipId) async {
    try {
      reactionsLoading.value = true;

      final reactions = await _commentReactionService.getReactionSummary(slipId);
      currentSlipReactions.assignAll(reactions);
    } catch (e) {
      Get.snackbar('Error', 'Could not load reactions');
    } finally {
      reactionsLoading.value = false;
    }
  }

  // ADD THIS METHOD - Toggle reaction
  Future<void> toggleReaction(int slipId, String reactionType) async {
    try {
      final result = await _commentReactionService.toggleReaction(slipId, reactionType);

      // Refresh reactions
      await fetchReactionSummary(slipId);

      // Update slip in list
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        // Re-fetch slip to get updated reaction counts
        await fetchSlips(slips[slipIndex].containerId);
      }

      final action = result['action'] as String;
      if (action == 'added') {
        Get.snackbar('', 'Reaction added', duration: Duration(seconds: 1));
      } else if (action == 'removed') {
        Get.snackbar('', 'Reaction removed', duration: Duration(seconds: 1));
      } else {
        Get.snackbar('', 'Reaction updated', duration: Duration(seconds: 1));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle reaction: $e');
    }
  }
}
```

## 🎨 UI Implementation in SlipDetailScreen

Update `lib/screens/journal_view/slip_detail_screen.dart`:

### 1. Initialize Controller in State

```dart
class _SlipDetailScreenState extends State<SlipDetailScreen> {
  late SlipController controller;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SlipController>(tag: 'jar_${widget.slip.containerId}');
    commentController = TextEditingController();

    // Load comments and reactions when screen opens
    controller.fetchCommentsForSlip(widget.slip.id);
    controller.fetchReactionSummary(widget.slip.id);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // ... rest of the code
}
```

### 2. Replace Comment Section (lines 274-399)

Replace the placeholder comment section with:

```dart
// COMMENT SECTION
Container(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Reactions Row
      Obx(() {
        if (controller.currentSlipReactions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: 8,
          children: controller.currentSlipReactions.map((reaction) {
            return Chip(
              avatar: Text(_getReactionEmoji(reaction.reactionType)),
              label: Text('${reaction.count}'),
              backgroundColor: Colors.blue.withOpacity(0.1),
            );
          }).toList(),
        );
      }),

      const SizedBox(height: 12),

      // Reaction Buttons
      Row(
        children: [
          _buildReactionButton('❤️', 'Heart'),
          const SizedBox(width: 8),
          _buildReactionButton('🔥', 'Fire'),
          const SizedBox(width: 8),
          _buildReactionButton('✨', 'Resonate'),
          const SizedBox(width: 8),
          _buildReactionButton('👍', 'Like'),
        ],
      ),

      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 16),

      // Comments Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
            'Comments (${widget.slip.commentCount})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      ),

      const SizedBox(height: 12),

      // Comment Input
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              final text = commentController.text.trim();
              if (text.isNotEmpty) {
                final success = await controller.addComment(widget.slip.id, text);
                if (success) {
                  commentController.clear();
                }
              }
            },
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),

      const SizedBox(height: 16),

      // Comments List
      Obx(() {
        if (controller.commentsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentSlipComments.isEmpty) {
          return const Center(
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: controller.currentSlipComments.map((comment) {
            return _buildCommentItem(comment);
          }).toList(),
        );
      }),
    ],
  ),
)
```

### 3. Add Helper Methods

```dart
// Get emoji for reaction type
String _getReactionEmoji(String type) {
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

// Build reaction button
Widget _buildReactionButton(String emoji, String reactionType) {
  return InkWell(
    onTap: () {
      controller.toggleReaction(widget.slip.id, reactionType);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
}

// Build comment item
Widget _buildCommentItem(Comment comment) {
  final currentUserId = Get.find<AppController>().userInfo['user_id'] as int?;
  final isAuthor = currentUserId == comment.authorId;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: comment.authorProfilePicture != null
              ? NetworkImage(comment.authorProfilePicture!)
              : null,
          child: comment.authorProfilePicture == null
              ? Text(comment.authorUsername?[0].toUpperCase() ?? 'U')
              : null,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCommentTime(comment.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.textContent,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        // Delete button (only for comment author)
        if (isAuthor)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.red.shade300,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Comment'),
                  content: const Text('Are you sure you want to delete this comment?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await controller.deleteComment(comment.commentId, widget.slip.id);
              }
            },
          ),
      ],
    ),
  );
}

// Format comment time (e.g., "2m ago", "1h ago", "3d ago")
String _formatCommentTime(DateTime dateTime) {
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
```

## 🎯 Testing Checklist

- [ ] Run backend migration: `python run_migration.py`
- [ ] Restart Flutter app to reload models
- [ ] Test adding a comment
- [ ] Test viewing all comments for a slip
- [ ] Test deleting own comment
- [ ] Test adding reaction (Heart, Fire, etc.)
- [ ] Test toggling same reaction (should remove)
- [ ] Test changing reaction type
- [ ] Verify comment count updates in slip list
- [ ] Verify reaction count updates
- [ ] Test with multiple users

## 📱 UI Preview

Slip Detail Screen will show:
```
┌─────────────────────────────────┐
│ Slip Title & Content           │
│ Media (if any)                 │
├─────────────────────────────────┤
│ ❤️ 5  🔥 3  ✨ 2              │ ← Reaction chips
│ ❤️ 🔥 ✨ 👍                    │ ← Reaction buttons
├─────────────────────────────────┤
│ Comments (12)                  │
│ ┌───────────────────────────┐  │
│ │ Add a comment...     [→]  │  │ ← Input field
│ └───────────────────────────┘  │
│                                │
│ 👤 John • 2m ago          [🗑]│
│    Nice post!                  │
│                                │
│ 👤 Jane • 1h ago               │
│    I love this!                │
└─────────────────────────────────┘
```

## 🔧 Troubleshooting

**Issue:** Comments not loading
- Check backend is running
- Check JWT token is valid
- Check slip_id is correct

**Issue:** Reactions not updating
- Check network response
- Verify reaction type matches backend ('Heart', 'Fire', etc.)
- Check user is member of container

**Issue:** Cannot delete comment
- Verify user is comment author or container admin
- Check backend permissions

## ✅ Complete!

After following this guide, your app will have:
- ✅ Full comment functionality (create, view, delete)
- ✅ Full reaction functionality (add, remove, change)
- ✅ Real-time updates in UI
- ✅ Proper access control
- ✅ Clean architecture following existing patterns
