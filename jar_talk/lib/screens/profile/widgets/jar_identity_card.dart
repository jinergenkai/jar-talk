import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/profile_controller.dart';
import 'package:jar_talk/utils/ui_extensions.dart';

class JarIdentityCard extends StatelessWidget {
  const JarIdentityCard({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD47311);
    const textSecondary = Color(0xFFC9AD92);
    const woodAccent = Color(0xFF483623);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Glow
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ).blur(20),
              ),
              // Jar Image
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuCE5866zhgUYWxReryWg4FbO8ZHO1OSmewyY5BLncuWaMqAlNB5ShlktP_W0Faq5dhyWxL1jTJCW--ajDexX2ZwSd70wgBj_argHrSAtwmX4vWOec6BcLWUdAEU0zxYXvBU9Thq6q0leahJzpxriPdaGj1GwrMP7G5LC4aztGvwPz0-IbEFweDrwfmf6wDCo9t8C6Sf5P-2QGLNoxztEwi5cMQIrszU-Hlpdwya6SVtuE3IGZKUk3BfYSoutYTtJMsHqceipueMe-Ar",
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              Positioned(
                bottom: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C241B),
                    shape: BoxShape.circle,
                    border: Border.all(color: woodAccent),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.edit, size: 16, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextField(
              textAlign: TextAlign.center,
              controller: TextEditingController(text: controller.jarName.value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.jarName.value.length),
                ),
              onChanged: controller.updateJarName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          Text(
            'Created ${controller.createdDate}',
            style: const TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }
}
