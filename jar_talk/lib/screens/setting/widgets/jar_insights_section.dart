import 'package:flutter/material.dart';
import 'package:jar_talk/screens/setting/widgets/section_header.dart';
import 'package:jar_talk/utils/app_theme.dart';

class JarInsightsSection extends StatelessWidget {
  const JarInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final appTheme = theme.extension<AppThemeExtension>()!;
    final textSecondary = appTheme.textSecondary;
    final surfaceLight = theme.cardColor;
    final woodAccent = appTheme.woodAccent;

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
                      context,
                      Icons.inventory_2,
                      '142',
                      'Total Slips',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
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
                            color: primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.emoji_events, color: primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Column(
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

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    // Note: This method needs context or colors passed to it. Assuming context is available or refactoring to pass it.
    // Since it's a separate method in a StatelessWidget, context isn't global.
    // Better to inline or pass colors.
    // Refactoring to pass colors.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: theme.colorScheme.primary)],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.extension<AppThemeExtension>()!.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
