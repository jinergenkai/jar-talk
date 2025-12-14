import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/profile_controller.dart';
import 'package:jar_talk/screens/profile/widgets/section_header.dart';

class PermissionsSection extends StatelessWidget {
  const PermissionsSection({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    const surfaceLight = Colors.white;

    return Column(
      children: [
        const SectionHeader(title: 'Privacy & Permissions'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
          ),
          child: Column(
            children: [
              Obx(
                () => _buildToggleRow(
                  'Allow members to invite',
                  controller.allowInvite.value,
                  controller.toggleInvite,
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              Obx(
                () => _buildToggleRow(
                  'Only Admin can delete slips',
                  controller.adminOnlyDelete.value,
                  controller.toggleAdminDelete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD47311),
            activeTrackColor: const Color(0xFFD47311),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
