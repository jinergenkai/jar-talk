import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/profile_controller.dart';
import 'package:jar_talk/screens/profile/widgets/appearance_section.dart';
import 'package:jar_talk/screens/profile/widgets/jar_identity_card.dart';
import 'package:jar_talk/screens/profile/widgets/jar_insights_section.dart';
import 'package:jar_talk/screens/profile/widgets/members_section.dart';
import 'package:jar_talk/screens/profile/widgets/permissions_section.dart';
import 'package:jar_talk/screens/profile/widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

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
                              backgroundColor: Colors.red.withOpacity(0.05),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.3),
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
