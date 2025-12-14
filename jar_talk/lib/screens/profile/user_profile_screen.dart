import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/app_controller.dart';
import 'package:jar_talk/utils/app_theme.dart';
import 'package:jar_talk/controllers/auth_controller.dart' as jar_talk;

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Section
            _buildAvatarSection(appController, theme, appTheme),
            const SizedBox(height: 32),

            // Theme Section
            _buildThemeSection(context, appController, theme, appTheme),

            const SizedBox(height: 32),

            // Logout Button
            _buildLogoutButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          // Find AuthController and sign out
          try {
            // For safety, though it should be registered
            Get.find<jar_talk.AuthController>().signOut();
          } catch (e) {
            // Handle if controller not found, maybe just navigate to login
            // but it should be there.
            // Using full path to avoid conflicts if imports are missing,
            // but better to import it at top.
            // Let's add the import and use AuthController.instance
            jar_talk.AuthController.instance.signOut();
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Log Out",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    AppController controller,
    ThemeData theme,
    AppThemeExtension appTheme,
  ) {
    return Obx(() {
      final userInfo = controller.userInfo;
      final avatarUrl = userInfo['avatarUrl'] as String?;
      final name = userInfo['name'] as String? ?? 'User';

      return Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.woodAccent, width: 2),
              image: avatarUrl != null && avatarUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildThemeSection(
    BuildContext context, // Add context
    AppController controller,
    ThemeData theme,
    AppThemeExtension appTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final currentType = controller.currentThemeType;

            return Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context: context, // Use passed context
                    label: 'Bruno',
                    color: const Color(0xFFD47311),
                    isSelected: currentType == AppThemeType.bruno,
                    onTap: () => controller.switchTheme(AppThemeType.bruno),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildThemeOption(
                    context: context, // Use passed context
                    label: 'Patel',
                    color: const Color(0xFF8EC5FC),
                    isSelected: currentType == AppThemeType.patel,
                    onTap: () => controller.switchTheme(AppThemeType.patel),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
