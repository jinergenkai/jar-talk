import 'package:get/get.dart';
import 'package:jar_talk/controllers/shelf_controller.dart';

class ShelfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelfController>(() => ShelfController());
  }
}
