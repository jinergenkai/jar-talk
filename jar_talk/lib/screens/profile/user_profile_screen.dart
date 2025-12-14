import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/app_controller.dart';
import 'package:jar_talk/utils/app_theme.dart';
import 'package:jar_talk/controllers/auth_controller.dart'
    as jar_talk; // Use alias to avoid conflicts

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
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: Center(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(appController, theme, appTheme),

            // Sections
            _buildSectionHeader('Account & Security', theme),
            _buildAccountSection(theme, appTheme),

            _buildSectionHeader('App Preferences', theme),
            _buildAppPreferencesSection(appController, theme, appTheme),

            _buildSectionHeader('Data & Privacy', theme),
            _buildDataPrivacySection(theme, appTheme),

            _buildSectionHeader('Support', theme),
            _buildSupportSection(theme, appTheme),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _buildLogoutButton(theme, appTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    AppController controller,
    ThemeData theme,
    AppThemeExtension appTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Obx(() {
        final userInfo = controller.userInfo;
        final avatarUrl = userInfo['avatarUrl'] as String?;
        final name = userInfo['name'] as String? ?? 'User';
        final email = userInfo['email'] as String? ?? 'user@glassjar.app';

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: appTheme.textSecondary,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16 + 8, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: theme.extension<AppThemeExtension>()!.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAccountSection(ThemeData theme, AppThemeExtension appTheme) {
    return _buildSectionContainer(
      theme,
      children: [
        _buildSettingsTile(
          theme: theme,
          icon: Icons.lock_outline,
          iconColor: Colors.blue.shade600,
          iconBgColor: Colors.blue.shade100, // Or shade900 with opacity in dark
          title: 'Change Password',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.mail_outline,
          iconColor: Colors.purple.shade600,
          iconBgColor: Colors.purple.shade100,
          title: 'Email Preferences',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.delete_forever_outlined,
          iconColor: Colors.red.shade600,
          iconBgColor: Colors.red.shade100,
          title: 'Delete Account',
          titleColor: Colors.red.shade600,
          showChevron: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(
    AppController controller,
    ThemeData theme,
    AppThemeExtension appTheme,
  ) {
    return _buildSectionContainer(
      theme,
      children: [
        Obx(() {
          final isDark = controller.currentThemeType == AppThemeType.bruno;
          return _buildSettingsTile(
            theme: theme,
            icon: Icons.dark_mode_outlined,
            iconColor: Colors.orange.shade600,
            iconBgColor: Colors.orange.shade100,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (value) {
                controller.switchTheme(
                  value ? AppThemeType.bruno : AppThemeType.patel,
                );
              },
              activeColor: theme.primaryColor,
            ),
            onTap: () => controller.switchTheme(
              isDark ? AppThemeType.patel : AppThemeType.bruno,
            ),
          );
        }),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.notifications_outlined,
          iconColor: Colors.pink.shade600,
          iconBgColor: Colors.pink.shade100,
          title: 'Notifications',
          value: 'On',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.grid_view,
          iconColor: Colors.teal.shade600,
          iconBgColor: Colors.teal.shade100,
          title: 'Default Jar View',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Grid',
                style: TextStyle(fontSize: 14, color: appTheme.textSecondary),
              ),
              const SizedBox(width: 4),
              Icon(Icons.unfold_more, size: 20, color: Colors.grey.shade400),
            ],
          ),
          showChevron: false,
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.language,
          iconColor: Colors.indigo.shade600,
          iconBgColor: Colors.indigo.shade100,
          title: 'Language',
          value: 'English',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection(ThemeData theme, AppThemeExtension appTheme) {
    return _buildSectionContainer(
      theme,
      children: [
        _buildSettingsTile(
          theme: theme,
          icon: Icons.download_outlined,
          iconColor: Colors.green.shade600,
          iconBgColor: Colors.green.shade100,
          title: 'Download All Data',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.policy_outlined,
          iconColor: Colors.grey.shade700,
          iconBgColor: Colors.grey.shade200,
          title: 'Privacy Policy & Terms',
          trailing: Icon(
            Icons.open_in_new,
            size: 20,
            color: Colors.grey.shade400,
          ),
          showChevron: false,
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.dataset_outlined,
          iconColor: Colors.amber.shade700,
          iconBgColor: Colors.amber.shade100,
          title: 'Data Usage Consent',
          trailing: Switch.adaptive(
            value: false,
            onChanged: (value) {},
            activeColor: theme.primaryColor,
          ),
          showChevron: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSection(ThemeData theme, AppThemeExtension appTheme) {
    return _buildSectionContainer(
      theme,
      children: [
        _buildSettingsTile(
          theme: theme,
          icon: Icons.help_outline,
          iconColor: Colors.cyan.shade600,
          iconBgColor: Colors.cyan.shade100,
          title: 'Help Center / FAQ',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.support_agent,
          iconColor: Colors.redAccent.shade400, // rose-600 approx
          iconBgColor: Colors.redAccent.shade100,
          title: 'Contact Support',
          onTap: () {},
        ),
        _buildDivider(theme),
        _buildSettingsTile(
          theme: theme,
          icon: Icons.info_outline,
          iconColor: Colors.grey.shade600,
          iconBgColor: Colors.grey.shade200,
          title: 'App Version',
          trailing: Text(
            'v1.0.2',
            style: TextStyle(fontSize: 14, color: appTheme.textSecondary),
          ),
          showChevron: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLogoutButton(ThemeData theme, AppThemeExtension appTheme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          try {
            jar_talk.AuthController.instance.signOut();
          } catch (e) {
            // Fallback if instance getter fails or not init
            Get.find<jar_talk.AuthController>().signOut();
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.withOpacity(0.2), // red-200
            ),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Log Out",
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionContainer(
    ThemeData theme, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    Color? titleColor,
    String? value,
    Widget? trailing,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    // Adjust colors for dark mode if needed (simple opacity fallback)
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconBg = isDark ? iconColor.withOpacity(0.2) : iconBgColor;
    final effectiveIconColor = isDark ? iconColor.withOpacity(0.9) : iconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: effectiveIconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.extension<AppThemeExtension>()!.textSecondary,
                  ),
                ),
              if (value != null && showChevron) const SizedBox(width: 8),
              if (trailing != null) trailing,
              if (trailing == null && showChevron)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56, // Align with text start (16 padding + 32 icon + 12 gap)
      color: theme.dividerColor.withOpacity(0.1),
    );
  }
}
