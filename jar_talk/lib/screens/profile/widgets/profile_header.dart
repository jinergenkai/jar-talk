import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD47311);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 48,
              height: 48,
              color: Colors.transparent,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            ),
          ),
          const Expanded(
            child: Text(
              'Jar Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Save action
            },
            child: Container(
              width: 48,
              alignment: Alignment.centerRight,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
