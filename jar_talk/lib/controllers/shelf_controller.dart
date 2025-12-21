import 'dart:convert';
import 'package:get/get.dart';
import 'package:jar_talk/models/jar_model.dart';
import 'package:jar_talk/services/jar_service.dart';

class ShelfController extends GetxController {
  final JarService _jarService = JarService();

  final RxList<Jar> activeJars = <Jar>[].obs;
  // TODO: Implement archiving logic in backend, for now we might filter or just keep empty
  final RxList<Jar> archivedJars = <Jar>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJars();
  }

  Future<void> fetchJars() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final jars = await _jarService.getUserJars();
      activeJars.assignAll(jars);
      // Logic for archived jars can be added later if backend supports state/status
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching jars: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createJar(String name, {String? styleSettings}) async {
    try {
      final settings =
          styleSettings ??
          jsonEncode({"shape": "Mason", "colorIndex": 0, "theme": "default"});
      final newJar = await _jarService.createJar(name, styleSettings: settings);
      activeJars.add(newJar);
    } catch (e) {
      Get.snackbar("Error", "Could not create jar: $e");
    }
  }
}
