import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/models/jar_model.dart'; // Ensure Member is imported
import 'package:jar_talk/models/jar_style.dart';
import 'package:jar_talk/services/jar_service.dart';

class SettingController extends GetxController {
  final int jarId;
  final JarService _jarService = JarService();

  SettingController({required this.jarId});

  // Jar Identity
  final RxString jarName = ''.obs;
  final Rx<DateTime> createdDate = DateTime.now().obs;

  // Appearance
  final RxString selectedShape = 'Mason'.obs;
  final RxInt selectedColorIndex = 0.obs;

  // Permissions
  final RxBool allowInvite = true.obs;
  final RxBool adminOnlyDelete = false.obs;

  // Members
  final RxList<Member> members = <Member>[].obs;

  final List<int> themeColors = [
    0xFFD47311, // Primary Orange
    0xFF5D4037, // Brown
    0xFF388E3C, // Green
    0xFF1976D2, // Blue
    0xFF7B1FA2, // Purple
  ];

  @override
  void onInit() {
    super.onInit();
    fetchJarDetails();
  }

  Future<void> fetchJarDetails() async {
    try {
      final jar = await _jarService.getJarDetails(jarId);
      jarName.value = jar.name;
      createdDate.value = jar.createdAt;

      if (jar.members != null) {
        members.assignAll(jar.members!);
      }

      if (jar.styleSettings != null && jar.styleSettings!.isNotEmpty) {
        final style = JarStyle.fromJson(jar.styleSettings!);
        selectedShape.value = style.shape;
        selectedColorIndex.value = style.colorIndex;
      }
    } catch (e) {
      debugPrint('Error fetching jar details: $e');
    }
  }

  void updateJarName(String name) {
    jarName.value = name;
  }

  void selectShape(String shape) {
    selectedShape.value = shape;
    // Auto-save logic removed in favor of manual save if requested,
    // but typically UI updates immediately.
    // User requested "save button trigger update api", so we might remove auto-save here
    // But for now, I'll keep the state update and expose a public save method.
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
  }

  Future<void> saveSettings() async {
    final style = JarStyle(
      shape: selectedShape.value,
      colorIndex: selectedColorIndex.value,
      theme: 'custom',
    );

    try {
      await _jarService.updateJar(
        jarId,
        name: jarName.value,
        styleSettings: style.toJson(),
      );
      Get.snackbar(
        'Success',
        'Jar settings saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void toggleInvite(bool value) {
    allowInvite.value = value;
  }

  void toggleAdminDelete(bool value) {
    adminOnlyDelete.value = value;
  }

  void removeMember(int index) {
    debugPrint('Remove member at $index');
  }

  void archiveJar() {
    debugPrint('Archive Jar');
  }
}
