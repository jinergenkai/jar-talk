import 'package:flutter/material.dart';

import 'package:jar_talk/controllers/profile_controller.dart';
import 'package:jar_talk/screens/profile/widgets/section_header.dart'; // Import custom widgets if not exporting

class MembersSection extends StatelessWidget {
  const MembersSection({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD47311);
    const textSecondary = Color(0xFFC9AD92);
    const surfaceLight = Colors.white;
    const woodAccent = Color(0xFF483623);

    return Column(
      children: [
        const SectionHeader(title: 'Members'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
          ),
          child: Column(
            children: [
              // Invite Button
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invite New Member',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Share link or add from contacts',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: textSecondary),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              // Members List
              ...controller.members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: woodAccent),
                                  image: DecorationImage(
                                    image: NetworkImage(member['avatarUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (member['isAdmin'])
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF2C241B),
                                      ),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              member['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!member['isAdmin'])
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => controller.removeMember(index),
                            ),
                        ],
                      ),
                    ),
                    if (index < controller.members.length - 1)
                      const Divider(height: 1, color: Colors.black12),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
