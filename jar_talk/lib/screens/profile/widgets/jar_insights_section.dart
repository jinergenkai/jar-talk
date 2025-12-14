import 'package:flutter/material.dart';
import 'package:jar_talk/screens/profile/widgets/section_header.dart';

class JarInsightsSection extends StatelessWidget {
  const JarInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD47311);
    const textSecondary = Color(0xFFC9AD92);
    const surfaceLight = Colors.white;
    const woodAccent = Color(0xFF483623);

    return Column(
      children: [
        const SectionHeader(title: 'Jar Insights'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.inventory_2,
                      '142',
                      'Total Slips',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.calendar_month,
                      "Oct '23",
                      'Date Started',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MOST ACTIVE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                              ),
                            ),
                            Text(
                              'Alice wrote 84 slips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: woodAccent),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCgYtUkiDzOWThusnSsQ_QnZpBqbLWDQccYgEFzS7V0WDVwN0toMo_nad6qfy7Z46RXAvx0zt-f0XxCkmwGAz7FJc6NmBOsF6USBMBSvf11GesCBWH9g9d189UinhZ8CEi0diUdFTq0J0hIAt2c0y0Robv51wA8ILWqtbtcbqqBLbhNG68y2hs1DHMWD-Ltzv5kW8rk3J6QS5vcjy1riOledp52xj0yLNWuJmqQ10SRXgEO72ZeELPqjyelNMScIK2Qp5JDO6d2dSR_',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: const Color(0xFFD47311))],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFC9AD92)),
          ),
        ],
      ),
    );
  }
}
