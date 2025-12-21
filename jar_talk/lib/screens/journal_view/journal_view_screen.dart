import 'package:flutter/material.dart';
import 'package:jar_talk/screens/journal_view/widgets/journal_entry_card.dart';
import 'package:jar_talk/screens/journal_view/widgets/timeline_entry.dart';
import 'package:jar_talk/screens/new_entry/new_entry_screen.dart';
import 'package:jar_talk/screens/journal_view/slip_detail_screen.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/slip_controller.dart';
import 'package:jar_talk/screens/setting/setting_screen.dart';

class JournalViewScreen extends StatefulWidget {
  final int jarId;
  final String jarName;

  const JournalViewScreen({
    super.key,
    required this.jarId,
    required this.jarName,
  });

  @override
  State<JournalViewScreen> createState() => _JournalViewScreenState();
}

class _JournalViewScreenState extends State<JournalViewScreen> {
  late SlipController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SlipController(), tag: 'jar_${widget.jarId}');
    controller.fetchSlips(widget.jarId);
    controller.fetchJarDetails(widget.jarId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date helper
    String formatDate(DateTime date) {
      // Simple formatter, can be improved with intl package
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
      final hour = date.hour > 12
          ? date.hour - 12
          : (date.hour == 0 ? 12 : date.hour);
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$month ${date.day} • $hour:$minute $ampm';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => NewEntryScreen(
                jarId: widget.jarId,
                controllerTag: 'jar_${widget.jarId}',
              ),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchSlips(widget.jarId);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Collapsing Header
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
              expandedHeight: 140.0,
              floating: true,
              pinned: false,
              snap: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFC9AD92),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.local_fire_department),
                  color: const Color(
                    0xFFC9AD92,
                  ), // Or a "fire" color like Colors.orange
                  tooltip: 'Streak',
                  onPressed: () {
                    // TODO: Implement Streak Screen
                    Get.snackbar(
                      "Streak",
                      "Streak functionality coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  color: const Color(0xFFC9AD92),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingScreen(
                          jarId: widget.jarId,
                          jarName: widget.jarName,
                        ),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                background: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.jarName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF0ECE6),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final jar = controller.currentJar.value;
                        final members = jar?.members ?? [];

                        return Row(
                          children: [
                            if (members.isNotEmpty) ...[
                              _buildAvatarStack(members),
                              const SizedBox(width: 12),
                            ],
                            if (members.length > 1)
                              const Text(
                                'Shared Journal',
                                style: TextStyle(
                                  color: Color(0xFFC9AD92),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Timeline List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              sliver: Obx(() {
                if (controller.isLoading.value && controller.slips.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.slips.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No slips yet. Add one!")),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final slip = controller.slips[index];
                    // Cycle rotations for visual variety: 1, -1, 2, 0
                    final rotations = [1, -1, 2, 0];
                    final rotation = rotations[index % rotations.length];

                    return AnimatedEntry(
                      index: index,
                      child: TimelineEntry(
                        isLast: index == controller.slips.length - 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SlipDetailScreen(slip: slip),
                              ),
                            );
                          },
                          child: JournalEntryCard(
                            date: formatDate(slip.createdAt),
                            rotation: rotation.toDouble(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAuthorRow(
                                  slip.authorUsername ?? 'Unknown',
                                  slip.authorEmail != null
                                      ? 'https://ui-avatars.com/api/?name=${slip.authorUsername}&background=random' // Fallback avatar
                                      : 'https://i.pravatar.cc/100?img=${(slip.authorId % 70) + 1}',
                                ),
                                const SizedBox(height: 12),
                                if (slip.title != null) ...[
                                  Text(
                                    slip.title!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (slip.media != null &&
                                    slip.media!.isNotEmpty) ...[
                                  for (var media in slip.media!)
                                    if (media.mediaType == 'image')
                                      Container(
                                        height:
                                            140, // Reduced height as requested
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              media.downloadUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                ],
                                Text(
                                  slip.textContent,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                _buildFooter(slip),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: controller.slips.length),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<dynamic> members) {
    // Expect List<Member> but using dynamic to avoid tight coupling if import missing,
    // though ideally should import Member. Assuming import is there implicitly or via part.
    // Actually, I should use Member type, but I haven't imported JarModel here explicitly?
    // Wait, JarModel is where Member is. Let's assume it's available via controller usage or add import.
    // I will use 'dynamic' for safety in replacement block unless I verify imports.
    // Ah, I see I already edited JarModel.

    final displayMembers = members.take(3).toList();
    final remainingCount = members.length - 3;

    return SizedBox(
      height: 36,
      width:
          40.0 +
          (24.0 * (displayMembers.isEmpty ? 0 : displayMembers.length - 1)) +
          (remainingCount > 0 ? 24.0 : 0),
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            _buildAvatar(
              i,
              displayMembers[i].profilePictureUrl ??
                  'https://ui-avatars.com/api/?name=${displayMembers[i].username}&background=random',
            ),

          if (remainingCount > 0)
            Positioned(
              left:
                  24.0 *
                  members.take(3).length, // Position after the last avatar
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF483623),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF221910), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
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

  Widget _buildAuthorRow(String name, String url) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(url),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFooter(slip) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${slip.commentCount} ${slip.commentCount == 1 ? "Comment" : "Comments"}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${slip.reactionCount}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedEntry({super.key, required this.child, required this.index});

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final delay = (widget.index % 5) * 50;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
