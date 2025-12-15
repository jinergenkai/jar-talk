import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "Invite Created!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      invite['invite_code'] ?? 'CODE',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        _copyToClipboard(invite['invite_link'] ?? '');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Use this code or link to invite members.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: appTheme.woodLight.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        color: appTheme.woodDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Invites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appTheme.woodDark,
                        fontFamily: 'Noto Serif',
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _createInvite,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Create"),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_invites.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                "No active invites. Create one to invite friends!",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _invites.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final invite = _invites[index];
                return ListTile(
                  title: Text(
                    invite['invite_code'] ?? 'UNK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  subtitle: Text("Expires: ${invite['expires_at'] ?? 'Never'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () =>
                            _copyToClipboard(invite['invite_link'] ?? ''),
                        color: Colors.grey,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deactivateInvite(invite['invite_id']),
                        color: Colors.red[300],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
