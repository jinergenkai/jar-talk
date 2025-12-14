import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/app_controller.dart';

class ProfileController extends GetxController {
  // Jar Identity
  final RxString jarName = 'Summer 2024 Memories'.obs;
  final String createdDate = 'Oct 12, 2023';

  // Appearance
  final RxString selectedShape = 'Mason'.obs;
  final RxInt selectedColorIndex = 0.obs;

  // Permissions
  final RxBool allowInvite = true.obs;
  final RxBool adminOnlyDelete = false.obs;

  // Mock Data
  final List<Map<String, dynamic>> members = [
    {
      'name': 'Alice (You)',
      'isAdmin': true,
      'avatarUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDbU504Y3fFBaHR18EIxfvr9jcdw36lVM7yC9J_mLrEuiiDSrmtKvLoiC-qrMwfOhwoAtLcAVMXoCQEyLnXYkyqyExhmRQv-w6csYwBMElFIy7NOUrnEoP1GhU2TW57A9J3yoP7MzYTuJBApfA2tD1VlsglJUNlsz_vDYoyfxDFiQfWEnb35YbZNJlDOQhzW_Q_T7sglxsty0WmIIsLT5zrb9jHrQuj7gfO8YgAc2WQ_-wD2epBLQ0nzbp7gCdpw2wOkK43-bMXVmgc',
    },
    {
      'name': 'Marcus',
      'isAdmin': false,
      'avatarUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCU5Ooke_Frv32NdjXKLudacAFqtoKs6dPtCbjThozEt0eBwB8noK9kjjIt7D-MhAJ0nmmqpy7URwPO2v4rb-F4XU26X6T5tFcONKgYfvm2kdBZDSamGh0clAoFeKiM63c8EVB2AXDvjtyEIN71ME9zfjgGxC4H_tWVyV4OQ5Uu3_G5G4xBMZV30F3o_5iXDHT7BeWCGgt0Kf7hbZZRTevFmlifXKHCvV0A3aoNriUPGlqR29lKxylhDVVjl52oTSah0Vup8T7bth8O',
    },
  ];

  final List<int> themeColors = [
    0xFFD47311, // Primary Orange
    0xFF5D4037, // Brown
    0xFF388E3C, // Green
    0xFF1976D2, // Blue
    0xFF7B1FA2, // Purple
  ];

  void updateJarName(String name) {
    jarName.value = name;
  }

  void selectShape(String shape) {
    selectedShape.value = shape;
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
    // Update global theme
    final appController = Get.find<AppController>();
    // appController.changeThemeColor(Color(themeColors[index]));
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
