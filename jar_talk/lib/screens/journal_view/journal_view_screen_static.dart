import 'package:flutter/material.dart';
import 'package:jar_talk/screens/journal_view/widgets/journal_entry_card.dart';
import 'package:jar_talk/screens/journal_view/widgets/timeline_entry.dart';
import 'package:jar_talk/screens/new_entry/new_entry_screen.dart';
import 'package:get/get.dart'; // Re-adding Get for state management if needed elsewhere, but using Navigator for nav

class JournalViewScreen extends StatelessWidget {
  const JournalViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) =>
                  const NewEntryScreen(jarId: 0, controllerTag: ""),
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
                icon: const Icon(Icons.settings),
                color: const Color(0xFFC9AD92),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              // We'll put the details in the background so they scroll nicely
              background: Padding(
                padding: const EdgeInsets.only(
                  top: 80,
                  left: 24,
                  right: 24,
                ), // Avoid overlap with leading/actions
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip to Japan 2023',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF0ECE6),
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
            ),
          ),

          // Timeline List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ENTRY 1: Ramen Shop (Photo)
                TimelineEntry(
                  child: JournalEntryCard(
                    date: 'OCT 24 • 10:30 AM',
                    rotation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAuthorRow(
                          'Sarah Jenkins',
                          'https://i.pravatar.cc/100?img=5',
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Found this amazing ramen shop in Shinjuku!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1569937745357-da811b87c5ed?auto=format&fit=crop&q=80&w=600',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Shinjuku',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Best broth I've ever had. The chashu simply melts in your mouth. We definitely need to come back here before we leave.",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),

                // ENTRY 2: Train Ticket
                TimelineEntry(
                  child: JournalEntryCard(
                    date: 'OCT 24 • 2:15 PM',
                    rotation: -1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAuthorRow(
                              'Mike Ross',
                              'https://i.pravatar.cc/100?img=11',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LOGISTICS',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.rotate(
                              angle: -2 * 3.14 / 180,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Icon(
                                  Icons.train,
                                  size: 32,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shinkansen Tickets',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Booked for tomorrow morning. 9:00 AM from Tokyo Station. Don't be late!",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ENTRY 3: Quote
                TimelineEntry(
                  child: JournalEntryCard(
                    date: 'OCT 25 • 9:00 AM',
                    rotation: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 40,
                            color: theme.colorScheme.primary.withOpacity(0.4),
                          ),
                          const Text(
                            '"Travel is the only thing you buy that makes you richer."',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Noto Serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/100?img=3',
                                ),
                                backgroundColor: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '— DAVID',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ENTRY 4: Map
                TimelineEntry(
                  isLast: true,
                  child: JournalEntryCard(
                    date: 'OCT 25 • 11:30 AM',
                    rotation: 0,
                    showPin: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Next Stop: Kyoto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.near_me, size: 16, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&q=80&w=600',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                color: const Color(0xFFEADDCF).withOpacity(0.2),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: theme.colorScheme.primary,
                                    size: 20,
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

                const SizedBox(height: 80),
              ]),
            ),
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
