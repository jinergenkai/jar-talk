import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  late final RxInt _selectedIndex;

  int get selectedIndex => _selectedIndex.value;

  @override
  void onInit() {
    super.onInit();
    _selectedIndex = 0.obs;
  }

  void goToTab(int index) {
    _selectedIndex.value = index;
  }
}
