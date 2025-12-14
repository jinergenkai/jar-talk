import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShelfController extends GetxController {
  // Add controller logic here
}

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if needed (or use Get.put/Get.find elsewhere)
    Get.put(ShelfController());

    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: const Center(
        child: Text('Shelf Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
