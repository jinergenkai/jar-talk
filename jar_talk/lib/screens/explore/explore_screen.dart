import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  // Add controller logic here
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ExploreController());

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: const Center(
        child: Text('Explore Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
