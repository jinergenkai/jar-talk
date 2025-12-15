import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/setting_controller.dart';
import 'package:jar_talk/screens/setting/widgets/appearance_section.dart';
import 'package:jar_talk/screens/setting/widgets/jar_identity_card.dart';
import 'package:jar_talk/screens/setting/widgets/jar_insights_section.dart';
import 'package:jar_talk/screens/setting/widgets/members_section.dart';
import 'package:jar_talk/screens/setting/widgets/permissions_section.dart';
import 'package:jar_talk/screens/setting/widgets/profile_header.dart';
import 'package:jar_talk/screens/setting/widgets/invite_section.dart';

class SettingScreen extends StatelessWidget {
  final int jarId;
  final String jarName;

  const SettingScreen({super.key, required this.jarId, required this.jarName});

  @override
  Widget build(BuildContext context) {
    // Initializing controller with specific tag to separate different jars if needed
    // For now we can just put it. If we want unique controllers per jar settings, we use tag.
    final controller = Get.put(ProfileController(), tag: 'settings_$jarId');

    // Initialize with passed data
    controller.jarName.value = jarName;

    const bgLight = Color(0xFFF8F7F6);

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      JarIdentityCard(controller: controller),
                      MembersSection(controller: controller),
                      const SizedBox(height: 24),
                      InviteSection(jarId: jarId),
                      const SizedBox(height: 24),
                      AppearanceSection(controller: controller),
                      const SizedBox(height: 24),
                      PermissionsSection(controller: controller),
                      const SizedBox(height: 24),
                      const JarInsightsSection(),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: controller.archiveJar,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.05,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Archive Jar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
