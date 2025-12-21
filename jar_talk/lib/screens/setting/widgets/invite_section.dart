import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jar_talk/screens/setting/widgets/section_header.dart';
import 'package:jar_talk/services/invite_service.dart';
import 'package:jar_talk/utils/app_theme.dart';

class InviteSection extends StatefulWidget {
  final int jarId;
  const InviteSection({super.key, required this.jarId});

  @override
  State<InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends State<InviteSection> {
  final _inviteService = Get.put(InviteService());
  bool _isLoading = false;
  List<Map<String, dynamic>> _invites = [];

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    setState(() => _isLoading = true);
    try {
      final invites = await _inviteService.getContainerInvites(widget.jarId);
      setState(() => _invites = invites);
    } catch (e) {
      Get.snackbar("Error", "Failed to load invites: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createInvite() async {
    try {
      final newInvite = await _inviteService.createInvite(
        containerId: widget.jarId,
        expiresInHours: 24,
        maxUses: 10,
      );

      _loadInvites();

      if (mounted) {
        _showInviteCreatedDialog(newInvite);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create invite: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showInviteCreatedDialog(Map<String, dynamic> invite) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Invite Created!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Share this code or link to invite friends.",
                textAlign: TextAlign.center,
                style: TextStyle(color: appTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      invite['invite_code'] ?? 'CODE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        _copyToClipboard(invite['invite_link'] ?? '');
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deactivateInvite(int inviteId) async {
    try {
      await _inviteService.deactivateInvite(inviteId);
      _loadInvites();
      Get.snackbar("Success", "Invite Deactivated");
    } catch (e) {
      Get.snackbar("Error", "Failed to deactivate invite: $e");
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar("Copied", "Invite link copied to clipboard");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Column(
      children: [
        const SectionHeader(title: 'Invites'),
        _buildSectionContainer(
          theme,
          children: [
            _buildSettingsTile(
              theme: theme,
              icon: Icons.add_link,
              iconColor: Colors.blue.shade600,
              iconBgColor: Colors.blue.shade100,
              title: 'Create New Invite',
              onTap: _createInvite,
              showChevron: true,
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_isLoading && _invites.isNotEmpty)
              ..._invites.map((invite) {
                String expiryText = 'Never';
                if (invite['expires_at'] != null) {
                  try {
                    final date = DateTime.parse(invite['expires_at']);
                    expiryText = 'Exp: ${DateFormat.yMMMd().format(date)}';
                  } catch (e) {
                    expiryText = 'Exp: ${invite['expires_at']}';
                  }
                }
                return Column(
                  children: [
                    _buildDivider(theme),
                    _buildInviteTile(
                      theme,
                      invite: invite,
                      expiryText: expiryText,
                    ),
                  ],
                );
              }),
            if (!_isLoading && _invites.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    "No active invites",
                    style: TextStyle(color: appTheme.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Consistent Helper Widgets matching UserProfileScreen

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

  Widget _buildInviteTile(
    ThemeData theme, {
    required Map<String, dynamic> invite,
    required String expiryText,
  }) {
    final appTheme = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.purple.shade900 : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.qr_code,
                color: Colors.purple.shade600,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invite['invite_code'] ?? 'CODE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryText,
                    style: TextStyle(
                      fontSize: 12,
                      color: appTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () =>
                      _copyToClipboard(invite['invite_link'] ?? ''),
                  color: Colors.grey,
                  tooltip: 'Copy Link',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deactivateInvite(invite['invite_id']),
                  color: Colors.red.shade400,
                  tooltip: 'Deactivate',
                ),
              ],
            ),
          ],
        ),
      ),
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
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconBg = isDark ? iconColor.withOpacity(0.2) : iconBgColor;
    final effectiveIconColor = isDark ? iconColor.withOpacity(0.9) : iconColor;

    return Material(
      // ... (current implementation of _buildSettingsTile continues same as before)
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
                    fontSize: 12,
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
      indent: 56,
      color: theme.dividerColor.withOpacity(0.1),
    );
  }
}
