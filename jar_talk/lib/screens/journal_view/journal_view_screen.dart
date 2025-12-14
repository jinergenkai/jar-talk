import 'package:flutter/material.dart';
import 'package:jar_talk/screens/journal_view/widgets/journal_entry_card.dart';
import 'package:jar_talk/screens/journal_view/widgets/timeline_entry.dart';
import 'package:jar_talk/screens/new_entry/new_entry_screen.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/slip_controller.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date helper
    String _formatDate(DateTime date) {
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
      body: CustomScrollView(
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
                icon: const Icon(Icons.refresh),
                color: const Color(0xFFC9AD92),
                onPressed: () => controller.fetchSlips(widget.jarId),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: const Color(0xFFC9AD92),
                onPressed: () {},
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
                    // Avatar Row (Static for now, user logic complex)
                    Row(
                      children: [
                        _buildAvatarStack(),
                        const SizedBox(width: 12),
                        const Text(
                          'Shared Journal',
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

                  return TimelineEntry(
                    isLast: index == controller.slips.length - 1,
                    child: JournalEntryCard(
                      date: _formatDate(slip.createdAt),
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
                          Text(
                            slip.textContent,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  );
                }, childCount: controller.slips.length),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      height: 40,
      width: 40 + (24.0 * 3),
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

  Widget _buildFooter() {
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
                '3 Comments',
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
                '12',
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
