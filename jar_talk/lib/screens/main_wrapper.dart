import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:jar_talk/controllers/main_wrapper_controller.dart';
import 'package:jar_talk/widgets/custom_bottom_bar.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final MainWrapperController controller = Get.put(MainWrapperController());

    return Scaffold(
      extendBody: true, // Content behind bar
      body: navigationShell,
      bottomNavigationBar: Obx(
        () => CustomBottomBar(
          currentIndex: controller.selectedIndex,
          onTap: (index) {
            controller.goToTab(index);
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
