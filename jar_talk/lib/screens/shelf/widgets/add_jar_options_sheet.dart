import 'package:flutter/material.dart';
import 'package:jar_talk/utils/app_theme.dart';

class AddJarOptionsSheet extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const AddJarOptionsSheet({
    super.key,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? appTheme.woodDark
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Journal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Noto Serif',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildOptionTile(
            context,
            icon: Icons.add_circle_outline_rounded,
            title: 'Create New Journal',
            subtitle: 'Start a fresh collection for yourself',
            onTap: () {
              Navigator.pop(context);
              onCreate();
            },
            theme: theme,
            appTheme: appTheme,
          ),
          const SizedBox(height: 16),
          _buildOptionTile(
            context,
            icon: Icons.group_add_outlined,
            title: 'Join Existing Journal',
            subtitle: 'Scan QR or use an invite link',
            onTap: () {
              Navigator.pop(context);
              onJoin();
            },
            theme: theme,
            appTheme: appTheme,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    required AppThemeExtension appTheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? appTheme.woodLight.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appTheme.woodAccent.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: appTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: appTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
