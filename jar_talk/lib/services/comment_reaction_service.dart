import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../models/reaction_model.dart';
import 'dio_client.dart';

class CommentReactionService {
  final Dio _dio = DioClient.instance.dio;

  // ==================== COMMENTS ====================

  /// Get all comments for a slip
  Future<List<Comment>> getCommentsForSlip(
    int slipId, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/comments/slip/$slipId',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  /// Create a new comment on a slip
  Future<Comment> createComment(int slipId, String textContent) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {
          'slip_id': slipId,
          'text_content': textContent,
        },
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  /// Update a comment (author only)
  Future<Comment> updateComment(int commentId, String textContent) async {
    try {
      final response = await _dio.put(
        '/comments/$commentId',
        data: {
          'text_content': textContent,
        },
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  /// Delete a comment (author or admin)
  Future<void> deleteComment(int commentId) async {
    try {
      await _dio.delete('/comments/$commentId');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // ==================== REACTIONS ====================

  /// Toggle reaction on a slip
  /// - Same type: removes reaction
  /// - Different type: updates reaction
  /// - No reaction: adds reaction
  Future<Map<String, dynamic>> toggleReaction(
    int slipId,
    String reactionType,
  ) async {
    try {
      final response = await _dio.post(
        '/reactions/toggle',
        data: {
          'slip_id': slipId,
          'reaction_type': reactionType,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to toggle reaction: $e');
    }
  }

  /// Get all reactions for a slip
  Future<List<Reaction>> getReactionsForSlip(int slipId) async {
    try {
      final response = await _dio.get('/reactions/slip/$slipId');

      final List<dynamic> data = response.data;
      return data.map((json) => Reaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load reactions: $e');
    }
  }

  /// Get reaction summary (grouped by type with counts)
  Future<List<ReactionSummary>> getReactionSummary(int slipId) async {
    try {
      final response = await _dio.get('/reactions/slip/$slipId/summary');

      final List<dynamic> data = response.data;
      return data.map((json) => ReactionSummary.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load reaction summary: $e');
    }
  }

  /// Remove user's reaction from a slip
  Future<void> removeReaction(int slipId) async {
    try {
      await _dio.delete('/reactions/slip/$slipId');
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }
}
