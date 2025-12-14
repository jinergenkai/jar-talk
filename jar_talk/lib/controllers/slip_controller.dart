import 'package:get/get.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/services/slip_service.dart';

class SlipController extends GetxController {
  final SlipService _slipService = SlipService();

  final RxList<Slip> slips = <Slip>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Track the current container ID
  final RxInt currentContainerId = 0.obs;

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

  Future<bool> createSlip(String textContent) async {
    if (currentContainerId.value == 0) return false;

    try {
      isLoading.value = true;
      // TODO: Add location logic if needed
      await _slipService.createSlip(currentContainerId.value, textContent);

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
