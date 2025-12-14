import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:jar_talk/controllers/main_wrapper_controller.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final MainWrapperController controller = Get.put(MainWrapperController());

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: (index) {
            controller.goToTab(index);
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.shelves), label: 'Shelf'),
            NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
