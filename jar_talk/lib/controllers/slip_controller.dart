import 'package:get/get.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/models/jar_model.dart';
import 'package:jar_talk/models/comment_model.dart';
import 'package:jar_talk/models/reaction_model.dart';
import 'package:jar_talk/services/slip_service.dart';
import 'package:jar_talk/services/jar_service.dart';
import 'package:jar_talk/services/media_service.dart';
import 'package:jar_talk/services/comment_reaction_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class SlipController extends GetxController {
  final SlipService _slipService = SlipService();
  final MediaService _mediaService = MediaService();
  final JarService _jarService = JarService();
  final CommentReactionService _commentReactionService = CommentReactionService();

  final RxList<Slip> slips = <Slip>[].obs;
  final Rx<Jar?> currentJar = Rx<Jar?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Track the current container ID
  final RxInt currentContainerId = 0.obs;

  // Comment & Reaction observables
  final RxList<Comment> currentSlipComments = <Comment>[].obs;
  final RxList<ReactionSummary> currentSlipReactions = <ReactionSummary>[].obs;
  final RxBool commentsLoading = false.obs;
  final RxBool reactionsLoading = false.obs;
  final RxString commentError = ''.obs;

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

  // ==================== COMMENT METHODS ====================

  /// Fetch comments for a slip
  Future<void> fetchCommentsForSlip(int slipId) async {
    try {
      commentsLoading.value = true;
      commentError.value = '';

      final comments = await _commentReactionService.getCommentsForSlip(slipId);
      currentSlipComments.assignAll(comments);
    } catch (e) {
      commentError.value = 'Failed to load comments: $e';
      Get.snackbar('Error', 'Could not load comments');
    } finally {
      commentsLoading.value = false;
    }
  }

  /// Add a comment to a slip
  Future<bool> addComment(int slipId, String textContent) async {
    if (textContent.trim().isEmpty) {
      Get.snackbar('Error', 'Comment cannot be empty');
      return false;
    }

    try {
      final newComment = await _commentReactionService.createComment(slipId, textContent);

      // Add to list
      currentSlipComments.insert(0, newComment);

      // Update slip's comment count in the slips list
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        final updatedSlip = Slip(
          id: slips[slipIndex].id,
          containerId: slips[slipIndex].containerId,
          authorId: slips[slipIndex].authorId,
          title: slips[slipIndex].title,
          emotion: slips[slipIndex].emotion,
          textContent: slips[slipIndex].textContent,
          createdAt: slips[slipIndex].createdAt,
          locationData: slips[slipIndex].locationData,
          authorUsername: slips[slipIndex].authorUsername,
          authorEmail: slips[slipIndex].authorEmail,
          authorProfilePicture: slips[slipIndex].authorProfilePicture,
          media: slips[slipIndex].media,
          comments: slips[slipIndex].comments,
          commentCount: slips[slipIndex].commentCount + 1,
          reactions: slips[slipIndex].reactions,
          reactionCount: slips[slipIndex].reactionCount,
        );
        slips[slipIndex] = updatedSlip;
      }

      Get.snackbar('Success', 'Comment added');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e');
      return false;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int commentId, int slipId) async {
    try {
      await _commentReactionService.deleteComment(commentId);

      // Remove from list
      currentSlipComments.removeWhere((c) => c.commentId == commentId);

      // Update slip's comment count
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        final updatedSlip = Slip(
          id: slips[slipIndex].id,
          containerId: slips[slipIndex].containerId,
          authorId: slips[slipIndex].authorId,
          title: slips[slipIndex].title,
          emotion: slips[slipIndex].emotion,
          textContent: slips[slipIndex].textContent,
          createdAt: slips[slipIndex].createdAt,
          locationData: slips[slipIndex].locationData,
          authorUsername: slips[slipIndex].authorUsername,
          authorEmail: slips[slipIndex].authorEmail,
          authorProfilePicture: slips[slipIndex].authorProfilePicture,
          media: slips[slipIndex].media,
          comments: slips[slipIndex].comments,
          commentCount: slips[slipIndex].commentCount - 1,
          reactions: slips[slipIndex].reactions,
          reactionCount: slips[slipIndex].reactionCount,
        );
        slips[slipIndex] = updatedSlip;
      }

      Get.snackbar('Success', 'Comment deleted');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment: $e');
      return false;
    }
  }

  // ==================== REACTION METHODS ====================

  /// Fetch reaction summary for a slip
  Future<void> fetchReactionSummary(int slipId) async {
    try {
      reactionsLoading.value = true;

      final reactions = await _commentReactionService.getReactionSummary(slipId);
      currentSlipReactions.assignAll(reactions);
    } catch (e) {
      Get.snackbar('Error', 'Could not load reactions');
    } finally {
      reactionsLoading.value = false;
    }
  }

  /// Toggle reaction on a slip
  Future<void> toggleReaction(int slipId, String reactionType) async {
    try {
      final result = await _commentReactionService.toggleReaction(slipId, reactionType);

      // Refresh reactions
      await fetchReactionSummary(slipId);

      // Update slip in list
      final slipIndex = slips.indexWhere((s) => s.id == slipId);
      if (slipIndex != -1) {
        // Re-fetch slip to get updated reaction counts
        await fetchSlips(slips[slipIndex].containerId);
      }

      final action = result['action'] as String;
      if (action == 'added') {
        Get.snackbar('', 'Reaction added', duration: const Duration(seconds: 1));
      } else if (action == 'removed') {
        Get.snackbar('', 'Reaction removed', duration: const Duration(seconds: 1));
      } else {
        Get.snackbar('', 'Reaction updated', duration: const Duration(seconds: 1));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle reaction: $e');
    }
  }
}
