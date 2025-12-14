import 'package:flutter/material.dart';
import 'package:get/get.dart'; // If you use Obx for selections later
import 'package:jar_talk/controllers/profile_controller.dart';
import 'package:jar_talk/screens/profile/widgets/section_header.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    const surfaceLight = Colors.white;

    return Column(
      children: [
        const SectionHeader(title: 'Appearance'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jar Shape',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  children: [
                    _buildShapeOption(
                      'Mason',
                      controller.selectedShape.value == 'Mason',
                    ),
                    const SizedBox(width: 16),
                    _buildShapeOption(
                      'Apothecary',
                      controller.selectedShape.value == 'Apothecary',
                    ),
                    const SizedBox(width: 16),
                    _buildShapeOption(
                      'Bowl',
                      controller.selectedShape.value == 'Bowl',
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Colors.black12),
              ),
              const Text(
                'Shared Theme Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...controller.themeColors.asMap().entries.map((entry) {
                      // Use index for selection comparison if strictly index based
                      // design implies color values, controller has list of ints
                      return GestureDetector(
                        onTap: () => controller.selectColor(entry.key),
                        child: _buildColorOption(
                          Color(entry.value),
                          controller.selectedColorIndex.value == entry.key,
                        ),
                      );
                    }),
                    // Add button
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF374151), Color(0xFF111827)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShapeOption(String label, bool isSelected) {
    const primaryColor = Color(0xFFD47311);
    const woodAccent = Color(0xFF483623);

    // In real app, attach onTap to this widget or parent to change selection
    // Here we assume simple display or modify to include onTap

    return Expanded(
      // Make touch target better or just fit row
      child: GestureDetector(
        onTap: () {
          // Ideally passing a callback or calling controller
          controller.selectShape(label);
        },
        child: Column(
          children: [
            Container(
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected
                    ? woodAccent.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: primaryColor, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.4),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(2), // Rough Mason shape
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : const Color(0xFFC9AD92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, bool isSelected) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : [],
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}
