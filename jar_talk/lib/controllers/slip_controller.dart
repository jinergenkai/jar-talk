import 'package:get/get.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/models/jar_model.dart';
import 'package:jar_talk/services/slip_service.dart';
import 'package:jar_talk/services/jar_service.dart';
import 'package:jar_talk/services/media_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class SlipController extends GetxController {
  final SlipService _slipService = SlipService();
  final MediaService _mediaService = MediaService();
  final JarService _jarService = JarService();

  final RxList<Slip> slips = <Slip>[].obs;
  final Rx<Jar?> currentJar = Rx<Jar?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Track the current container ID
  final RxInt currentContainerId = 0.obs;

  Future<void> fetchJarDetails(int jarId) async {
    try {
      final jar = await _jarService.getJarDetails(jarId);
      currentJar.value = jar;
    } catch (e) {
      print("Error fetching jar details: $e");
    }
  }

  Future<void> fetchSlips(int containerId) async {
    try {
      currentContainerId.value = containerId;
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedSlips = await _slipService.getSlips(containerId);
      slips.assignAll(fetchedSlips);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching slips: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSlip(
    String textContent, {
    String? title,
    String? emotion,
    XFile? imageFile,
  }) async {
    if (currentContainerId.value == 0) return false;

    try {
      isLoading.value = true;

      // 1. Create Slip first
      final slip = await _slipService.createSlip(
        currentContainerId.value,
        textContent,
        title: title,
        emotion: emotion,
      );

      // 2. If image is selected, upload it
      if (imageFile != null) {
        try {
          final bytes = await imageFile.readAsBytes();
          final contentType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

          // Request Upload URL
          final uploadData = await _mediaService.getUploadUrl(
            'image',
            contentType,
          );
          final uploadUrl = uploadData['upload_url'];
          final fileKey = uploadData['file_key'];

          // Upload to MinIO
          await _mediaService.uploadFileToMinio(uploadUrl, bytes, contentType);

          // Create Media Record
          await _mediaService.createMediaRecord(
            slip.id,
            'image', // Assuming image for now
            fileKey,
          );
        } catch (e) {
          print("Error uploading media: $e");
          // Optionally show a non-blocking error or just continue
          Get.snackbar("Warning", "Slip created but image upload failed: $e");
        }
      }

      // Refresh list
      await fetchSlips(currentContainerId.value);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
